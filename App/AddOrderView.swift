import SwiftUI

import UniformTypeIdentifiers

struct AddOrderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var customer: Customer

    @State private var showDocumentPicker = false
    @State private var selectedPDFData: Data?
    @State private var productName = ""
    @State private var quantity: Int16 = 1
    @State private var date = Date()

    var body: some View {
        Form {
            Section(header: Text("Produktdetails")) {
                TextField("Produktname", text: $productName)
                Stepper(value: $quantity, in: 1...100) {
                    Text("Anzahl: \(quantity)")
                }
                DatePicker("Bestelldatum", selection: $date, displayedComponents: .date)
            }

            Button(action: addOrder) {
                Text("Bestellung speichern")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            Section(header: Text("PDF anhängen")) {
                if selectedPDFData != nil {
                    Text("PDF hochgeladen ✅")
                        .foregroundColor(.green)
                }
                Button("PDF auswählen") {
                    showDocumentPicker = true
                }
            }
        }
        .navigationTitle("Neue Bestellung")
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(pdfData: $selectedPDFData)
        }
    }

    private func addOrder() {
        guard !productName.isEmpty else {
            print("Produktname fehlt!")
            return
        }

        let newOrder = Order(context: viewContext)
        newOrder.productName = productName
        newOrder.quantity = quantity
        newOrder.date = date
        newOrder.customer = customer
        newOrder.isFulfilled = false
        newOrder.pdfData = selectedPDFData

        do {
            try viewContext.save()
            print("Bestellung gespeichert!")
            dismiss()
        } catch {
            print("Fehler beim Speichern der Bestellung: \(error.localizedDescription)")
        }
    }

}

#Preview {
    // Dummy Customer Preview
    let context = PersistenceController.preview.container.viewContext
    let customer = Customer(context: context)
    customer.name = "Testkunde"
    return AddOrderView(customer: customer)
        .environment(\.managedObjectContext, context)
}
