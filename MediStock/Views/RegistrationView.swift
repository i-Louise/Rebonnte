//
//  RegistrationView.swift
//  MediStock
//
//  Created by Louise Ta on 31/12/2024.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: RegistrationViewModel
    @Binding var showPopover: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account informations")) {
                    EntryFieldView(placeHolder: "Mail address", field: $email, errorMessage: viewModel.emailErrorMessage, imageName: "mail.fill")
                        .accessibilityIdentifier("mailAddressTextField")
                    PasswordEntryFieldView(password: $password, placeHolder: "Password", errorMessage: viewModel.passwordErrorMessage)
                        .accessibilityIdentifier("passwordSecuredField")
                    PasswordEntryFieldView(password: $confirmPassword, placeHolder: "Confirm password", errorMessage: viewModel.confirmPasswordErrorMessage)
                        .accessibilityIdentifier("passwordConfirmSecuredField")
                }
                Section {
                    Button("Register") {
                        viewModel.onSignUpAction(email: email, password: password, confirmPassword: confirmPassword)
                    }
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

//#Preview {
//    RegistrationView()
//}
