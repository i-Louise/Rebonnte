import Foundation
import Firebase

class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var filterText: String = ""
    @Published var sortOption: SortOption = .none
    private var db = Firestore.firestore()
    private let currentUserRepository: CurrentUserRepository
    private let medicineStockService: MedicineStockService
    private var currentFilter: String = ""
    
    init(currentUserRepository: CurrentUserRepository, medicineStockService: MedicineStockService) {
        self.currentUserRepository = currentUserRepository
        self.medicineStockService = medicineStockService
    }
    
    func updateFilter(text: String) {
        currentFilter = text
        fetchMedicines()
    }
    
    func updateSorting(option: SortOption) {
        sortOption = option
        fetchMedicines()
    }
    
    func fetchMedicines() {
        medicineStockService.fetchMedicines(filterText: filterText, sortOption: sortOption) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let medicines):
                    self?.medicines = medicines
                case .failure(let error):
                    // add error message
                    print("Error fetching medicines: \(error)")
                }
            }
        }
    }
    
    func fetchAisles() {
        medicineStockService.fetchAisles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let aisles):
                    self?.aisles = aisles
                case .failure(let error):
                    print("Error fetching aisles: \(error)")
                }
            }
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String, completion: @escaping (Result<String, Error>) -> Void) {
        medicineStockService.addMedicine(name: name, stock: stock, aisle: aisle) { result in
            switch result {
            case .success(let userEmail):
                let newMedicine = Medicine(name: name, stock: stock, aisle: aisle)
                
                self.addHistory(action: "Added \(name)",
                                user: userEmail,
                                medicineId: newMedicine.id ?? "",
                                details: "Added new medicine")
                
                self.fetchMedicines()
            case .failure(let error): break
                //set error
            }
        }
    }
    
    func deleteMedicines(at offsets: IndexSet) {
        offsets.map { medicines[$0] }.forEach { medicine in
            guard let id = medicine.id else { return }
            medicineStockService.deleteMedicine(withID: id) { [weak self] error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self?.medicines.removeAll { $0.id == id }
                    }
                }
            }
        }
    }
    
    private func addHistory(action: String, user: String, medicineId: String, details: String) {
        let history = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        medicineStockService.addHistory(history: history) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("History added successfully.")
                case .failure(let error):
                    print("History added failure.")
                    //self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func getMedicineDetailViewModel(medicine: Medicine) -> MedicineDetailViewModel {
        return MedicineDetailViewModel(
            networkService: medicineStockService,
            medicine: medicine,
            currentUserRepository: currentUserRepository)
    }
}
