//
//  NotificationManager.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2025-07-04.
//

import Foundation
import Combine
import SQLite3



class NotificationManager: ObservableObject {
    
    @Published var latestNotification: NotificationPayload?
    
    private var dbPath: String?
    private var fileMonitor: DispatchSourceFileSystemObject?
    private var db: OpaquePointer?
    private var lastNotificationUUID: String?

    init() {
        DispatchQueue.global(qos: .background).async {
            self.dbPath = self.getNotificationDbPath()
            self.setupDatabaseMonitoring()
        }
    }

    deinit {
        fileMonitor?.cancel()
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    func dismissLatestNotification() {
        DispatchQueue.main.async {
            self.latestNotification = nil
        }
    }

    private func setupDatabaseMonitoring() {
        guard let dbPath = dbPath else {
            return
        }
        
        let url = URL(fileURLWithPath: dbPath)
        let fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            return
        }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: .global(qos: .background))
        
        fileMonitor?.setEventHandler { [weak self] in
            self?.queryLatestNotification()
        }
        
        fileMonitor?.setCancelHandler {
            close(fileDescriptor)
        }
        
        fileMonitor?.resume()
    }

    private func queryLatestNotification() {
        guard let dbPath = dbPath else { return }
        
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            return
        }
        defer { sqlite3_close(db) }

        let query = "SELECT uuid, app_id, title, body, request_data FROM record WHERE presented = 0 ORDER BY delivered_date DESC LIMIT 1;"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            return
        }
        defer { sqlite3_finalize(statement) }

        if sqlite3_step(statement) == SQLITE_ROW {
            
            guard let uuid_c = sqlite3_column_text(statement, 0),
                  let app_id_c = sqlite3_column_text(statement, 1) else {
                return
            }
            
            let uuid = String(cString: uuid_c)
            if uuid == lastNotificationUUID { return }
            lastNotificationUUID = uuid
            
            let appIdentifier = String(cString: app_id_c)
            
            
            let allowedIdentifiers = ["com.apple.iChat", "com.apple.facetime", "com.apple.sharingd", "com.apple.controlcenter"]
            guard allowedIdentifiers.contains(appIdentifier) else { return }
            
            preemptSystemNotification(uuid: uuid)

            
            
            if appIdentifier == "com.apple.controlcenter" {
                return
            }

            let title_c = sqlite3_column_text(statement, 2)
            let body_c = sqlite3_column_text(statement, 3)
            
            var finalTitle = title_c != nil ? String(cString: title_c!) : ""
            var finalBody = body_c != nil ? String(cString: body_c!) : ""
            
            
            if appIdentifier == "com.apple.sharingd" {
                if let dataBlob = sqlite3_column_blob(statement, 4) {
                    let dataSize = sqlite3_column_bytes(statement, 4)
                    let requestData = Data(bytes: dataBlob, count: Int(dataSize))
                    
                    if let plist = try? PropertyListSerialization.propertyList(from: requestData, options: [], format: nil) as? [String: Any],
                       let aps = plist["aps"] as? [String: Any],
                       let alert = aps["alert"] as? [String: Any] {
                        
                        if let titleArgs = alert["title-loc-args"] as? [String], let senderName = titleArgs.first {
                            finalTitle = senderName
                        }
                        
                        if let bodyArgs = alert["body-loc-args"] as? [String], let fileName = bodyArgs.first {
                            finalBody = fileName
                        }
                    }
                }
            }
            
            let payload = NotificationPayload(id: uuid, appIdentifier: appIdentifier, title: finalTitle, body: finalBody)
            
            DispatchQueue.main.async {
                self.latestNotification = payload
            }
        }
    }
    
    private func preemptSystemNotification(uuid: String) {
        guard let dbPath = dbPath else { return }
        var write_db: OpaquePointer?
        
        if sqlite3_open_v2(dbPath, &write_db, SQLITE_OPEN_READWRITE, nil) != SQLITE_OK {
            return
        }
        defer { sqlite3_close(write_db) }

        let updateQuery = "UPDATE record SET presented = 1 WHERE uuid = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(write_db, updateQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (uuid as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
            }
        }
        sqlite3_finalize(statement)
    }

    private func getNotificationDbPath() -> String? {
        let basePath = ("~/Library/Application Support/NotificationCenter" as NSString).expandingTildeInPath
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: basePath)
            return files.first { $0.hasSuffix(".db") }.map { (basePath as NSString).appendingPathComponent($0) }
        } catch {
            return nil
        }
    }
}
