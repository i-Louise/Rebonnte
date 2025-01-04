//
//  AuthServiceMock.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import Foundation
@testable import MediStock

class AuthServiceMock: AuthenticationProtocol {
    var shouldSucceed: Bool = true
    var loginSucceed: Bool = false
    var isSignOut: Bool = false
    var isServiceCalled: Bool = false
    var mockUser: User = User(uid: "mock")

    func signIn(email: String, password: String) async throws -> User {
        if shouldSucceed {
            isServiceCalled = true
            return mockUser
        } else {
            throw AuthError.unknownError("Mocked error during sign up")
        }
    }
    
    func signUp(email: String, password: String) async throws -> User {
        isServiceCalled = true
        if shouldSucceed {
            return mockUser
        } else {
            throw AuthError.unknownError("Mocked error during sign up")
        }
    }
    
    func signOut() async throws {
        if shouldSucceed {
            isSignOut = true
        } else {
            throw AuthError.unknownError("Mocked error during sign out")
        }
    }

    
    
}
