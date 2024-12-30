//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import Foundation

class MedicineDetailViewModel: ObservableObject {
    private let networkService: MedicineStockService
    private let currentUserRepository: CurrentUserRepository
    @Published var medicine: Medicine
    @Published var medicineCopy: Medicine
    @Published var isEditing: Bool = false
    @Published var history: [HistoryEntry] = []
    
    init(networkService: MedicineStockService, medicine: Medicine, currentUserRepository: CurrentUserRepository) {
        self.networkService = networkService
        self.medicine = medicine
        self.medicineCopy = medicine
        self.currentUserRepository = currentUserRepository
    }
    
    func onEditAction() {
        medicineCopy = medicine
        isEditing = true
    }
    
    func onCancelAction() {
        isEditing = false
    }
    func onDoneAction() {
        let originalMedicine = medicine
        medicine = medicineCopy
        updateRemoteMedicine(medicine: medicine, originalMedicine: originalMedicine)
    }
    
    private func generateActionDetails(for updatedMedicine: Medicine, original: Medicine) -> (action: String, details: String) {
        var actionDetails = [String]()
        var changeDetails = [String]()
        
        if updatedMedicine.stock != original.stock {
            let difference = updatedMedicine.stock - original.stock
            actionDetails.append("\(difference > 0 ? "Increased" : "Decreased") stock")
            changeDetails.append("Stock changed from \(original.stock) to \(updatedMedicine.stock)")
        }
        
        if updatedMedicine.name != original.name {
            actionDetails.append("Renamed medicine")
            changeDetails.append("Name changed from \(original.name) to \(updatedMedicine.name)")
        }
        
        if updatedMedicine.aisle != original.aisle {
            actionDetails.append("Updated aisle")
            changeDetails.append("Aisle number changed from \(original.aisle) to \(updatedMedicine.aisle)")
        }
        
        if actionDetails.isEmpty {
            actionDetails.append("No update")
            changeDetails.append("No significant changes detected")
        }
        
        let action = actionDetails.joined(separator: ", ")
        let details = changeDetails.joined(separator: "\n")
            
        return (action: action, details: details)
    }
    
    private func updateRemoteMedicine(medicine: Medicine, originalMedicine: Medicine) {
        guard let currentUser = currentUserRepository.getUser() else { return }
        
        networkService.updateMedicine(medicine) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let actionDetails = self?.generateActionDetails(for: medicine, original: originalMedicine) {
                        self?.addHistory(
                            action: actionDetails.action,
                            user: "User \(currentUser.email ?? "Unknown")",
                            medicineId: medicine.id ?? "Unknown ID",
                            details: actionDetails.details
                        )
                    }
                    print("Medicine updated successfully")
                    print("Success")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func addHistory(action: String, user: String, medicineId: String, details: String) {
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        networkService.addHistory(history: history) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("History added successfully.")
                case .failure(let error):
                    print("History failure")
                    //self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchHistory(for medicine: Medicine) {
        guard let medicineId = medicine.id else {
            print("Invalid medicine ID")
            return
        }
        networkService.fetchHistory(for: medicineId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedHistory):
                    self?.history = fetchedHistory
                case .failure(let error):
                    print("Failed to fetch history: \(error.localizedDescription)")
                }
            }
        }
    }
}
