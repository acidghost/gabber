import SwiftUI

@main
struct GabberApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private var eventsStore = EventsStore()
    private var cliService = CLIService()
    @State var noCLIAlert = false
    @State var eventsWindowOpen = false
    @Environment(\.openSettings) var openSettings
    @Environment(\.openWindow) var openWindow

    init() {
        if let cli = cliService.cli {
            appDelegate.cli = cli
        }
        appDelegate.eventsStore = eventsStore
    }

    var body: some Scene {
        AlertScene("Could not load CLI", isPresented: $noCLIAlert) {
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }

        WindowGroup("Events", id: "events") {
            EventsView()
                .environmentObject(eventsStore)
                .onAppear {
                    eventsWindowOpen = true
                    if cliService.cli == nil {
                        openSettings()
                    }
                }
                .onDisappear {
                    eventsWindowOpen = false
                }
        }
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: [])
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appVisibility) {}
            CommandGroup(replacing: .textEditing) {}
            CommandGroup(replacing: .textFormatting) {}
            CommandGroup(replacing: .pasteboard) {}
            CommandGroup(replacing: .undoRedo) {}
            CommandGroup(replacing: .toolbar) {}
            CommandGroup(replacing: .windowList) {
                Button("Clear Events") {
                    self.eventsStore.events.removeAll()
                }
                .keyboardShortcut(.init("d"), modifiers: .command)
                Button("Show Events") {
                    if !eventsWindowOpen {
                        openWindow(id: "events")
                    }
                }
                .keyboardShortcut(.init("e"), modifiers: .command)
            }
        }
        .defaultLaunchBehavior(.presented)

        Settings {
            SettingsView()
                .environmentObject(cliService)
                .onAppear {
                    if cliService.error != nil {
                        noCLIAlert = true
                    }
                }
        }
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var cli: CLI?
    var eventsStore: EventsStore!

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        print("opening urls: \(urls)")
        guard let url = urls.first else { return }
        guard let cli = self.cli else {
            print("CLI not yet initialized")
            return
        }
        eventsStore.events.append(.opening(url: url))
        Task {
            do {
                try await cli.run(url)
                eventsStore.events.append(.closed(url: url))
            } catch {
                eventsStore.events.append(.error(url: url, error: error))
            }
        }
    }
}
