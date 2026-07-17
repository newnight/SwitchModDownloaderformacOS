import Foundation
import os.log

enum AppLogger {
    private static let subsystem = "com.switchmoddownloader"

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let dataSource = Logger(subsystem: subsystem, category: "DataSource")
    static let service = Logger(subsystem: subsystem, category: "Service")
    static let storage = Logger(subsystem: subsystem, category: "Storage")
    static let ui = Logger(subsystem: subsystem, category: "UI")
}
