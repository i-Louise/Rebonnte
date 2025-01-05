import Foundation
import Firebase

class AuthenticationService: AuthenticationProtocol {
    private var handle: AuthStateDidChangeListenerHandle?
    
    func signUp(email: String, password: String) async throws -> User {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = User(uid: authResult.user.uid, email: authResult.user.email)
            return user
        } catch {
            if let error = error as NSError? {
                if let authError = AuthErrorCode.Code(rawValue: error.code) {
                    throw mapAuthError(authError)
                } else {
                    throw AuthError.unknownError(error.localizedDescription)
                }
            } else {
                throw NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error while registration"])
            }
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = User(uid: authResult.user.uid, email: authResult.user.email)
            return user
        } catch {
            if let error = error as NSError? {
                if let authError = AuthErrorCode.Code(rawValue: error.code) {
                    throw mapAuthError(authError)
                } else {
                    throw AuthError.unknownError(error.localizedDescription)
                }
            } else {
                throw NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error while login"])
            }
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw error
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
    
    func listenForAuthChanges(onStateChange: @escaping (User?) -> Void) {
        handle = Auth.auth().addStateDidChangeListener { _, firebaseUser in
            if let firebaseUser = firebaseUser {
                let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                onStateChange(user)
            } else {
                onStateChange(nil)
            }
        }
    }
    
    func removeAuthListener() {
        if let handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
