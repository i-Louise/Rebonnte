//
//  MedicineDetailViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import Foundation

class MedicineDetailViewModel: ObservableObject {
    private let networkService: MedicineStockProtocol
    private let currentUserRepository: CurrentUserProtocol
    @Published var medicine: Medicine
    @Published var medicineCopy: Medicine
    @Published var isEditing: Bool = false
    @Published var history: [HistoryEntry] = []
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    @Published var isShowingAlert: Bool = false
    
    init(networkService: MedicineStockProtocol, medicine: Medicine, currentUserRepository: CurrentUserProtocol) {
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
        isLoading = true
        alertMessage = nil
        guard let currentUser = currentUserRepository.getUser() else { return }
        Task {
            do {
                try await networkService.updateMedicine(medicine)
                let actionDetails = self.generateActionDetails(for: medicine, original: originalMedicine)
                await self.addHistory(
                    action: actionDetails.action,
                    user: "User \(currentUser.email ?? "Unknown")",
                    medicineId: medicine.id ?? "Unknown ID",
                    details: actionDetails.details
                )
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isEditing = false
                }
            } catch {
                isLoading = false
                alertMessage = "Error updating medicine: \(error)"
                isShowingAlert = true
            }
        }
    }
    
    private func addHistory(action: String, user: String, medicineId: String, details: String) async {
        isLoading = false
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        do {
            try await networkService.addHistory(history: history)
        } catch {
            alertMessage = "Error adding history: \(error)"
        }
    }
    
    func fetchHistory(for medicine: Medicine) {
        isLoading = false
        alertMessage = nil
        guard let medicineId = medicine.id else { return }
        Task {
            do {
                let history = try await networkService.fetchHistory(for: medicineId)
                DispatchQueue.main.async {
                    self.history = history
                    print("fetchHistory succeded, history: \(self.history.count)")
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.alertMessage = "An error occured while fetching history"
                    self.isShowingAlert = true
                }
            }
        }
    }
}
