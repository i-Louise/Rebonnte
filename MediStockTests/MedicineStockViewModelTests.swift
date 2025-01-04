//
//  MedicineStockViewModelTests.swift
//  MediStockTests
//
//  Created by Louise Ta on 04/01/2025.
//

import XCTest
@testable import MediStock

final class MedicineStockViewModelTests: XCTestCase {
    var viewModel: MedicineStockViewModel!
    var mockService: MedicineServiceMock!
    var currentUserRepository = CurrentUserRepository()

    override func setUp() {
        super.setUp()
        mockService = MedicineServiceMock()
        viewModel = MedicineStockViewModel(currentUserRepository: currentUserRepository, medicineStockService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testUpdateFilter() {
        // Given
        let expectations = XCTestExpectation()
        let testFilterText = "Test Filter"
        
        // When
        viewModel.updateFilter(text: testFilterText)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.filterText, testFilterText, "Filter text should be updated.")
            XCTAssertTrue(self.viewModel.medicines.isEmpty, "Medicines array should be reset.")
            XCTAssertTrue(self.mockService.serviceIsCalled, "fetchMedicines should be called.")
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1.0)
    }
    
    func testUpdateSorting() {
        // Given
        let expectations = XCTestExpectation()
        let testSortOption: SortOption = .name
        
        // When
        viewModel.updateSorting(option: testSortOption)
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.sortOption, testSortOption, "Sort option should be updated.")
            XCTAssertTrue(self.viewModel.medicines.isEmpty, "Medicines array should be reset.")
            XCTAssertTrue(self.mockService.serviceIsCalled, "fetchMedicines should be called.")
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 1.0)
    }
    
    func testFetchMedicinesSuccess() {
        // Given
        let expectation = XCTestExpectation()
        let expectedMedicines = [Medicine(name: "Paracetamol", stock: 20, aisle: "A1")]
        mockService.fetchedMedicines = expectedMedicines
        mockService.shouldSucceed = true
        
        // When
        viewModel.fetchMedicines()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.medicines, expectedMedicines, "Medicines should be fetched successfully.")
            XCTAssertFalse(self.viewModel.isLoading, "Loading state should be false after fetching.")
            XCTAssertNil(self.viewModel.alertMessage, "No alert message should be shown on success.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchMedicinesFailure() {
        // Given
        let expectation = XCTestExpectation()
        let expectedMedicines = [Medicine(name: "Paracetamol", stock: 20, aisle: "A1")]
        mockService.fetchedMedicines = expectedMedicines
        mockService.shouldSucceed = false
        
        // When
        viewModel.fetchMedicines()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading, "Loading state should be false after fetching.")
            XCTAssertNotNil(self.viewModel.alertMessage, "An alert message should be shown on error.")
            XCTAssertTrue(self.viewModel.isShowingAlert, "Alert should be shown on error.")
            XCTAssertTrue(self.viewModel.medicines.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    func testAddMedicineSuccess() {
        // Given
        let expectation = XCTestExpectation()
        mockService.shouldSucceed = true
        
        // When
        viewModel.addMedicine(name: "Ibuprofen", stock: 30, aisle: "B2")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.addedMedicineSucceed)
            XCTAssertFalse(self.viewModel.isLoading, "Loading state should be false after adding.")
            XCTAssertTrue(self.viewModel.isAdded, "Medicine should be added successfully.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testAddMedicineFailure() {
        // Given
        let expectation = XCTestExpectation(description: "Add medicine should fail and show an alert")
        mockService.shouldSucceed = false
        viewModel.isLoading = true
        
        // When
        viewModel.addMedicine(name: "Ibuprofen", stock: 30, aisle: "B2")
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockService.serviceIsCalled, "addMedicine should be called on the service.")
            XCTAssertFalse(self.viewModel.isLoading, "Loading state should be false after error.")
            XCTAssertFalse(self.viewModel.isAdded, "isAdded should remain false on error.")
            XCTAssertNotNil(self.viewModel.alertMessage, "An alert message should be shown on error.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
