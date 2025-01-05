//
//  MainViewModel.swift
//  MediStock
//
//  Created by Louise Ta on 28/12/2024.
//

import Foundation
import FirebaseAuth

class MainViewModel: ObservableObject {
    private let authService: AuthenticationService
    private let currentUserRepository: CurrentUserRepository
    @Published var currentUser: User?
    
    init(authService: AuthenticationService, currentUserRepository: CurrentUserRepository) {
        self.authService = authService
        self.currentUserRepository = currentUserRepository
    }
    
    func listenForAuthChanges() {
        authService.listenForAuthChanges { user in
            if let user = user {
                self.currentUserRepository.setUser(user)
                self.currentUser = user
            } else {
                self.currentUserRepository.clearUser()
                self.currentUser = nil
            }
        }
    }
    
    func removeAuthListener() {
        authService.removeAuthListener()
    }
}
