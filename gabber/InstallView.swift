import SwiftUI

struct InstallView: View {
    @State private var showInstallAlert = false
    @State private var installError: Error?
    @State private var installCompleted = false
    @State private var isDirectoryPickerPresented = false
    @State private var installPath = FileManager.default.homeDirectoryForCurrentUser.appending(
        components: ".local", "bin")

    let cli: CLI

    var body: some View {
        Group {
            HStack(spacing: 4) {
                TextField(
                    "No directory selected",
                    text: Binding<String>(
                        get: { installPath.path },
                        set: { _ in }
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .truncationMode(.head)
                .disabled(true)
                Button("Browse", systemImage: "folder.badge.questionmark") {
                    isDirectoryPickerPresented = true
                }
                .buttonStyle(.bordered)
            }
            Button("Install CLI", systemImage: "apple.terminal") {
                showInstallAlert = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: 340)
        .alert(
            "Installing CLI",
            isPresented: $showInstallAlert
        ) {
            Button("Cancel", role: .cancel) {}
            Button("OK") {
                installError = nil
                installCompleted = false
                do {
                    try cli.install(in: installPath)
                    installCompleted = true
                } catch {
                    installError = error
                }
            }
        } message: {
            Text("Are you sure you want to install the CLI?")
        }
        .alert(
            "CLI installed!",
            isPresented: $installCompleted
        ) {
        } message: {
            let bin = installPath.appending(component: "git-gabber").path
            Text("The CLI has been installed at \(bin). Restart your terminal to use it.")
        }
        .alert(
            "Error installing CLI",
            isPresented: Binding<Bool>(
                get: { installError != nil },
                set: { _ in installError = nil }
            ),
            actions: {},
            message: {
                ScrollView {
                    Text(installError?.localizedDescription ?? "An unknown error occurred.")
                }
            }
        )
        .fileImporter(
            isPresented: $isDirectoryPickerPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    installPath = url
                }
            case .failure(let error):
                print("Error selecting directory: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    InstallView(cli: try! CLI())
}
