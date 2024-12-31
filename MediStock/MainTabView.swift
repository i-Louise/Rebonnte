import SwiftUI

struct MainTabView: View {
    private let medicineStockViewModel: MedicineStockViewModel
    private let loginViewModel: LoginViewModel
    
    init(medicineStockViewModel: MedicineStockViewModel, loginViewModel: LoginViewModel) {
        self.medicineStockViewModel = medicineStockViewModel
        self.loginViewModel = loginViewModel
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
            UserProfileView(viewModel: loginViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
