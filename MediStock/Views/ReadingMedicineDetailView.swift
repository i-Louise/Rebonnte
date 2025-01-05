//
//  ReadingMedicineDetailView.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import SwiftUI

struct ReadingMedicineDetailView: View {
    @ObservedObject var viewModel: MedicineDetailViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "pills.fill")
                        .font(.title)
                        .accessibilityHidden(true)
                    Text(viewModel.medicine.name)
                        .fontWeight(.bold)
                        .font(.title)
                        .accessibilityLabel("\(viewModel.medicine.name)")
                    Spacer()
                }
                .padding(.horizontal, 15)
                List {
                    Section(header: Text("Informations")) {
                        HStack {
                            Image(systemName: "pencil.and.list.clipboard")
                                .accessibilityHidden(true)
                            Text("\(viewModel.medicine.stock) in stock")
                                .accessibilityLabel("\(viewModel.medicine.stock) in stock")
                        }
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .accessibilityHidden(true)
                            Text("Aisle \(viewModel.medicine.aisle)")
                                .accessibilityLabel("Aisle \(viewModel.medicine.aisle)")
                        }
                    }
                    Section(header: Text("History")) {
                        if viewModel.history.isEmpty {
                            Text("No history yet")
                                .accessibilityLabel("No history yet for this medicine.")
                        } else {
                            historySection
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Edit") {
                            viewModel.onEditAction()
                        }
                        .accessibilityLabel("Edit medicine details")
                        .accessibilityHint("Tap to edit the details of this medicine.")
                    }
                }
            }
        }
        .navigationBarTitle("Medicine Details", displayMode: .inline)
        .onAppear {
            viewModel.fetchHistory(for: viewModel.medicine)
        }
    }
}

extension ReadingMedicineDetailView {
    
    private var historySection: some View {
        
        
            ForEach(viewModel.history) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .accessibilityHidden(true)
                        Text(entry.action)
                            .font(.headline)
                            .accessibilityLabel("Action: \(entry.action)")
                    }
                    Text("\(entry.user)")
                        .font(.subheadline)
                        .accessibilityLabel("Made by \(entry.user)")
                    Text("Date: \(entry.timestamp.formatted())")
                        .font(.subheadline)
                        .accessibilityLabel("The \(entry.timestamp.formatted())")
                    Text("Details: \(entry.details)")
                        .font(.subheadline)
                        .accessibilityLabel("\(entry.details)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 5)
                .accessibilityElement(children: .combine)
            }
        
    }
}

//#Preview {
//    ReadingMedicineDetailView(viewModel: MedicineDetailViewModel(), medicine: Medicine(name: "test", stock: 45, aisle: "10"))
//}
