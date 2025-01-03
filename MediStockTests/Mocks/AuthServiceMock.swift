//
//  AuthServiceMock.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import Foundation
import FirebaseAuth
@testable import MediStock

class AuthServiceMock: AuthenticationProtocol {
    var shouldSucceed: Bool = true
    var loginSucceed: Bool = false
    var isSignOut: Bool = false
    var mockUser: User?
    var handle: AuthStateDidChangeListenerHandle?

    func signIn(email: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser ?? User(uid: "fakeUid", email: "fakeEmail")
        } else {
            throw AuthError.unknownError("Mocked error during sign up")
        }
    }
    
    func signUp(email: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser ?? User(uid: "fakeUid", email: "fakeEmail")
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
    
    func listenForAuthChanges() async -> User? {
        if shouldSucceed {
            return mockUser ?? User(uid: "fakeUid", email: "fakeEmail")
        } else {
            return nil
        }
    }
    
    func removeAuthListener(handle: AuthStateDidChangeListenerHandle) async {}
    
    
}
