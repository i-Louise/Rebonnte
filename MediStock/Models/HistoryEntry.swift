import Foundation
import FirebaseFirestoreSwift

struct HistoryEntry: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var medicineId: String
    var user: String
    var action: String
    var details: String
    var timestamp: Date

    init(id: String? = nil, medicineId: String, user: String, action: String, details: String, timestamp: Date = Date()) {
        self.id = id
        self.medicineId = medicineId
        self.user = user
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }
    static func == (lhs: HistoryEntry, rhs: HistoryEntry) -> Bool {
        return lhs.id == rhs.id &&
        lhs.medicineId == rhs.medicineId &&
        lhs.user == rhs.user &&
        lhs.action == rhs.action &&
        lhs.details == rhs.details &&
        lhs.timestamp.timeIntervalSince1970 == rhs.timestamp.timeIntervalSince1970
    }
}
