//
//  DittoManager.swift
//  UpsertTests
//
//  Created by Maximilian Alexander on 11/28/21.
//

import Foundation
import DittoSwift

class DittoManager {
    static let shared = DittoManager()

    let ditto: Ditto

    init() {
        ditto = Ditto(identity: .onlinePlayground(appID: "600f455f-a1f0-403d-8042-b746b2c581ab", enableDittoCloudSync: true))
        try! ditto.setLicenseToken("o2d1c2VyX2lka21lcmdlLXRlc3RzZmV4cGlyeXgYMjAyMi0wMy0zMVQyMzo1OTo1OS4yMzhaaXNpZ25hdHVyZXhYd2xISWc5R2RrSHRPeW8rcnIxd3VwWklmclJPekVPa2NicWR5cVZvd2hFdzRncGcrZFhPWWp5aEVVZDlNQzQwUWQyYVoyVlFsUzZYMjhUeU54R1c5c2c9PQ==")
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
          // non preview simulators and real devices can sync
          try! ditto.tryStartSync()
        }
    }
}
