//
//  CurrentUserRepository.swift
//  MediStock
//
//  Created by Louise Ta on 29/12/2024.
//

import Foundation

class CurrentUserRepository: CurrentUserProtocol {
    private var user: User?
    
    func setUser(_ user: User) {
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    func getUser() -> User? {
        return user
    }
    
    func clearUser() {
        DispatchQueue.main.async {
            self.user = nil
        }
    }
}

protocol CurrentUserProtocol {
    func setUser(_ user: User)
    func getUser() -> User?
    func clearUser()
}
