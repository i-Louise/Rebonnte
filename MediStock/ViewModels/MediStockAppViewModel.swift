//
//  MediStockAppViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 29/12/2024.
//

import Foundation

class MediStockAppViewModel {
    private let currentUserRepository: CurrentUserRepository
    private let authenticationService: AuthenticationService
    
    init() {
        currentUserRepository = CurrentUserRepository()
        authenticationService = AuthenticationService()
    }
    
    var mainViewModel: MainViewModel {
        return MainViewModel(authService: authenticationService, currentUserRepository: currentUserRepository)
    }
    
    var loginViewModel: LoginViewModel {
        return LoginViewModel(authenticationService: authenticationService, currentUserRepository: currentUserRepository)
    }
    var medicineStockViewModel: MedicineStockViewModel {
        return MedicineStockViewModel(currentUserRepository: currentUserRepository)
    }
}
