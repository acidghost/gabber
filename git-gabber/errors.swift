import Foundation

enum GabberError: LocalizedError {
    case programsNotFound([String])
    case cmdRun(Error)
    case cmd(String, Int32)
    case tmp(Error)
    case wrapped(String, Error)

    var errorDescription: String? {
        switch self {
        case .programsNotFound(let programs):
            if programs.count == 1 {
                return "program '\(programs[0])' not found"
            } else {
                return "programs '\(programs.joined(separator: "', '"))' not found"
            }
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
