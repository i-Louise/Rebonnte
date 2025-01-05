import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: MainViewModel
    private let loginViewModel: LoginViewModel
    private let medicineStockViewModel: MedicineStockViewModel
    
    init(viewModel: MainViewModel, loginViewModel: LoginViewModel, medicineStockViewModel: MedicineStockViewModel) {
        self.viewModel = viewModel
        self.loginViewModel = loginViewModel
        self.medicineStockViewModel = medicineStockViewModel
    }
    
    var body: some View {
        Group {
            if viewModel.currentUser != nil {
                MainTabView(medicineStockViewModel: medicineStockViewModel, loginViewModel: loginViewModel)
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
        .onAppear {
            viewModel.listenForAuthChanges()
        }
        .onDisappear {
            viewModel.removeAuthListener()
        }
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(viewModel: Main, loginViewModel: LoginViewModel(authenticationService: AuthenticationService(), currentUserRepository: CurrentUserRepository()))
//    }
//}
