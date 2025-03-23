import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cliService: CLIService

    var body: some View {
        VStack(spacing: 20) {
            AboutView()
            Spacer()
            if let cli = cliService.cli {
                InstallView(cli: cli)
            } else if let err = cliService.error {
                ErrorView(error: err)
            } else {
                ProgressView()
            }
            Spacer()
            VStack(spacing: 8) {
                Text("Made with ❤️ and a 555")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
        .environmentObject(CLIService())
}
