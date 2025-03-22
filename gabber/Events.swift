import Combine
import SwiftUI

class GabberEvents: NSObject {
    static let shared = GabberEvents()
    let eventsPublisher = PassthroughSubject<Event, Never>()
    enum Event: Identifiable, Equatable {
        case opening(uid: UUID = UUID(), ts: Date = Date(), url: URL)
        case closed(uid: UUID = UUID(), ts: Date = Date(), url: URL)
        case error(uid: UUID = UUID(), ts: Date = Date(), url: URL, error: Error)
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
        static func == (lhs: GabberEvents.Event, rhs: GabberEvents.Event) -> Bool {
            lhs.id == rhs.id
        }
    }
    func append(_ event: Event) {
        eventsPublisher.send(event)
    }
}

class EventsStore: ObservableObject {
    @Published var events: [GabberEvents.Event] = []
    private var cancellableSet: Set<AnyCancellable> = []
    init() {
        GabberEvents.shared.eventsPublisher
            .receive(on: RunLoop.main)
            .sink { self.events.append($0) }
            .store(in: &cancellableSet)
    }
}
