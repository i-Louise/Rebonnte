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
    func fetchMedicines(filterText: String, sortOption: SortOption, completion: @escaping (Result<[Medicine], Error>) -> Void)
    func fetchAisles(completion: @escaping (Result<[String], Error>) -> Void)
    func addMedicine(name: String, stock: Int, aisle: String, completion: @escaping (Result<String, Error>) -> Void)
    func deleteMedicine(withID id: String, completion: @escaping (Error?) -> Void)
    func updateStock(medicineId: String, newStock: Int, completion: @escaping (Result<Void, Error>) -> Void)
    func updateMedicine(_ medicine: Medicine, completion: @escaping (Result<Void, Error>) -> Void)
    func addHistory(history: HistoryEntry, completion: @escaping (Result<Void, Error>) -> Void)
    func fetchHistory(for medicineId: String, completion: @escaping (Result<[HistoryEntry], Error>) -> Void)
}

class MedicineStockService: MedicineStockProtocol {
    
    private var db = Firestore.firestore()
    
    func fetchMedicines(filterText: String, sortOption: SortOption, completion: @escaping (Result<[Medicine], Error>) -> Void) {
        var query: Query = Firestore.firestore().collection("medicines")
            
            if !filterText.isEmpty {
                query = query.whereField("name", isGreaterThanOrEqualTo: filterText)
                              .whereField("name", isLessThanOrEqualTo: filterText + "\u{f8ff}")
            }
            
            switch sortOption {
            case .name:
                query = query.order(by: "name", descending: false)
            case .stock:
                query = query.order(by: "stock", descending: false)
            case .none:
                break
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let medicines: [Medicine] = documents.compactMap { document in
                    try? document.data(as: Medicine.self) // Assurez-vous que Medicine est `Codable`
                }
                completion(.success(medicines))
            }
    }
    
    func fetchAisles(completion: @escaping (Result<[String], Error>) -> Void) {
        db.collection("medicines").addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = querySnapshot else {
                completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found"])))
                return
            }
            let allMedicines = snapshot.documents.compactMap { document in
                try? document.data(as: Medicine.self)
            }
            let uniqueAisles = Array(Set(allMedicines.map { $0.aisle })).sorted()
            completion(.success(uniqueAisles))
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String, completion: @escaping (Result<String, Error>) -> Void) {
        let medicine = Medicine(name: name, stock: stock, aisle: aisle)
        
        guard let userEmail = Auth.auth().currentUser?.email else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
        let medicineID = medicine.id ?? UUID().uuidString
        do {
            try db.collection("medicines").document(medicineID).setData(from: medicine)
            completion(.success(userEmail))
        } catch let error {
            completion(.failure(error))
            print("Error adding document: \(error)")
        }
    }
    
    func deleteMedicine(withID id: String, completion: @escaping (Error?) -> Void) {
        db.collection("medicines").document(id).delete { error in
            completion(error)
        }
    }
    
    func updateStock(medicineId: String, newStock: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("medicines").document(medicineId).updateData([
            "stock": newStock
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateMedicine(_ medicine: Medicine, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let medicineId = medicine.id else {
            completion(.failure(NSError(domain: "MedicineError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Medicine ID"])))
            return
        }
        
        do {
            try db.collection("medicines").document(medicineId).setData(from: medicine)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func addHistory(history: HistoryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        let historyID = history.id ?? UUID().uuidString
        do {
            try db.collection("history").document(historyID).setData(from: history)
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func fetchHistory(for medicineId: String, completion: @escaping (Result<[HistoryEntry], Error>) -> Void) {
        db.collection("history").whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let history = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: HistoryEntry.self)
                } ?? []
                completion(.success(history))
            }
        }
    }
    
}
