//
//  MedicineDetailViewModelTests.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import XCTest
@testable import MediStock

final class MedicineDetailViewModelTests: XCTestCase {
    var viewModel: MedicineDetailViewModel!
    var mockService: MedicineServiceMock!
    var currentUserRepository: MockCurrentUserRepository!
    var medicine: Medicine?

    override func setUp() {
        super.setUp()
        mockService = MedicineServiceMock()
        currentUserRepository = MockCurrentUserRepository()
        let mockUser = User(uid: "mock", email: "test@example.com")
        currentUserRepository.setUser(mockUser)
        viewModel = MedicineDetailViewModel(networkService: mockService, medicine: medicine ?? Medicine(name: "mock", stock: 0, aisle: "1"), currentUserRepository: currentUserRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        currentUserRepository = nil
        super.tearDown()
    }

    func testOnEditAction() {
        let sampleMedicine = Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1")
        viewModel.medicine = sampleMedicine
        
        viewModel.onEditAction()
        
        XCTAssertEqual(viewModel.medicineCopy, sampleMedicine, "The medicineCopy should match the original medicine")
        XCTAssertTrue(viewModel.isEditing, "isEditing should be true after calling onEditAction")
    }
    
    func testOnCancelAction() {
        // Given
        viewModel.isEditing = true
        
        // When
        viewModel.onCancelAction()
        
        // Then
        XCTAssertFalse(viewModel.isEditing, "isEditing should be false after calling onCancelAction")
    }
    
    func testOnDoneActionUpdatesMedicineSuccessfully() {
        // Given
        let expectation = XCTestExpectation()
        let originalMedicine = Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1")
        let updatedMedicine = Medicine(id: "1", name: "Ibuprofen", stock: 120, aisle: "B2")
        viewModel.medicine = originalMedicine
        viewModel.medicineCopy = updatedMedicine
        mockService.shouldSucceed = true
        
        // When
        viewModel.onDoneAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.serviceIsCalled, "updateMedicine should be called on the network service")
            XCTAssertTrue(self.mockService.updateMedicineSucceed, "updateMedicine should succeed")
            XCTAssertEqual(self.viewModel.medicine, updatedMedicine, "The medicine should be updated to the new values")
            XCTAssertFalse(self.viewModel.isEditing, "isEditing should be false after calling onDoneAction")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testOnDoneActionFailsToUpdateMedicine() {
        // Given
        let expectation = XCTestExpectation()
        let originalMedicine = Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1")
        let updatedMedicine = Medicine(id: "1", name: "Ibuprofen", stock: 120, aisle: "B2")
        viewModel.medicine = originalMedicine
        viewModel.medicineCopy = updatedMedicine
        mockService.shouldSucceed = false
        
        viewModel.onDoneAction()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.serviceIsCalled, "updateMedicine should be called on the network service")
            XCTAssertFalse(self.mockService.updateMedicineSucceed, "updateMedicine should fail")
            XCTAssertNotNil(self.viewModel.alertMessage, "an alert message should be set")
            XCTAssertTrue(self.viewModel.isShowingAlert, "the alert should be shown")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchHistorySuccessfully() {
        // Given
        let mockMedicine = Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1")
        let sampleHistory = [
            HistoryEntry(medicineId: "1", user: "test@example.com", action: "Test Action", details: "Test Details", timestamp: Date())
        ]
        mockService.fetchedMedicines = [mockMedicine]
        mockService.shouldSucceed = true
        mockService.historyEntries = sampleHistory
        
        let expectation = XCTestExpectation(description: "History fetch should succeed")

        // When
        viewModel.fetchHistory(for: mockMedicine)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.history, sampleHistory, "The fetched history should match the stubbed data")
            XCTAssertFalse(self.viewModel.isLoading, "isLoading should be set to false after fetch")
            XCTAssertNil(self.viewModel.alertMessage, "alertMessage should be nil when fetch succeeds")
            XCTAssertFalse(self.viewModel.isShowingAlert, "isShowingAlert should be false when fetch succeeds")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchHistoryFails() {
        // Given
        let mockMedicine = Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1")
        mockService.shouldSucceed = false
        
        let expectation = XCTestExpectation(description: "History fetch should fail and show an alert")

        // When
        viewModel.fetchHistory(for: mockMedicine)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.alertMessage, "An error occured while fetching history", "Alert message should indicate fetch failure")
            XCTAssertTrue(self.viewModel.isShowingAlert, "isShowingAlert should be true when fetch fails")
            XCTAssertTrue(self.viewModel.history.isEmpty, "History should remain empty after a failed fetch")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
}

class MockCurrentUserRepository: CurrentUserProtocol {
    private var user: User?

    func setUser(_ user: MediStock.User) {
        self.user = user
    }
    
    func clearUser() {
        self.user = nil
    }
    
    func getUser() -> User? {
        return user
    }
}
