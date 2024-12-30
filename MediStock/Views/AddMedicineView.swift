//
//  AddMedicineView.swift
//  MediStock
//
//  Created by Louise Ta on 30/12/2024.
//

import SwiftUI

struct AddMedicineView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: MedicineStockViewModel
    
    @State private var name: String = ""
    @State private var stock: Int = 0
    @State private var aisle: String = ""
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medicine Information")) {
                    TextField("Name", text: $name)
                    Picker("Stock", selection: $stock) {
                        ForEach(0..<101, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    TextField("Aisle", text: $aisle)
                }
            }
            .navigationTitle("Add Medicine")
            .navigationBarItems(leading: Button("Cancel", action: {
                presentationMode.wrappedValue.dismiss()
            }), trailing: Button("Add") {
                viewModel.addMedicine(name: name, stock: stock, aisle: aisle) { _ in
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
                .disabled(name.isEmpty || aisle.isEmpty || stock == 0)
            )
        }
    }
}

#Preview {
    AddMedicineView()
}
