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
    var currentUserRepository = CurrentUserRepository()
    var medicine: Medicine?

    override func setUp() {
        super.setUp()
        mockService = MedicineServiceMock()
        viewModel = MedicineDetailViewModel(networkService: mockService, medicine: medicine ?? Medicine(name: "mock", stock: 0, aisle: "1"), currentUserRepository: currentUserRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
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
    
    func testOnDoneActionUpdatesMedicineSuccessfully() async {
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
            XCTAssertNotNil(self.viewModel.alertMessage)
            XCTAssertTrue(self.viewModel.isShowingAlert)
            expectation.fulfill()
        }
    }
    func testFetchHistorySuccessfully() async {
        // Given
        let expectation = XCTestExpectation()
        let sampleHistory = [
            HistoryEntry(id: "1", medicineId: "1", user: "test@example.com", action: "Test Action", details: "Test Details")
        ]
        mockService.shouldSucceed = true
        mockService.historyEntries = sampleHistory
        
        // When
        viewModel.fetchHistory(for: Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1"))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.history, sampleHistory, "The fetched history should match the stubbed data")
            expectation.fulfill()
        }
    }
    
    func testFetchHistoryFails() async {
        // Given
        let expectation = XCTestExpectation()
        mockService.shouldSucceed = false
        
        viewModel.fetchHistory(for: Medicine(id: "1", name: "Aspirin", stock: 100, aisle: "A1"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.alertMessage, "An error occured while fetching history")
            XCTAssertTrue(self.viewModel.isShowingAlert)
            expectation.fulfill()
        }
    }
    
}
