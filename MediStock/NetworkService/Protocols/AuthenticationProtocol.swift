//
//  AuthenticationProtocol.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation
import FirebaseAuth

protocol AuthenticationProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func listenForAuthChanges() async -> User?
    func removeAuthListener(handle: AuthStateDidChangeListenerHandle) async
}
