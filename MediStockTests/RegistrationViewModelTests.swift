//
//  RegistrationViewModelTests.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import XCTest
@testable import MediStock

final class RegistrationViewModelTests: XCTestCase {
    var viewModel: RegistrationViewModel!
    var mockService: AuthServiceMock!
    
    override func setUp() {
        super.setUp()
        mockService = AuthServiceMock()
        viewModel = RegistrationViewModel(authenticationService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testOnSignUpAction_InvalidEmail() {
        // Given & When
        viewModel.onSignUpAction(
            email: "invalid-email",
            password: "Password1!",
            confirmPassword: "Password1!"
        )

        // Then
        XCTAssertEqual(viewModel.emailErrorMessage, "Incorrect email format.")
        XCTAssertFalse(mockService.isServiceCalled)
    }
    
    func testOnSignUpAction_PasswordIncorrect() {
        // Given & When
        viewModel.onSignUpAction(
            email: "test@example.com",
            password: "incorrectPassword",
            confirmPassword: "incorrectPassword"
        )

        // Then
        XCTAssertEqual(viewModel.passwordErrorMessage, "Password must be more than 6 characters, with at least one capital, numeric or special character.")
        XCTAssertFalse(mockService.isServiceCalled)
    }
    func testOnSignUpAction_PasswordsDoNotMatch() {
        // Given & When
        viewModel.onSignUpAction(
            email: "test@example.com",
            password: "Password1!",
            confirmPassword: "DifferentPassword1!"
        )

        // Then
        XCTAssertEqual(viewModel.confirmPasswordErrorMessage, "Passwords are not matching.")
        XCTAssertFalse(mockService.isServiceCalled)
    }
    
    func testOnSignUpAction_ValidInputs() {
        // Given
        let expectation = XCTestExpectation(description: "SignUp action completes successfully with valid inputs.")
        mockService.shouldSucceed = true

        // When
        viewModel.onSignUpAction(email: "test@example.com", password: "Password1!", confirmPassword: "Password1!")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.isServiceCalled, "Service should be called during sign-up.")
            XCTAssertFalse(self.viewModel.isShowingAlert, "Alert should not be shown on valid sign-up.")
            XCTAssertNil(self.viewModel.alertMessage, "Alert message should be nil on success.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testOnSignUpAction_ValidInputs_Failure() {
        let expectation = XCTestExpectation()
        mockService.shouldSucceed = false
        
        viewModel.onSignUpAction(email: "test@example.com", password: "Password1!", confirmPassword: "Password1!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.isServiceCalled)
            XCTAssertTrue(self.viewModel.isShowingAlert)
            XCTAssertNotNil(self.viewModel.alertMessage)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
    }
}
