import SwiftUI

struct AllMedicinesView: View {
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var sortOption: SortOption = .none
    @State private var isShowingAddMedicineSheet = false

    var body: some View {
        NavigationView {
            VStack {
                // Filtrage et Tri
                HStack {
                    TextField("Filter by name", text: $viewModel.filterText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 10)
                        .onChange(of: viewModel.filterText) { newValue in
                            viewModel.updateFilter(text: newValue)
                        }
                        .accessibilityLabel("Filter by name")
                        .accessibilityHint("Type to filter medicines by name.")
                    
                    Spacer()

                    Picker("Sort by", selection: $viewModel.sortOption) {
                        Text("None").tag(SortOption.none)
                        Text("Name").tag(SortOption.name)
                        Text("Stock").tag(SortOption.stock)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.trailing, 10)
                    .onChange(of: viewModel.sortOption) { newValue in
                        viewModel.updateSorting(option: newValue)
                    }
                    .accessibilityLabel("Sort options")
                    .accessibilityHint("Select a sort option for the list of medicines.")
                }
                .padding(.top, 10)
                
                // Liste des Médicaments
                List {
                    ForEach(viewModel.medicines, id: \.id) { medicine in
                        NavigationLink(destination: MedicineDetailView(viewModel: viewModel.getMedicineDetailViewModel(medicine: medicine))) {
                            VStack(alignment: .leading) {
                                Text(medicine.name)
                                    .font(.headline)
                                    .accessibilityLabel("\(medicine.name)")
                                Text("Stock: \(medicine.stock)")
                                    .font(.subheadline)
                                    .accessibilityLabel("Stock count: \(medicine.stock)")
                            }
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteMedicines(at: offsets)
                    }
                    
                }
                .navigationBarTitle("All Medicines")
                .navigationBarItems(
                    trailing: Button(action: {
                        isShowingAddMedicineSheet = true
                    }) {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add new medicine")
                            .accessibilityHint("Tap to add a new medicine to the list.")
                    }
                )
                .sheet(isPresented: $isShowingAddMedicineSheet) {
                    AddMedicineView(isShowingAddMedicineSheet: $isShowingAddMedicineSheet)
                        .environmentObject(viewModel)
                }
            }
        }
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case none
    case name
    case stock

    var id: String { self.rawValue }
}

//struct AllMedicinesView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllMedicinesView()
//    }
//}
