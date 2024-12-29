//
//  AuthenticationProtocol.swift
//  MediStock
//
//  Created by Louise Ta on 27/12/2024.
//

import Foundation
import FirebaseAuth

protocol AuthenticationProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
    func listenForAuthChanges(_ callback: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle
    func removeAuthListener(_ handle: AuthStateDidChangeListenerHandle)
}
