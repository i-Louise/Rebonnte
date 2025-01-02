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
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    
    init(authenticationService: AuthenticationProtocol, currentUserRepository: CurrentUserRepository) {
        self.authenticationService = authenticationService
        self.currentUserRepository = currentUserRepository
    }
    
    var registrationViewModel: RegistrationViewModel {
        return RegistrationViewModel(authenticationService: authenticationService)
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                let signedUser = try await authenticationService.signIn(email: email, password: password)
                self.currentUserRepository.setUser(signedUser)
                self.isLoading = false
            } catch {
                self.alertMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                try await authenticationService.signOut()
                self.isLoading = false
            } catch {
                self.alertMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
