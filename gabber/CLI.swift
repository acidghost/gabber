import Foundation

enum CLIError: LocalizedError {
    case notBundled
    case installing(_ msg: String, _ error: Error)
    case invalidURL(_ url: URL)
    case execProcess(_ msg: String, _ error: Error)
    case nonZero(_ code: Int32, _ output: String)

    var errorDescription: String? {
        switch self {
        case .notBundled:
            return "CLI not bundled"
        case .installing(let msg, let error):
            return "Failed to install CLI: \(msg): \(error)"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .execProcess(let msg, let error):
            return "Failed to run CLI: \(msg): \(error)"
        case .nonZero(let code, let output):
            return "CLI exited with non-zero code \(code):\n\(output)"
        }
    }
}

class CLI {
    private let bundledURL: URL

    init() throws(CLIError) {
        guard let bundledURL = Bundle.main.url(forResource: "git-gabber", withExtension: "") else {
            throw CLIError.notBundled
        }
        self.bundledURL = bundledURL
    }

    func install(in installPath: URL) throws(CLIError) {
        let fileManager = FileManager.default

        let cliPath = bundledURL.path()
        let destinationPath = installPath.appending(components: "git-gabber").path

        if !fileManager.fileExists(atPath: installPath.path) {
            do {
                try fileManager.createDirectory(at: installPath, withIntermediateDirectories: true)
            } catch {
                throw CLIError.installing("Failed to create bin directory", error)
            }
        }

        if fileManager.fileExists(atPath: destinationPath) {
            do {
                try fileManager.removeItem(atPath: destinationPath)
            } catch {
                throw CLIError.installing("Failed to remove existing CLI tool", error)
            }
        }

        do {
            try fileManager.copyItem(atPath: cliPath, toPath: destinationPath)
            try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destinationPath)
        } catch {
            throw CLIError.installing("Failed to copy CLI tool", error)
        }

        print("CLI tool installed successfully at \(destinationPath)")
    }

    @discardableResult
    func run(_ gabberURL: URL) throws(CLIError) -> String {
        let task = Process()
        let pipe = Pipe()

        guard var components = URLComponents(url: gabberURL, resolvingAgainstBaseURL: true) else {
            throw CLIError.invalidURL(gabberURL)
        }
        components.scheme = "https"
        guard let repoURL = components.url else {
            throw CLIError.invalidURL(gabberURL)
        }

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = [repoURL.absoluteString]
        task.executableURL = bundledURL
        task.standardInput = nil

        do {
            try task.run()
        } catch {
            throw CLIError.execProcess("Executing CLI", error)
        }

        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        guard task.terminationStatus == 0 else {
            throw CLIError.nonZero(task.terminationStatus, out)
        }
        return out
    }
}

class CLIService: ObservableObject {
    @Published var cli: CLI?
    @Published var error: CLIError?

    init() {
        do {
            cli = try CLI()
        } catch {
            self.error = error
        }
    }
}
