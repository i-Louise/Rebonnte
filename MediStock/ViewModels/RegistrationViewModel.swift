//
//  RegistrationViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var isUserRegistered: Bool = false
    @Published var isLoading: Bool = false
    @Published var emailErrorMessage: String? = nil
    @Published var passwordErrorMessage: String? = nil
    @Published var confirmPasswordErrorMessage: String? = nil
    @Published var alertMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isShowingAlert: Bool = false
    
    private let authenticationService: AuthenticationProtocol
    
    init(authenticationService: AuthenticationProtocol) {
        self.authenticationService = authenticationService
    }
    
    func onSignUpAction(email: String, password: String, confirmPassword: String) {
        clearMessages()
        
        if !isEmailValid(email: email) {
            emailErrorMessage = "Incorrect email format."
        } else if !isPasswordValid(password: password) {
            passwordErrorMessage = "Password must be more than 6 characters, with at least one capital, numeric or special character."
        } else if password != confirmPassword {
            confirmPasswordErrorMessage = "Passwords are not matching."
        } else {
            signUp(email: email, password: password)
        }
    }
    
    private func signUp(email: String, password: String) {
        isLoading = true
        Task {
            do {
                let user = try await authenticationService.signUp(email: email, password: password)
                self.isUserRegistered = true
                self.isLoading = false
            } catch let error as AuthError {
                DispatchQueue.main.async {
                    self.alertMessage = error.errorDescription
                    self.isShowingAlert = true
                    self.isLoading = false
                }
            } catch {
                self.isUserRegistered = false
                self.alertMessage = "Failed to sign up: \(error.localizedDescription)"
                self.isShowingAlert = true
            }
        }
    }
    
    private func clearMessages() {
        emailErrorMessage = nil
        passwordErrorMessage = nil
        confirmPasswordErrorMessage = nil
    }
    
    private func isEmailValid(email: String) -> Bool {
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")
        return usernameTest.evaluate(with: email)
    }
    
    private func isPasswordValid(password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^.*(?=.{6,})(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*\\d)|(?=.*[!#$%&? ]).*$")
        return passwordTest.evaluate(with: password)
    }
}
