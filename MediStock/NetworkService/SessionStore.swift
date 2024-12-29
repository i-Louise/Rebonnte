import Foundation
import Firebase

class AuthenticationService: AuthenticationProtocol {
    @Published var session: User?
    var handle: AuthStateDidChangeListenerHandle?
    
    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>)
        -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "AuthenticationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknow error while registration"])))
            }
        }
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>)
        -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error while login"])))
            }
        }
    }
    
    func signOut(
        completion: @escaping (Result<Void, Error>)
        -> Void
    ) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func listenForAuthChanges(
        _ callback: @escaping (User?)
        -> Void)
    -> AuthStateDidChangeListenerHandle
    {
        return Auth.auth().addStateDidChangeListener { _, firebaseUser in
            if let firebaseUser = firebaseUser {
                let user = User(uid: firebaseUser.uid, email: firebaseUser.email)
                callback(user)
            } else {
                callback(nil)
            }
        }
    }
    
    func removeAuthListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
