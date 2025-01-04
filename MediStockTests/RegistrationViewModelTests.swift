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
        let expectation = XCTestExpectation()
        let mockUser = User(uid: "mock-uid-123", email: "test@example.com")
        mockService.mockUser = mockUser
        mockService.shouldSucceed = true
        
        viewModel.onSignUpAction(email: mockUser.email!, password: "Password1!", confirmPassword: "Password1!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.isServiceCalled)
            XCTAssertFalse(self.viewModel.isShowingAlert)
            XCTAssertNil(self.viewModel.alertMessage)
        }
    }
    
    func testOnSignUpAction_ValidInputs_Failure() {
        let expectation = XCTestExpectation()
        let mockUser = User(uid: "mock-uid-123", email: "test@example.com")
        mockService.mockUser = mockUser
        mockService.shouldSucceed = false
        
        viewModel.onSignUpAction(email: mockUser.email!, password: "Password1!", confirmPassword: "Password1!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.isServiceCalled)
            XCTAssertTrue(self.viewModel.isShowingAlert)
            XCTAssertEqual(self.viewModel.alertMessage, "An unknown error occurred. Please try again.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
        
        
    }
}
