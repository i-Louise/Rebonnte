//
//  EditingMedicineDetailView.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import SwiftUI

struct EditingMedicineDetailView: View {
    @ObservedObject var viewModel: MedicineDetailViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CustomTextFieldView(imageName: "pills.fill", placeholder: "Medicine name", text: $viewModel.medicineCopy.name)
                    
                    medicineStockSection
                    
                    CustomTextFieldView(imageName: "square.grid.2x2.fill", placeholder: "Aisle", text: $viewModel.medicineCopy.aisle)
                        .keyboardType(.numberPad)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    viewModel.onCancelAction()
                }
                .accessibilityLabel("Cancel")
                .accessibilityHint("Tap to cancel the edit and return to the previous screen.")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    viewModel.onDoneAction()
                }
                .accessibilityLabel("Done")
                .accessibilityHint("Tap to save the changes and exit the screen.")
            }
        }.alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text("An Error occured"),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }.overlay(
            ProgressViewCustom(isLoading: viewModel.isLoading)
        )
    }
}

extension EditingMedicineDetailView {
    
    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("Stock")
                .font(.headline)
                .accessibilityLabel("Stock section")
            HStack {
                Button(action: {
                    if viewModel.medicineCopy.stock > 0 {
                        viewModel.medicineCopy.stock -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Decrease")
                .accessibilityHint("Tap to decrease the stock by 1.")
                TextField(
                    "Stock",
                    text: Binding(
                        get: { String(viewModel.medicineCopy.stock) },
                        set: { viewModel.medicineCopy.stock = Int($0) ?? 0 }
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
                Button(action: {
                    viewModel.medicineCopy.stock += 1
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .accessibilityLabel("Increase stock")
                .accessibilityHint("Tap to increase the stock by 1.")
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }
}

struct CustomTextFieldView: View {
    var imageName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .frame(maxWidth: 15)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(5)
        .accessibilityLabel("\(placeholder) field")
        .accessibilityHint("Enter the \(placeholder)")
    }
}

//#Preview {
//    EditingMedicineDetailView()
//}
