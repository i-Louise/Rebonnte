//
//  LoginViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    private let authenticationService: AuthenticationProtocol
    private var currentUserRepository: CurrentUserRepository
    
    init(authenticationService: AuthenticationProtocol, currentUserRepository: CurrentUserRepository) {
        self.authenticationService = authenticationService
        self.currentUserRepository = currentUserRepository
    }
    
    func signIn(email: String, password: String) {
        authenticationService.signIn(email: email, password: password) { result in
            switch result {
            case .success(let user):
                self.currentUserRepository.setUser(user)
            case .failure(let error):
                // Add error message
                print("Sign in failed: \(error.localizedDescription)")
            }
        }
    }
    func signOut() {
        authenticationService.signOut { result in
            switch result {
            case .success:
                self.currentUserRepository.clearUser()
            case .failure(let error):
                print("Sign out failed: \(error.localizedDescription)")
            }
        }
    }
}
