enum SupportedTerminal: String, CaseIterable, Identifiable {
    case ghostty
    case tmux

    var id: Self { self }
}
