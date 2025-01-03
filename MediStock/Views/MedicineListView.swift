import SwiftUI

struct MedicineListView: View {
    @ObservedObject var viewModel: MedicineStockViewModel
    var aisle: String

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                    NavigationLink {
                        MedicineDetailView(viewModel: viewModel.getMedicineDetailViewModel(medicine: medicine))
                    } label: {
                        VStack(alignment: .leading) {
                            Text(medicine.name)
                                .font(.headline)
                            Text("Stock: \(medicine.stock)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationBarTitle(aisle)
            .alert(isPresented: $viewModel.isShowingAlert) {
                Alert(
                    title: Text("An Error occured"),
                    message: Text(viewModel.alertMessage ?? ""),
                    primaryButton: .default(Text("Retry")) {
                        viewModel.fetchMedicines()
                    },
                    secondaryButton: .cancel()
                )
            }.overlay(
                ProgressViewCustom(isLoading: viewModel.isLoading)
            )
        }
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
}

//#Preview {
//    MedicineListView()
//}
