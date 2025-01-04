import Foundation
import Firebase

class AuthenticationService: AuthenticationProtocol {
    var handle: AuthStateDidChangeListenerHandle?
    
    func signUp(email: String, password: String) async throws -> User {
        
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { [self] result, error in
                if let error = error as NSError? {
                    if let authError = AuthErrorCode.Code(rawValue: error.code) {
                        continuation.resume(throwing: mapAuthError(authError))
                    } else {
                        continuation.resume(throwing: AuthError.unknownError(error.localizedDescription))
                    }
                } else if let firebaseUser = result?.user {
                    let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknow error while registration"]))
                }
            }
        }
    }
    
    
    func signIn(email: String, password: String) async throws -> User {
        
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error as NSError? {
                    if let authError = AuthErrorCode.Code(rawValue: error.code) {
                        continuation.resume(throwing: self.mapAuthError(authError))
                    }
                } else if let firebaseUser = result?.user {
                    let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing:NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error while login"]))
                }
            }
        }
        
    }
    
    func signOut() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try Auth.auth().signOut()
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func mapAuthError(_ authErrorCode: AuthErrorCode.Code) -> AuthError {
        switch authErrorCode {
        case .invalidCredential:
            return .invalidCredentials
        case .networkError:
            return .networkIssue
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        default:
            return .unknownError("An unknown error occurred. Please try again.")
        }
    }
}

extension AuthenticationService {
    func listenForAuthChanges() async -> User? {
        await withCheckedContinuation { continuation in
            var handle: AuthStateDidChangeListenerHandle?
            handle = Auth.auth().addStateDidChangeListener { _, firebaseUser in
                if let firebaseUser = firebaseUser {
                    let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(returning: nil)
                }
                
                if let handle = handle {
                    Auth.auth().removeStateDidChangeListener(handle)
                }
            }
        }
    }
    
    
    func removeAuthListener(handle: AuthStateDidChangeListenerHandle) async {
        await withCheckedContinuation { continuation in
            Auth.auth().removeStateDidChangeListener(handle)
            continuation.resume()
        }
    }
}
