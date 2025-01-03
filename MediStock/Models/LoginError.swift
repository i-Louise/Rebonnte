//
//  LoginError.swift
//  MediStock
//
//  Created by Louise Ta on 03/01/2025.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkIssue
    case userNotFound
    case emailAlreadyInUse
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "The email or password is incorrect. Please try again."
        case .networkIssue:
            return "Network issue. Please check your connection."
        case .userNotFound:
            return "No user found with the provided email."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
