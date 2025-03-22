import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var body: some View {
        HStack {
            Image("Icon512")
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 2) {
                Text("Gabber")
                    .font(.title)
                    .bold()
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Link(destination: URL(string: "https://github.com/acidghost/gabber")!) {
                    HStack {
                        Text("GitHub")
                            .font(.subheadline)
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.blue)
                    }
                }
                .pointerStyle(.link)
                .padding(.top, 2)
            }
            .padding(.leading, 8)

        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AboutView()
}
