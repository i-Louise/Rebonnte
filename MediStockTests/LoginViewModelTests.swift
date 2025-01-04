//
//  LoginViewModelTests.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import XCTest
@testable import MediStock

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockService: AuthServiceMock!
    var userRepository = CurrentUserRepository()
    
    override func setUp() {
        super.setUp()
        mockService = AuthServiceMock()
        viewModel = LoginViewModel(authenticationService: mockService, currentUserRepository: userRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func test_onLoginAction_withInvalidEmail_setsErrorMessage() {
        // Given
        let invalidEmail = "invalid-email"
        let password = "password123"

        // When
        viewModel.onLoginAction(email: invalidEmail, password: password)

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Incorrect email format, please try again.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_signIn_successful() async {
        // Given
        let expectation = XCTestExpectation()
        let email = "test@example.com"
        let password = "password123"
        mockService.shouldSucceed = true

        // When
        viewModel.onLoginAction(email: email, password: password)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.mockService.loginSucceed)
            XCTAssertNil(self.viewModel.alertMessage)
            expectation.fulfill()
        }
    }
    
    func test_signIn_failure_setsAlertMessage() async {
        // Given
        let expectation = XCTestExpectation()
        mockService.shouldSucceed = false
        let email = "test@example.com"
        let password = "password123"

        // When
        viewModel.onLoginAction(email: email, password: password)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertNotNil(self.viewModel.alertMessage)
            XCTAssertEqual(self.viewModel.alertMessage, AuthError.invalidCredentials.errorDescription)
            XCTAssertTrue(self.viewModel.showingAlert)
            expectation.fulfill()
        }
    }

}
