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
        Task {
            let user = await authService.listenForAuthChanges()
            await MainActor.run {
                if let user = user {
                    self.currentUserRepository.setUser(user)
                    self.currentUser = user
                } else {
                    self.currentUserRepository.clearUser()
                    self.currentUser = nil
                }
            }
        }
    }
    
    deinit {
        if let handle = authListenerHandle {
            Task { [weak self] in
                guard let self = self else { return }
                await self.authService.removeAuthListener(handle: handle)
            }
        }
    }
}
