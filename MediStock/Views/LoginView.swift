import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                viewModel.signIn(email: email, password: password)
            }) {
                Text("Login")
            }
            Button(action: {
                // open sheet
            }) {
                Text("Sign Up")
            }
        }
        .padding()
    }
}

//#Preview {
//    LoginView(viewModel: LoginViewModel(authenticationService: AuthenticationService()))
//}
