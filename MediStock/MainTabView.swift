import SwiftUI

struct MainTabView: View {
    private let medicineStockViewModel: MedicineStockViewModel
    
    init(medicineStockViewModel: MedicineStockViewModel) {
        self.medicineStockViewModel = medicineStockViewModel
    }
    
    var body: some View {
        TabView {
            AisleListView(viewModel: medicineStockViewModel)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Aisles")
                }

            AllMedicinesView(viewModel: medicineStockViewModel)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("All Medicines")
                }
        }
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
