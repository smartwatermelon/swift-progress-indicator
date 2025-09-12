# ProgressIndicator

A lightweight macOS progress indicator that watches log files and displays real-time updates in a floating window.

## Features

- Real-time file watching with instant updates
- Clean, native macOS interface using SwiftUI
- Command-line interface for easy integration
- Minimal resource usage
- No special permissions required

## Usage

```bash
# Display progress from a log file
ProgressIndicator --watchfile=/path/to/your/logfile.log

# Show usage information
ProgressIndicator
```

## Building

```bash
# Build universal binary (Intel + Apple Silicon)
./build.sh

# Install system-wide (optional)
sudo cp release/ProgressIndicator /usr/local/bin/
```

The build script creates a universal binary that runs on both Intel and Apple Silicon Macs.

## Requirements

- macOS 13.0 or later
- Swift 5.7 or later
- Xcode Command Line Tools (for `lipo` command)

## Integration Example

Perfect for showing progress during automated setup scripts:

```bash
#!/bin/bash
# Start progress indicator
ProgressIndicator --watchfile=/tmp/setup-progress.log &
PROGRESS_PID=$!

# Update progress during tasks
echo "🔧 Installing packages..." > /tmp/setup-progress.log
install_packages

echo "⚙️ Configuring system..." > /tmp/setup-progress.log  
configure_system

echo "✅ Setup complete!" > /tmp/setup-progress.log
sleep 2

# Clean up
kill $PROGRESS_PID 2>/dev/null || true
rm -f /tmp/setup-progress.log
```

## How It Works

The app uses `DispatchSource.makeFileSystemObjectSource` to monitor file changes efficiently. When the watched file is modified, it reads the most recent non-empty line and displays it in a floating window.

The window is designed to be:

- Non-intrusive but visible
- Easy to dismiss (Cmd+Q or kill process)
- Automatically sized to content
- Always on top for visibility

## License

MIT License - feel free to use in your projects!
