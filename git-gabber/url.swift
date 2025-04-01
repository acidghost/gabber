import ArgumentParser
import Foundation

struct GitURL: ExpressibleByArgument {
    let url: String
    let isSSH: Bool
    let domain: String
    let username: String
    let repository: String
    var fullPath: String
    let line: UInt?

    var branch: String?
    var commit: String?
    var filePath: String?

    init?(argument url: String) {
        self.url = url

        if url.hasPrefix("git@") {
            isSSH = true
            let parts = url.split(separator: "@")[1].split(separator: ":")
            domain = String(parts[0])
            fullPath = String(parts[1])
            line = nil
        } else {
            isSSH = false
            guard let parsed = URLComponents(string: url) else { return nil }
            domain = parsed.host ?? ""
            fullPath = parsed.path.replacing(/^\/*/, with: "")
            line = Self.parseLineNumber(from: parsed)
        }

        fullPath = fullPath.replacing(/\.git$/, with: "")

        if fullPath.contains("/") {
            let parts = fullPath.split(separator: "/")
            username = String(parts[0])
            repository = String(parts[1])
            if parts.count > 2 {
                parseAdditionalPathComponents(parts: parts.dropFirst(2))
            }
        } else {
            username = ""
            repository = fullPath
        }
    }

    static private func parseLineNumber(from parsed: URLComponents) -> UInt? {
        guard let fragment = parsed.fragment else { return nil }
        if fragment.starts(with: "L") {
            let idx = fragment.index(after: fragment.startIndex)
            return UInt(fragment[idx...])
        }
        return nil
    }

    private mutating func parseAdditionalPathComponents(parts: ArraySlice<Substring>) {
        guard let first = parts.first else { return }
        let rest = parts.dropFirst()

        switch first {
        case "blob", "tree":
            guard let branch = rest.first else { break }
            self.branch = String(branch)
            if rest.count > 1 {
                filePath = rest.dropFirst().joined(separator: "/")
            }

        case "commit":
            guard let commit = rest.first else { break }
            self.commit = String(commit)

        default:
            break
        }
    }

    var cloneURL: String {
        if isSSH { url } else { "https://\(domain)/\(username)/\(repository).git" }
    }
}
