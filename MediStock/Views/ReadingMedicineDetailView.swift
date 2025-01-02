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
                    Text(viewModel.medicine.name)
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                }
                .padding(.horizontal, 15)
                List {
                    Section(header: Text("Informations")) {
                        HStack {
                            Image(systemName: "pencil.and.list.clipboard")
                            Text("\(viewModel.medicine.stock) in stock")
                        }
                        HStack {
                            Image(systemName: "square.grid.2x2.fill")
                            Text("Aisle \(viewModel.medicine.aisle)")
                        }
                    }
                    Section(header: Text("History")) {
                        if viewModel.history.isEmpty {
                            Text("No history yet")
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
                        Text(entry.action)
                            .font(.headline)
                    }
                    Text("\(entry.user)")
                        .font(.subheadline)
                    Text("Date: \(entry.timestamp.formatted())")
                        .font(.subheadline)
                    Text("Details: \(entry.details)")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 5)
            }
        
    }
}

//#Preview {
//    ReadingMedicineDetailView(viewModel: MedicineDetailViewModel(), medicine: Medicine(name: "test", stock: 45, aisle: "10"))
//}
