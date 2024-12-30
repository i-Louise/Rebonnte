import SwiftUI

struct MedicineDetailView: View {
    @ObservedObject var viewModel: MedicineDetailViewModel
    
    var body: some View {
        NavigationStack {
            if viewModel.isEditing {
                EditingMedicineDetailView(viewModel: viewModel)
            } else {
                ReadingMedicineDetailView(viewModel: viewModel, medicine: viewModel.medicine)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


//struct MedicineDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
//        let sampleViewModel = MedicineStockViewModel(currentUserRepository: <#CurrentUserRepository#>)
//        MedicineDetailView(medicine: sampleMedicine, viewModel: sampleViewModel))
//    }
//}
