# ProgressIndicator

Lightweight macOS progress indicator that displays real-time updates from log files in a native floating window.

## Installation

### Via Homebrew (Recommended)

```bash
brew tap smartwatermelon/tap
brew install --cask progress-indicator
```

### From Source

```bash
git clone https://github.com/smartwatermelon/swift-progress-indicator.git
cd swift-progress-indicator
```

## Build

```bash
./build.sh
```

Creates universal binary at `release/ProgressIndicator`.

## Use

```bash
# Show help
ProgressIndicator --help

# Start watching a log file
ProgressIndicator --watchfile=/tmp/progress.log &

# Update progress
echo "Installing packages..." > /tmp/progress.log
echo "Configuring system..." > /tmp/progress.log

# Kill when done
killall ProgressIndicator
```

## Requirements

- macOS 13.0+
- Xcode Command Line Tools

## Development

### How to Update the Homebrew Tap

For maintainers releasing new versions, see the detailed process in [RELEASING.md](RELEASING.md).

The release process follows [Justin Searls' automated distribution approach](https://justin.searls.co/posts/how-to-distribute-your-own-scripts-via-homebrew/) with GitHub Actions handling the entire pipeline from version tag to Homebrew cask update.

## Current bugs to fix

- Launch without parameter should exit after help display
- Needs a title line in the blank dialog area

## Future

- Ability to specify textarea height (more than one line)
- App should appear in Cmd-Tab switcher
- App should have at least a minimal menubar

## License

MIT License
