import Foundation
import Firebase

class AuthenticationService: AuthenticationProtocol {
    @Published var session: User?
    var handle: AuthStateDidChangeListenerHandle?
    
    func signUp(email: String, password: String) async throws -> User {
        
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
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
                if let error = error {
                    continuation.resume(throwing: error)
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
    
    func listenForAuthChanges() async -> User? {
        await withCheckedContinuation { continuation in
            // Add a state listener
            var handle: AuthStateDidChangeListenerHandle?
            handle = Auth.auth().addStateDidChangeListener { _, firebaseUser in
                // Ensure the continuation is resumed only once
                if let firebaseUser = firebaseUser {
                    let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(returning: nil)
                }
                
                // Remove the listener to prevent multiple invocations
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
