//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import SwiftUI

struct AddMedicineView: View {
    @Binding var isShowingAddMedicineSheet: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MedicineStockViewModel
    @State private var name: String = ""
    @State private var stock: Int = 0
    @State private var aisle: String = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medicine Information")) {
                    TextField("Name", text: $name)
                    TextField("Stock", text: Binding(
                        get: { String(stock) },
                        set: {
                            if let value = Int($0), value >= 0 {
                                stock = value
                            }
                        }
                    ))
                    .keyboardType(.numberPad)
                    TextField("Aisle", text: $aisle)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Medicine")
            .navigationBarItems(leading: Button("Cancel", action: {
                isShowingAddMedicineSheet = false
            }), trailing: Button("Add") {
                viewModel.addMedicine(name: name, stock: stock, aisle: aisle)
                if viewModel.isAdded {
                    dismiss()
                }
            }
                .disabled(name.isEmpty || aisle.isEmpty || stock == 0)
            )
        }
    }
}

//#Preview {
//    AddMedicineView()
//}
