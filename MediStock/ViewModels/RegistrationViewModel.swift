//
//  RegistrationViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var isUserRegistered: Bool = false
    private let authenticationService: AuthenticationProtocol
    
    init(authenticationService: AuthenticationProtocol) {
        self.authenticationService = authenticationService
    }
    
    func signUp(email: String, password: String) {
        authenticationService.signUp(email: email, password: password) { result in
            switch result {
            case .success(_):
                self.isUserRegistered = true
            case .failure(let error):
                // Add error message
                print("Sign up failed: \(error.localizedDescription)")
            }
        }
    }
}
