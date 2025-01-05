//
//  MedicineServiceMock.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import Foundation
import Firebase
@testable import MediStock

class MedicineServiceMock: MedicineStockProtocol {
    var shouldSucceed: Bool = false
    var fetchedMedicines: [Medicine] = []
    var fetchedAisles: [String] = []
    var serviceIsCalled: Bool = false
    var deleteMedicineCalled: Bool = false
    var stock = 0
    var historyEntries: [HistoryEntry] = []
    var addedMedicineSucceed: Bool = false
    var updateMedicineSucceed: Bool = false
    var mockLastDocument: DocumentSnapshot? = nil
    
    func fetchMedicines(filter: String? = nil, sortOption: SortOption = .none, lastVisible: DocumentSnapshot? = nil) async throws -> ([Medicine], DocumentSnapshot?){
        serviceIsCalled = true
        if shouldSucceed {
            return (fetchedMedicines, mockLastDocument)
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch medicines"])
        }
    }
    
    func fetchAisles() async throws -> [String] {
        if shouldSucceed {
            return fetchedAisles
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch aisles"])
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String, currentUserRepository: MediStock.CurrentUserRepository) async throws {
        serviceIsCalled = true
        if shouldSucceed {
            addedMedicineSucceed = true
        } else {
            addedMedicineSucceed = false
            throw NSError(domain: "MockMedicineStockService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to add medicine"])
        }
    }
    
    func deleteMedicine(withID id: String) async throws {
        if shouldSucceed {
            deleteMedicineCalled = true
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to delete medicine"])
        }
    }
    
    func updateStock(medicineId: String, newStock: Int) async throws {
        if shouldSucceed {
            stock += 1
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to update stock"])
        }
    }
    
    func updateMedicine(_ medicine: MediStock.Medicine) async throws {
        serviceIsCalled = true
        if shouldSucceed {
            updateMedicineSucceed = true
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to update medicine"])
        }
    }
    
    func addHistory(history: MediStock.HistoryEntry) async throws {
        serviceIsCalled = true
        if shouldSucceed {
            historyEntries.append(history)
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch history"])
        }
    }
    
    func fetchHistory(for medicineId: String) async throws -> [MediStock.HistoryEntry] {
        serviceIsCalled = true
        if shouldSucceed {
            return historyEntries
        } else {
            throw NSError(domain: "MockMedicineStockService", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch history"])
        }
    }
    
}
