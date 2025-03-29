import Foundation

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
        case .cmdRun(let err):
            return "failed to execute command: \(err.localizedDescription)"
        case .cmd(let out, let code):
            return "command failed with status \(code):\n\(out)"
        case .tmp(let err):
            return "failed to create temporary directory: \(err.localizedDescription)"
        case .wrapped(let msg, let err):
            return "\(msg): \(err.localizedDescription)"
        }
    }
}
