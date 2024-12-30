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
    
    lazy var mainViewModel: MainViewModel = {
        return MainViewModel(authService: authenticationService, currentUserRepository: currentUserRepository)
    }()
    
    lazy var loginViewModel: LoginViewModel = {
        return LoginViewModel(authenticationService: authenticationService, currentUserRepository: currentUserRepository)
    }()
    
    lazy var medicineStockViewModel: MedicineStockViewModel = {
        return MedicineStockViewModel(currentUserRepository: currentUserRepository, medicineStockService: MedicineStockService())
    }()
}
