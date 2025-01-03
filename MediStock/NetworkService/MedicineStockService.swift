//
//  MedicineStockService.swift
//  MediStock
//
//  Created by Louise Ta on 29/12/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol MedicineStockProtocol {
    func fetchMedicines(filter: String?, sortOption: SortOption) async throws -> [Medicine]
    func fetchAisles() async throws -> [String]
    func addMedicine(name: String, stock: Int, aisle: String, currentUserRepository: CurrentUserRepository) async throws
    func deleteMedicine(withID id: String) async throws
    func updateStock(medicineId: String, newStock: Int) async throws
    func updateMedicine(_ medicine: Medicine) async throws
    func addHistory(history: HistoryEntry) async throws
    func fetchHistory(for medicineId: String) async throws -> [HistoryEntry]
}

class MedicineStockService: MedicineStockProtocol {
    private let currentUserRepository: CurrentUserRepository = CurrentUserRepository()
    private var db = Firestore.firestore()
    
    func fetchMedicines(filter: String? = nil, sortOption: SortOption = .none) async throws -> [Medicine] {
        
        try await withCheckedThrowingContinuation { continuation in
            var query: Query = db.collection("medicines")
            
            if let filter = filter, !filter.isEmpty {
                query = query.whereField("name", isGreaterThanOrEqualTo: filter)
                    .whereField("name", isLessThanOrEqualTo: filter + "\u{f8ff}")
            }
            
            switch sortOption {
            case .name:
                query = query.order(by: "name")
            case .stock:
                query = query.order(by: "stock")
            case .none:
                break
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let snapshot = snapshot else {
                    continuation.resume(throwing: NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                    return
                }
                
                let medicines = snapshot.documents.compactMap { try? $0.data(as: Medicine.self) }
                continuation.resume(returning: medicines)
            }
        }
    }
    
    func fetchAisles() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            db.collection("medicines").getDocuments { querySnapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let snapshot = querySnapshot else {
                    continuation.resume(throwing: NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                    return
                }
                
                let uniqueAisles = Set(snapshot.documents.compactMap { document in
                    try? document.data(as: Medicine.self).aisle
                }).sorted()
                
                continuation.resume(returning: uniqueAisles)
            }
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String, currentUserRepository: CurrentUserRepository) async throws {
        let medicine = Medicine(name: name, stock: stock, aisle: aisle)
        let medicineID = medicine.id ?? UUID().uuidString
        
        do {
            try db.collection("medicines").document(medicineID).setData(from: medicine)
        } catch let error {
            throw error
        }
    }
    
    func deleteMedicine(withID id: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection("medicines").document(id).delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func updateStock(medicineId: String, newStock: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection("medicines").document(medicineId).updateData([
                "stock": newStock
            ]) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func updateMedicine(_ medicine: Medicine) async throws {
        guard let medicineId = medicine.id else {
            throw NSError(domain: "MedicineError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Medicine ID"])
        }
        
        do {
            try db.collection("medicines").document(medicineId).setData(from: medicine)
        } catch let error {
            throw error
        }
    }
    
    func addHistory(history: HistoryEntry) async throws {
        let historyID = history.id ?? UUID().uuidString
        do {
            try db.collection("history").document(historyID).setData(from: history)
        } catch let error {
            throw error
        }
    }
    
    func fetchHistory(for medicineId: String) async throws -> [HistoryEntry] {
        try await withCheckedThrowingContinuation { continuation in
            db.collection("history")
                .whereField("medicineId", isEqualTo: medicineId)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let snapshot = querySnapshot else {
                        continuation.resume(throwing: NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                        return
                    }
                    
                    let historyEntries = snapshot.documents.compactMap { document in
                        try? document.data(as: HistoryEntry.self)
                    }
                    
                    continuation.resume(returning: historyEntries)
                }
        }
    }
}
