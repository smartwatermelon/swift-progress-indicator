# ProgressIndicator

Lightweight macOS progress indicator that displays real-time updates from log files in a native floating window.

## Clone

```bash
git clone https://github.com/username/swift-progress-indicator.git
cd swift-progress-indicator
```

## Build

```bash
./build.sh
```

Creates universal binary at `release/ProgressIndicator`.

## Use

```bash
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

## Future

- Ability to specify textarea height (more than one line)
- App should appear in Cmd-Tab switcher
- App should have at least a minimal menubar

## License

MIT License
