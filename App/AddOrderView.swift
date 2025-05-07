import SwiftUI
import UniformTypeIdentifiers

struct AddOrderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var customer: Customer

    @State private var productName = ""
    @State private var quantity: Int16 = 1
    @State private var date = Date()
    @State private var selectedPDFData: Data?
    @State private var showDocumentPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Produkt")) {
                    TextField("Produktname", text: $productName)
                    Stepper(value: $quantity, in: 1...100) {
                        Text("Anzahl: \(quantity)")
                    }
                    DatePicker("Bestelldatum", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("PDF anhängen")) {
                    if selectedPDFData != nil {
                        Text("PDF hochgeladen ✅")
                            .foregroundColor(.green)
                    } else {
                        Text("Kein PDF ausgewählt")
                            .foregroundColor(.gray)
                    }

                    Button("PDF auswählen") {
                        showDocumentPicker = true
                    }
                }

                Section {
                    Button(action: addOrder) {
                        Label("Bestellung speichern", systemImage: "checkmark")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Neue Bestellung")
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(pdfData: $selectedPDFData)
            }
        }
    }

    private func addOrder() {
        let newOrder = Order(context: viewContext)
        newOrder.productName = productName
        newOrder.quantity = quantity
        newOrder.date = date
        newOrder.pdfData = selectedPDFData
        newOrder.isFulfilled = false
        newOrder.customer = customer  // ✅ Linking to the correct customer

        do {
            try viewContext.save()
            print("✅ Bestellung gespeichert!")
            print("📦 Total Orders: \((customer.orders as? NSSet)?.count ?? 0)")
            dismiss()
        } catch {
            print("❌ Fehler beim Speichern der Bestellung: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let testCustomer = Customer(context: context)
    testCustomer.name = "Testkunde"
    return AddOrderView(customer: testCustomer)
        .environment(\.managedObjectContext, context)
}
