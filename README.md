# Gabber

**Clone and edit GitHub repositories directly from your browser with temporary local copies**

## Overview

Gabber is a browser extension + CLI tool combination that lets you quickly clone GitHub
repositories into temporary directories and open them in your preferred editor. The
workflow consists of:

1. Browser extension that converts GitHub URLs to `gabber://` protocol links
2. Python script (bundled as macOS app) that handles cloning and temp directory management

## Features

- **One-click access** to repositories from GitHub pages
- **Automatic cleanup** of temporary directories after editing
- **Editor integration** with `$EDITOR` environment variable
- **Cross-protocol support** (HTTPS/SSH/Git URLs)

## Installation

### Browser Extension

1. Package the `ext/` directory as a browser extension
2. Install in your preferred browser (supports WebExtensions API)

### Python Script

Install the script and the macOS app bundle with `just install`.

## Credits

The idea for Gabber was inspired by [git-peek](https://github.com/Jarred-Sumner/git-peek)
and [peek](https://github.com/Jarred-Sumner/peek) by Jarred Sumner.
