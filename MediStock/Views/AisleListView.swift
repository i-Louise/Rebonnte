import SwiftUI

struct AisleListView: View {
    @ObservedObject var viewModel: MedicineStockViewModel
    @State private var isShowingAddMedicineSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(destination: MedicineListView(viewModel: viewModel, aisle: aisle)) {
                        Text(aisle)
                            .accessibilityLabel("Aisle \(aisle)")
                            .accessibilityHint("Tap to see the list of medicines in aisle \(aisle).")
                    }
                }
            }
            .navigationBarTitle("Aisles")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddMedicineSheet = true
            }) {
                Image(systemName: "plus")
                    .accessibilityLabel("Add new medicine")
                    .accessibilityHint("Tap to add a new medicine to the inventory.")

            })
            .sheet(isPresented: $isShowingAddMedicineSheet) {
                AddMedicineView(isShowingAddMedicineSheet: $isShowingAddMedicineSheet)
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.fetchAisles()
        }
        .alert(isPresented: $viewModel.isShowingAlert) {
            Alert(
                title: Text("An Error occured"),
                message: Text(viewModel.alertMessage ?? ""),
                primaryButton: .default(Text("Retry")) {
                    viewModel.fetchAisles()
                },
                secondaryButton: .cancel()
            )
        }.overlay(
            ProgressViewCustom(isLoading: viewModel.isLoading)
        )
    }
}

//struct AisleListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AisleListView()
//    }
//}
