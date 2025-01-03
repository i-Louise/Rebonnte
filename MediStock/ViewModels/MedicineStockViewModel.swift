import Foundation
import Firebase


class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var filterText: String = ""
    @Published var sortOption: SortOption = .none
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    @Published var isAdded: Bool = false
    @Published var isShowingAlert: Bool = false
    private var db = Firestore.firestore()
    private let currentUserRepository: CurrentUserRepository
    private let medicineStockService: MedicineStockService
    private var lastDocument: DocumentSnapshot?
    private var noMoreItems: Bool = false

    
    init(currentUserRepository: CurrentUserRepository, medicineStockService: MedicineStockService) {
        self.currentUserRepository = currentUserRepository
        self.medicineStockService = medicineStockService
    }
    
    func updateFilter(text: String) {
        medicines = []
        lastDocument = nil
        noMoreItems = false
        filterText = text
        fetchMedicines()
    }
    
    func updateSorting(option: SortOption) {
        medicines = []
        lastDocument = nil
        noMoreItems = false
        sortOption = option
        fetchMedicines()
    }
    
//    func fetchMedicines() {
//        guard !isLoading && !noMoreItems else { return }
//        isLoading = true
//        alertMessage = nil
//        medicineStockService.fetchMedicines(filter: filterText, sortOption: sortOption, lastDocument: lastDocument) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let (medicines, lastDoc)):
//                    self?.medicines.append(contentsOf: medicines)
//                    self?.lastDocument = lastDoc
//                    self?.isLoading = false
//                case .failure(let error):
//                    self?.alertMessage = "Failed to load medicines: \(error.localizedDescription)"
//                    self?.isLoading = false
//                    self?.isShowingAlert = true
//                }
//            }
//        }
//    }
    
    func fetchMedicines() {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                let medicines = try await medicineStockService.fetchMedicines(filter: filterText, sortOption: sortOption)
                DispatchQueue.main.async {
                    self.medicines = medicines
                    self.isLoading = false
                }
            } catch {
                self.alertMessage = "Failed to load medicines: \(error.localizedDescription)"
                self.isLoading = false
                self.isShowingAlert = true
            }
        }
    }
        
    func fetchAisles() {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                let aislesFetched = try await medicineStockService.fetchAisles()
                DispatchQueue.main.async {
                    self.aisles = aislesFetched
                    self.isLoading = false
                }
            } catch {
                self.alertMessage = "Error fetching aisles: \(error)"
                self.isLoading = false
                self.isShowingAlert = true
            }
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String) {
        isLoading = true
        alertMessage = nil
        isAdded = false
        Task {
            do {
                let newMedicine = try await medicineStockService.addMedicine(name: name, stock: stock, aisle: aisle, currentUserRepository: currentUserRepository)
                DispatchQueue.main.async {
                    self.medicines.append(newMedicine)
                    self.isLoading = false
                    self.isAdded = true
                }
            } catch {
                isLoading = false
                alertMessage = "Error adding medicine: \(error)"
                isAdded = false
            }
        }
    }
    
    func deleteMedicines(at offsets: IndexSet) {
        for index in offsets {
            let medicine = medicines[index]
            guard let id = medicine.id else { continue }
            Task {
                do {
                    try await medicineStockService.deleteMedicine(withID: id)
                    self.medicines.removeAll { $0.id == id }
                } catch {
                    DispatchQueue.main.async {
                        print("Error removing document: \(error.localizedDescription)")
                    }
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
