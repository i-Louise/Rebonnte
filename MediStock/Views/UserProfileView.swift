//
//  UserProfileView.swift
//  MediStock
//
//  Created by Louise Ta on 31/12/2024.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("User profile")
                    Button {
                        viewModel.signOut()
                    } label: {
                        Text("Sign out")
                    }
                }
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text("An Error occured"),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            ProgressViewCustom(isLoading: viewModel.isLoading)
        )
    }
}

//#Preview {
//    UserProfileView()
//}
