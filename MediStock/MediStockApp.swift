//
//  MediStockApp.swift
//  MediStock
//
//  Created by Vincent Saluzzo on 28/05/2024.
//

import SwiftUI

@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let appViewModel = MediStockAppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: appViewModel.mainViewModel, loginViewModel: appViewModel.loginViewModel, medicineStockViewModel: appViewModel.medicineStockViewModel)
        }
    }
}
