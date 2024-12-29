//
//  CurrentUserRepository.swift
//  MediStock
//
//  Created by Louise Ta on 29/12/2024.
//

import Foundation

class CurrentUserRepository {
    private var user: User?
    
    func setUser(_ user: User) {
        self.user = user
    }
    
    func getUser() -> User? {
        return user
    }
    
    func clearUser() {
        self.user = nil
    }
}
