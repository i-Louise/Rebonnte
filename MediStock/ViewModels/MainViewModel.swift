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
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    init(authService: AuthenticationService, currentUserRepository: CurrentUserRepository) {
        self.authService = authService
        self.currentUserRepository = currentUserRepository
        self.authListenerHandle = authService.listenForAuthChanges { [weak self] user in
            if let user = user {
                self?.currentUserRepository.setUser(user)
            } else {
                self?.currentUserRepository.clearUser()
            }
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    deinit {
        if let authListenerHandle = authListenerHandle {
            authService.removeAuthListener(authListenerHandle)
        }
    }
}
