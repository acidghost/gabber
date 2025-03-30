import Foundation

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
