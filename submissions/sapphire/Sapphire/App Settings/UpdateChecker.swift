//
//  UpdateChecker.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-10.
//

import SwiftUI



let currentAppVersion = "Pre-Release"

struct GitHubReleaseAsset: Codable {
    let name: String
    let browserDownloadUrl: URL
    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
    }
}

struct GitHubRelease: Codable {
    let tagName: String
    let assets: [GitHubReleaseAsset]
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case assets
    }
}

enum UpdateStatus {
    case checking
    case upToDate
    case available(version: String, asset: GitHubReleaseAsset)
    case downloading(progress: Double)
    case downloaded(path: URL)
    case error(String)
}

@MainActor
class UpdateChecker: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var status: UpdateStatus = .checking
    private var downloadTask: URLSessionDownloadTask?

    func checkForUpdates() {
        self.status = .checking
        guard let url = URL(string: "https://api.github.com/repos/cshariq/sapphire/releases/latest") else {
            self.status = .error("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.status = .error(error.localizedDescription)
                    return
                }
                guard let data = data else {
                    self.status = .error("No data received.")
                    return
                }
                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                    let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "v"))
                    
                    if latestVersion.compare(currentAppVersion, options: .numeric) == .orderedDescending {
                        
                        if let asset = release.assets.first(where: { $0.name.hasSuffix(".dmg") || $0.name.hasSuffix(".zip") }) {
                            self.status = .available(version: latestVersion, asset: asset)
                        } else {
                            self.status = .error("No suitable asset found.")
                        }
                    } else {
                        self.status = .upToDate
                    }
                } catch {
                    self.status = .error("Failed to decode response.")
                }
            }
        }.resume()
    }

    func downloadAndUpdate(asset: GitHubReleaseAsset) {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        downloadTask = session.downloadTask(with: asset.browserDownloadUrl)
        downloadTask?.resume()
        self.status = .downloading(progress: 0)
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        guard let downloadsURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            DispatchQueue.main.async { self.status = .error("Could not find Downloads folder.") }
            return
        }
        
        let destinationURL = downloadsURL.appendingPathComponent(downloadTask.originalRequest!.url!.lastPathComponent)
        
        
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.status = .downloaded(path: destinationURL)
                NSWorkspace.shared.open(destinationURL) 
            }
        } catch {
            DispatchQueue.main.async { self.status = .error("Failed to move update to Downloads.") }
        }
    }

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.status = .downloading(progress: progress)
        }
    }
}
