# Gabber

[![License](https://img.shields.io/github/license/acidghost/gabber)](LICENSE)
[![Release](https://img.shields.io/github/v/release/acidghost/gabber)](https://github.com/acidghost/gabber/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/acidghost/gabber/ci.yaml)](https://github.com/acidghost/gabber/actions)

**Repository to editor, at high BPM**

## Description

Gabber provides instant access to GitHub repositories from your browser with
automatic cleanup. This tool combines a browser extension with a macOS app to
streamline the workflow of temporarily cloning and editing repositories. Perfect
for quick contributions, code reviews, or exploring projects without cluttering
your local filesystem.

## Quick start

1. Install the browser extension and macOS app from
   [releases](https://github.com/acidghost/gabber/releases)
2. Navigate to any GitHub repository
3. Click the Gabber button in your browser toolbar
4. Repository opens automatically in your configured editor

## Installation

### Browser extension

1. Download the latest extension package from
   [releases](https://github.com/acidghost/gabber/releases)
2. Install in your browser (supports WebExtensions API)
3. The extension will add a button to your browser toolbar

### macOS app

1. Download `Gabber.dmg` from
   [releases](https://github.com/acidghost/gabber/releases)
2. Mount the DMG and drag Gabber.app to Applications
3. Launch the app and follow the setup instructions
4. The CLI tool can be optionally installed via the app

Alternatively, build from source using [just](https://github.com/casey/just):

```bash
just install
```

## Usage

### Browser workflow

1. Navigate to any GitHub repository page
2. Click the Gabber extension button
3. Repository is cloned to a temporary directory and opened in `$EDITOR`

### CLI usage

```bash
# Direct CLI usage
git-gabber https://github.com/owner/repo

# Works with various GitHub URL formats
git-gabber https://github.com/owner/repo/blob/main/file.js#L42
git-gabber git@github.com:owner/repo.git
```

### Code example

The extension converts GitHub URLs to `gabber://` protocol links:

```javascript
// Extension automatically transforms GitHub URLs
window.location.href = "gabber://github.com/owner/repo";
```

## Configuration

Gabber uses your system's `$EDITOR` environment variable. Set it to your
preferred editor:

```bash
export EDITOR="code"        # VS Code
export EDITOR="vim"         # Vim
export EDITOR="subl"        # Sublime Text
```

No additional configuration files are required. Temporary directories are
automatically cleaned up after editing sessions.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for
guidelines on submitting issues and pull requests.

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE)
file for details.

## Credits

Inspired by [git-peek](https://github.com/Jarred-Sumner/git-peek) and
[peek](https://github.com/Jarred-Sumner/peek) by Jarred Sumner.
