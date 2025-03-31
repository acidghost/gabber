import SwiftUI

enum Event: Identifiable, Equatable {
    case opening(uid: UUID = UUID(), date: Date = Date(), url: URL)
    case closed(uid: UUID = UUID(), date: Date = Date(), url: URL)
    case error(uid: UUID = UUID(), date: Date = Date(), url: URL, error: Error)
    var id: UUID {
        switch self {
        case .opening(let uid, _, _):
            return uid
        case .closed(let uid, _, _):
            return uid
        case .error(let uid, _, _, _):
            return uid
        }
    }
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

class EventsStore: ObservableObject {
    @Published var events: [Event] = []
}
