import ArgumentParser
import Foundation

let brewenv = """
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    """

@main
struct Gabber: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "git-gabber",
        abstract: "Repository 2 editor, at high BPM"
    )

    @Option(help: "Path to git binary")
    var git: String = "/usr/bin/git"

    @Option(help: "Shell environment file to source")
    var env: String = "~/.shell/env.sh"

    @Option(help: "Editor to open the repository in")
    var editor: String = ProcessInfo.processInfo.environment["EDITOR"] ?? "$EDITOR"

    @Argument(help: "URL of the repository")
    var url: GitURL

    func run() throws {
        let tmux: String
        do {
            tmux = try shell("\(brewenv)\nwhich tmux")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            throw GabberError.wrapped("looking up tmux", error)
        }

        if tmux.isEmpty {
            throw GabberError.noTmux
        }

        let tmpdir = try TemporaryDirectory()
        defer { tmpdir.cleanup() }

        var dst = URL(filePath: tmpdir.path)
        dst.append(components: url.repository)

        do {
            try cmd(git, ["clone", url.url, dst.path()])
        } catch {
            throw GabberError.wrapped("cloning repository", error)
        }

        // TODO: make this unique to avoid strange race conditions in tmux
        let signal = "gabber-\(url.repository)"

        let neww: String
        do {
            neww = try shell(
                """
                \(brewenv)
                source \(env)
                \(tmux) -L default new-window -Pd -n \(signal) -c \(dst) \
                    '\(editor) \(dst); \(tmux) wait -S \(signal)'
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
