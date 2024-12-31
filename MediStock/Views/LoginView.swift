import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel: LoginViewModel
    @State private var showPopover = false

    var body: some View {
        VStack(spacing: 20) {
            EntryFieldView(placeHolder: "Email address", field: $email, imageName: "person.fill")
                .keyboardType(.emailAddress)
                .accessibilityIdentifier("emailTextField")
            PasswordEntryFieldView(password: $password, placeHolder: "Password")
            Button(action: {
                viewModel.signIn(email: email, password: password)
            }) {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            Button(action: {
                showPopover = true
            }) {
                Text("Sign Up")
            }
            .popover(isPresented: $showPopover) {
                RegistrationView(viewModel: viewModel.registrationViewModel, showPopover: $showPopover)
            }
        }
        .padding()
    }
}

struct EntryFieldView: View {
    var placeHolder: String
    @Binding var field: String
    var errorMessage: String? = nil
    var imageName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: imageName)
                    .frame(maxWidth: 15)
                    .accessibilityHidden(true)
                TextField(placeHolder, text: $field)
                
            }
            .padding()
            .textInputAutocapitalization(.never)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .disableAutocorrection(true)
            .accessibilityLabel("\(placeHolder) field")
            .accessibilityHint("Enter your \(placeHolder)")
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct PasswordEntryFieldView: View {
    @Binding var password: String
    @State private var hidePassword = true
    var placeHolder: String
    var errorMessage: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .accessibilityHidden(true)
            if hidePassword {
                SecureField(placeHolder, text: $password)
                    .accessibilityIdentifier("passwordSecuredTextField")
            } else {
                TextField(placeHolder, text: $password)
                    .accessibilityIdentifier("passwordTextField")
            }
            Button(action: {
                self.hidePassword.toggle()
            }, label: {
                Image(systemName: hidePassword ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(.gray)
            })
            .accessibilityIdentifier("passwordVisibilityButton")

        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .disableAutocorrection(true)
        .accessibilityLabel("\(placeHolder) field")
        .accessibilityHint("Enter your \(placeHolder)")
        
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .fixedSize(horizontal: false, vertical: true)
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}

//#Preview {
//    LoginView(viewModel: LoginViewModel(authenticationService: AuthenticationService()))
//}
