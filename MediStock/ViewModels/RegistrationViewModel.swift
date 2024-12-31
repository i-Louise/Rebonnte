//
//  RegistrationViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var isUserRegistered: Bool = false
    @Published var emailErrorMessage: String? = nil
    @Published var passwordErrorMessage: String? = nil
    @Published var confirmPasswordErrorMessage: String? = nil
    
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
