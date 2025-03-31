import SwiftUI

struct EventsView: View {
    @EnvironmentObject var eventsStore: EventsStore
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if eventsStore.events.isEmpty {
                Text("Try opening a gabber:// URL...").padding(.top, 14)
            }
            ScrollViewReader { proxy in
                List(eventsStore.events) { evt in
                    switch evt {
                    case .opening(let id, let date, let url):
                        eventView(id, date, "app.fill", "opening \(url.absoluteString)")
                    case .closed(let id, let date, let url):
                        eventView(id, date, "app.dashed", "closed \(url.absoluteString)")
                    case .error(let id, let date, let url, let err):
                        eventView(
                            id, date, "exclamationmark.triangle",
                            "error \(url.absoluteString): \(err.localizedDescription)",
                            isError: true)
                    }
                }
                .onAppear {
                    guard let lastEvent = eventsStore.events.last else { return }
                    proxy.scrollTo(lastEvent.id, anchor: .bottom)
                }
                .onChange(of: eventsStore.events) {
                    guard let lastEvent = eventsStore.events.last else { return }
                    withAnimation {
                        proxy.scrollTo(lastEvent.id, anchor: .bottom)
                    }
                }
                .frame(width: 600, height: 200)
            }
        }
    }

    func eventView(_ id: UUID, _ date: Date, _ img: String, _ txt: String, isError: Bool = false)
        -> some View
    {
        HStack(alignment: .center) {
            Text(date.formatted(date: .numeric, time: .standard))
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 100)
            Image(systemName: img)
                .resizable()
                .foregroundStyle(isError ? Color.red : Color.primary)
                .frame(width: 20, height: 20)
            Text(txt)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(txt)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .id(id)
    }
}

#Preview {
    let eventsStore = EventsStore()
    EventsView()
        .environmentObject(eventsStore)
        .task {
            eventsStore.events.append(.opening(url: URL(filePath: "testing")))
            eventsStore.events.append(.closed(url: URL(filePath: "testing")))
            try? await Task.sleep(for: .seconds(1))
            eventsStore.events.append(.opening(url: URL(filePath: "testing")))
            eventsStore.events.append(.closed(url: URL(filePath: "testing")))
            eventsStore.events.append(.opening(url: URL(filePath: "testing")))
            eventsStore.events.append(.closed(url: URL(filePath: "testing")))
            try? await Task.sleep(for: .seconds(1))
            eventsStore.events.append(
                .error(
                    url: URL(filePath: "testing"),
                    error: CLIError.execProcess("asd\ndsa\nqwe", CLIError.notBundled)))
        }
}
