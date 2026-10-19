// FileWatcher.swift (for monitoring profile changes)
import Foundation
import Combine

class FileWatcher: ObservableObject {
    private var source: DispatchSourceFileSystemObject?
    private let path: String
    
    @Published var didChange = false
    
    init(path: String) {
        self.path = path
        startWatching()
    }
    
    deinit {
        stopWatching()
    }
    
    private func startWatching() {
        let url = URL(fileURLWithPath: path)
        
        let fd = open(url.path, O_EVTONLY)
        guard fd >= 0 else {
            print("Failed to open file descriptor for \(path)")
            return
        }
        
        source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global(qos: .background)
        )
        
        source?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.didChange.toggle()
            }
        }
        
        source?.setCancelHandler {
            close(fd)
        }
        
        source?.resume()
    }
    
    private func stopWatching() {
        source?.cancel()
        source = nil
    }
}