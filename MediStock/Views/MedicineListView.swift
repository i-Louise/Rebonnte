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
        }
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
}

//#Preview {
//    MedicineListView()
//}
