import ArgumentParser
import Foundation

struct GitURL: ExpressibleByArgument {
    let url: String
    let domain: String
    let username: String
    let repository: String
    var fullPath: String

    init?(argument url: String) {
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
