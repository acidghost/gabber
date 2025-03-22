import ArgumentParser
import Foundation

let brewenv = """
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    """

Gabber.main()

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

enum GabberError: LocalizedError {
    case noTmux
    case cmdRun(Error)
    case cmd(String, Int32)
    case tmp(Error)
    case wrapped(String, Error)

    var errorDescription: String? {
        switch self {
        case .noTmux:
            return "tmux not installed"
        case .cmdRun(let e):
            return "failed to execute command: \(e.localizedDescription)"
        case .cmd(let out, let ec):
            return "command failed with status \(ec):\n\(out)"
        case .tmp(let e):
            return "failed to create temporary directory: \(e.localizedDescription)"
        case .wrapped(let msg, let e):
            return "\(msg): \(e.localizedDescription)"
        }
    }
}

struct GitURL: ExpressibleByArgument {
    let url: String
    let domain: String
    let username: String
    let repository: String
    var fullPath: String

    init(argument url: String) {
        self.url = url
        if url.hasPrefix("git@") {
            let parts = url.split(separator: "@")[1].split(separator: ":")
            domain = String(parts[0])
            fullPath = String(parts[1])
        } else {
            let parsed = URLComponents(string: url)!
            domain = parsed.host ?? ""
            fullPath = parsed.path
            fullPath = fullPath.replacing(/^\/*/, with: "")
        }

        fullPath = fullPath.replacing(/\.git$/, with: "")

        if fullPath.contains("/") {
            let parts = fullPath.split(separator: "/")
            username = String(parts[0])
            repository = String(parts[1])
        } else {
            username = ""
            repository = fullPath
        }
    }
}

class TemporaryDirectory {
    private let url: URL
    let path: String

    init() throws {
        let systemTempDir = FileManager.default.temporaryDirectory
        let uniqueDirName = "gabber-" + UUID().uuidString
        self.url = systemTempDir.appendingPathComponent(uniqueDirName)
        self.path = url.path
        do {
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            throw GabberError.tmp(error)
        }
    }

    deinit {
        cleanup()
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: url)
    }
}

@discardableResult
func cmd(_ cmd: String, _ args: [String]) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = args
    task.executableURL = URL(fileURLWithPath: cmd)
    task.standardInput = nil

    do {
        try task.run()
    } catch {
        throw GabberError.cmdRun(error)
    }

    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let out = String(data: data, encoding: .utf8) ?? ""
    guard task.terminationStatus == 0 else {
        throw GabberError.cmd(out, task.terminationStatus)
    }
    return out
}

@discardableResult
func shell(_ command: String) throws -> String {
    try cmd("/bin/sh", ["-c", command])
}
