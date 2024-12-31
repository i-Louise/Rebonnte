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
                    }
                }
            }
            .navigationBarTitle("Aisles")
            .navigationBarItems(trailing: Button(action: {
                isShowingAddMedicineSheet = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isShowingAddMedicineSheet) {
                AddMedicineView(isShowingAddMedicineSheet: $isShowingAddMedicineSheet)
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            viewModel.fetchAisles()
        }
    }
}

//struct AisleListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AisleListView()
//    }
//}
