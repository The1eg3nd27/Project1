import SwiftUI
import PDFKit

struct OrderDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var order: Order

    var body: some View {
        Form {
            Section(header: Text("Produktinformationen")) {
                Text("Produktname: \(order.productName ?? "-")")
                Text("Anzahl: \(order.quantity)")
                if let orderDate = order.date {
                    Text("Bestelldatum: \(orderDate.formatted(date: .abbreviated, time: .omitted))")
                } else {
                    Text("Bestelldatum: -")
                }
            }

            Section(header: Text("PDF Dokument")) {
                if let pdfData = order.pdfData {
                    PDFViewer(data: pdfData)
                        .frame(height: 300)
                } else {
                    Text("Kein PDF hochgeladen")
                        .foregroundColor(.gray)
                }
            }

            Section(header: Text("Status")) {
                Toggle(isOn: Binding(
                    get: { order.isFulfilled },
                    set: { newValue in
                        order.isFulfilled = newValue
                        try? viewContext.save()
                    }
                )) {
                    Text("Erledigt ✅")
                }
            }

            Section {
                Button(role: .destructive) {
                    deleteOrder()
                } label: {
                    Label("Bestellung löschen", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Bestellung Details")
    }

    private func deleteOrder() {
        viewContext.delete(order)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Löschen der Bestellung: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let order = Order(context: context)
    order.productName = "Test Produkt"
    order.quantity = 5
    return OrderDetailView(order: order)
        .environment(\.managedObjectContext, context)
}
