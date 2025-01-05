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
    @Published var errorMessage: String? = nil
    @Published var showingAlert = false
    @Published var isSignedOut = false
    @Published var isLoggedIn = false
    @Published var user: User?
    
    init(authenticationService: AuthenticationProtocol, currentUserRepository: CurrentUserRepository) {
        self.authenticationService = authenticationService
        self.currentUserRepository = currentUserRepository
    }
    
    var registrationViewModel: RegistrationViewModel {
        return RegistrationViewModel(authenticationService: authenticationService)
    }
    
    func onLoginAction(
        email: String,
        password: String
    ) {
        alertMessage = nil
        errorMessage = nil
        
        if !isEmailValid(email: email) {
            isLoading = false
            errorMessage = "Incorrect email format, please try again."
        } else if password.isEmpty {
            isLoading = false
        } else {
            signIn(email: email, password: password)
        }
    }
    
    private func signIn(email: String, password: String) {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                let signedUser = try await authenticationService.signIn(email: email, password: password)
                DispatchQueue.main.async {
                    self.currentUserRepository.setUser(signedUser)
                    self.isLoading = false
                }
            } catch let signInError as AuthError {
                DispatchQueue.main.async {
                    self.alertMessage = signInError.errorDescription
                    self.isLoading = false
                    self.showingAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.isLoading = false
                    self.showingAlert = true
                }
            }
        }
    }
    
    func signOut() {
        isLoading = true
        alertMessage = nil
        Task {
            do {
                try authenticationService.signOut()
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.currentUserRepository.clearUser()
                    self.user = nil
                    self.isLoggedIn = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "An unexpected error occured. Please try again."
                    self.isLoading = false
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func isEmailValid(email: String) -> Bool {
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
        return usernameTest.evaluate(with: email)
    }
}
