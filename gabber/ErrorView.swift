import SwiftUI

struct ErrorView: View {
    @State var error: Error
    var body: some View {
        Image(systemName: "exclamationmark.triangle")
            .resizable()
            .frame(width: 32, height: 32)
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.red)
        Text("Could not load CLI!").bold()
        ScrollView {
            Text(error.localizedDescription)
        }
        .padding(8)
    }
}

#Preview {
    ErrorView(error: CLIError.notBundled)
}
