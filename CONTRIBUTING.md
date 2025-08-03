# Contributing to Gabber

Thank you for your interest in contributing to Gabber! This guide will help you
get started.

## Getting started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Create a new branch for your feature or bug fix
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development setup

### Prerequisites

- macOS (for app development)
- Xcode 15+
- Node.js 18+
- [just](https://github.com/casey/just) task runner

### Building

```bash
# Install dependencies
npm install

# Build the extension
just extension

# Build the macOS app
just build

# Run tests
just test-extension

# Check code quality
just check
```

## Project structure

```
├── gabber/           # SwiftUI macOS app
├── git-gabber/       # Swift CLI tool
├── Extension/        # Browser extension (JavaScript)
├── justfile          # Build tasks
└── README.md
```

## Coding standards

- **Swift**: Follow the project's `.swift-format` configuration
- **JavaScript**: Use ESLint and Prettier (configured in project)
- **Commits**: Use conventional commit messages

### Code formatting and linting

```bash
# Format Swift code
swift format --recursive gabber git-gabber

# Format other files
npx prettier --write .

# Check formatting
just check-format

# Lint everything
just check-lint
```

## Testing

- Browser extension tests: `npm test` / `just test-extension`
- Manual testing: Install locally built extension and app
- Test with various GitHub URL formats

## Submitting changes

1. **Create an issue** first to discuss major changes
2. **Keep PRs focused** - one feature/fix per PR
3. **Include tests** where applicable
4. **Update documentation** if needed
5. **Follow commit conventions**:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `refactor:` for code refactoring

## Bug reports

When reporting bugs, please include:

- Operating system and version
- Browser type and version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

## Feature requests

Feature requests are welcome! Please:

- Check existing issues first
- Explain the use case clearly
- Consider backwards compatibility
- Be open to discussion about implementation

## Questions?

- Open an issue for questions about contributing
- Check existing issues and discussions first
- Be respectful and constructive in all interactions

## License

By contributing to Gabber, you agree that your contributions will be licensed
under the same GPL-3.0 license that covers the project.
