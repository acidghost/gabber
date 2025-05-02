import ArgumentParser
import Foundation

let editorVar = "$EDITOR"

@main
struct Gabber: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "git-gabber",
        abstract: "Repository 2 editor, at high BPM"
    )

    @Option(help: "Editor to open the repository in")
    var editor: String = ProcessInfo.processInfo.environment["EDITOR"] ?? editorVar

    @Argument(help: "URL of the repository")
    var url: GitURL

    func run() throws {
        let editor = try resolveEditor()

        var neededPrograms = ["git", editor]
        if editor != "code" {
            neededPrograms.append("tmux")
        }

        let programs = try findPrograms(neededPrograms)
        guard let git = programs["git"] else {
            throw GabberError.programsNotFound(["git"])
        }
        guard let editorPath = programs[editor] else {
            throw GabberError.programsNotFound([editor])
        }

        let tmpdir = try TemporaryDirectory()
        defer { tmpdir.cleanup() }

        let dst = URL(filePath: tmpdir.path).appending(components: url.repository)
        try clone(with: git, into: dst)

        let editorCmd = editorCmd(for: editor, withPath: editorPath, dst)
        print("running editor command: \(editorCmd)")

        if editor == "code" {
            try shell(editorCmd)
        } else {
            guard let tmux = programs["tmux"] else {
                throw GabberError.programsNotFound(["tmux"])
            }
            try spawn(tmux: tmux, cmd: editorCmd, in: dst)
        }
    }

    func resolveEditor() throws(GabberError) -> String {
        if editor == editorVar {
            try shell("echo \(editor)")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            editor
        }
    }

    func findPrograms(_ programs: [String]) throws(GabberError) -> [String: String] {
        var script = ""
        var searchedPrograms: [String: String?] = [:]
        for program in programs {
            script += "printf '%s\n' \"$(which \(program))\"\n"
            searchedPrograms.updateValue(nil, forKey: program)
        }

        let out = try shell(script)
        for foundProgram in out.split(separator: "\n") where !foundProgram.isEmpty {
            let foundProgram = String(foundProgram).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !foundProgram.isEmpty, let parsed = URL(string: foundProgram) else { continue }
            searchedPrograms[parsed.lastPathComponent] = foundProgram
        }

        var foundPrograms: [String: String] = [:]
        var notFound: [String] = []
        for (program, maybePath) in searchedPrograms {
            if let path = maybePath {
                foundPrograms[program] = path
            } else {
                notFound.append(program)
            }
        }

        guard notFound.isEmpty else {
            throw GabberError.programsNotFound(notFound)
        }
        return foundPrograms
    }

    func clone(with git: String, into dst: URL) throws(GabberError) {
        do {
            try cmd(git, ["clone", url.cloneURL, dst.path()])
        } catch {
            throw GabberError.wrapped("cloning repository", error)
        }

        if let branchOrCommit = url.branch ?? url.commit {
            do {
                try cmd(git, ["-C", dst.path(), "checkout", branchOrCommit])
            } catch {
                throw GabberError.wrapped("checking out branch/commit", error)
            }
        }
    }

    func editorCmd(for editor: String, withPath editorPath: String, _ dst: URL) -> String {
        var cmd: String
        switch editor {
        case "vim", "nvim":
            cmd = "cd \(dst.path()) && \(editorPath)"
            if let filePath = url.filePath {
                cmd += " \(filePath)"
                if let line = url.line {
                    cmd += " +\(line)"
                }
            } else {
                cmd += " ."
            }
        case "code":
            cmd = "\(editorPath) --wait --new-window"
            if let filePath = url.filePath {
                cmd += " --goto \(dst.appending(components: filePath).path()):\(url.line ?? 1)"
            }
            cmd += " \(dst.path())"
        default:
            cmd = "cd \(dst.path()) && \(editorPath) \(url.filePath ?? ".")"
        }
        return cmd
    }

    func spawn(tmux: String, cmd editorCmd: String, in dst: URL) throws {
        // TODO: make this unique to avoid strange race conditions in tmux
        let signal = "gabber-\(url.repository)"

        let neww: String
        do {
            neww = try shell(
                """
                \(tmux) -L default new-window -Pd -n \(signal) -c \(dst) \
                    '\(editorCmd); \(tmux) wait -S \(signal)'
                """
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw GabberError.wrapped("creating new tmux window", error)
        }

        print("\(url.url) cloned to \(neww)")

        do {
            try cmd(tmux, ["-L", "default", "wait", signal])
        } catch {
            throw GabberError.wrapped("waiting for editor to exit", error)
        }
    }
}
