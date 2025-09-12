//
// ProgressIndicator - A lightweight macOS progress indicator that watches log files
//
// Usage: ProgressIndicator --watchfile=PATH_TO_LOG_FILE
//

import SwiftUI
import Foundation

@main
struct ProgressApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, maxWidth: 600, minHeight: 120, maxHeight: 200)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @State private var logFilePath: String = ""
    @State private var showUsage: Bool = false
    
    var body: some View {
        VStack {
            if showUsage {
                UsageView()
            } else if !logFilePath.isEmpty {
                ProgressView(logFilePath: logFilePath)
            } else {
                Text("Initializing...")
                    .onAppear {
                        parseArguments()
                    }
            }
        }
    }
    
    private func parseArguments() {
        let arguments = CommandLine.arguments
        
        // Check for proper usage
        if arguments.count < 2 || !arguments[1].hasPrefix("--watchfile=") {
            showUsage = true
            return
        }
        
        // Extract the file path from --watchfile=PATH
        let watchFile = String(arguments[1].dropFirst("--watchfile=".count))
        
        // Validate that the file path is not empty
        guard !watchFile.isEmpty else {
            showUsage = true
            return
        }
        
        logFilePath = watchFile
    }
}

struct UsageView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ProgressIndicator")
                .font(.headline)
            Text("Real-time log file viewer for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            Text("Usage:")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("ProgressIndicator --watchfile=PATH_TO_LOG_FILE")
                .font(.system(.body, design: .monospaced))
                .padding(.leading)
            
            Text("Example:")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("ProgressIndicator --watchfile=/tmp/my-progress.log")
                .font(.system(.body, design: .monospaced))
                .padding(.leading)
            
            Divider()
            
            Text("Exit with Cmd+Q or kill the process")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            // Print usage to console as well
            print("ProgressIndicator - Real-time log file viewer for macOS")
            print("")
            print("Usage:")
            print("  ProgressIndicator --watchfile=PATH_TO_LOG_FILE")
            print("")
            print("Description:")
            print("  Shows real-time updates from the specified log file in a floating window.")
            print("  The window displays the most recent line from the log file.")
            print("  Exit with Cmd+Q or kill the process with 'killall ProgressIndicator'")
            print("")
            print("Example:")
            print("  ProgressIndicator --watchfile=/tmp/my-progress.log")
        }
    }
}

struct ProgressView: View {
    let logFilePath: String
    @State private var currentMessage = "Waiting for updates..."
    @State private var fileMonitor: DispatchSourceFileSystemObject?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                Text("Progress")
                    .font(.headline)
                Spacer()
            }
            
            Text(currentMessage)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .onAppear {
            startWatching()
        }
        .onDisappear {
            stopWatching()
        }
    }
    
    private func startWatching() {
        // Create the file if it doesn't exist
        let fileURL = URL(fileURLWithPath: logFilePath)
        
        // Create parent directory if needed
        let parentDir = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        } catch {
            print("Warning: Could not create parent directory: \\(error)")
        }
        
        // Create empty file if it doesn't exist
        if !FileManager.default.fileExists(atPath: logFilePath) {
            FileManager.default.createFile(atPath: logFilePath, contents: Data(), attributes: nil)
            currentMessage = "Created log file: \\(logFilePath)"
        } else {
            // Read initial content
            readLatestLine()
        }
        
        // Set up file monitoring
        let fileDescriptor = open(logFilePath, O_RDONLY)
        guard fileDescriptor >= 0 else {
            currentMessage = "Error: Could not open file \\(logFilePath)"
            return
        }
        
        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: DispatchQueue.global(qos: .userInitiated)
        )
        
        fileMonitor?.setEventHandler { [self] in
            DispatchQueue.main.async {
                self.readLatestLine()
            }
        }
        
        fileMonitor?.setCancelHandler {
            close(fileDescriptor)
        }
        
        fileMonitor?.resume()
        
        currentMessage = "Watching: \\(logFilePath)"
    }
    
    private func stopWatching() {
        fileMonitor?.cancel()
        fileMonitor = nil
    }
    
    private func readLatestLine() {
        guard let contents = try? String(contentsOfFile: logFilePath, encoding: .utf8) else {
            return
        }
        
        let lines = contents.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if let lastLine = lines.last {
            currentMessage = lastLine.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}