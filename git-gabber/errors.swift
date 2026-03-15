import Foundation

enum GabberError: LocalizedError {
    case resourcesNotFound([String])
    case programsNotFound([String])
    case cmdRun(Error)
    case cmd(String, Int32)
    case tmp(Error)
    case wrapped(String, Error)

    var errorDescription: String? {
        switch self {
        case .resourcesNotFound(let resources):
            return notFound(resources, named: "resource")
        case .programsNotFound(let programs):
            return notFound(programs, named: "program")
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

    private func notFound(_ items: [String], named: String, pluralizedAs: String? = nil) -> String {
        let plural = pluralizedAs ?? named + "s"
        if items.count == 1 {
            return "\(named) '\(items[0])' not found"
        }
        return "\(plural) '\(items.joined(separator: "', '"))' not found"
    }
}
