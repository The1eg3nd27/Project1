import SwiftUI

struct CustomerDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var customer: Customer

    @FetchRequest private var orders: FetchedResults<Order>
    
    @State private var searchText = ""


    init(customer: Customer) {
        self.customer = customer
        _orders = FetchRequest<Order>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Order.date, ascending: false)
            ],
            predicate: NSPredicate(format: "customer == %@", customer)
        )
    }

    var body: some View {
        List {
            // Kontakt – read-only
            Section(header: Text("Kontakt")) {
                Text("Name: \(customer.name ?? "-")")
                Text("Telefon: \(customer.phone ?? "-")")
                Text("E-Mail: \(customer.email ?? "-")")
            }

            // Notizen – displayed multiline, not editable
            Section(header: Text("Notizen")) {
                Text(customer.notes ?? "-")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }

            // Open Orders
            Section(header: Text("Offene Bestellungen")) {
                ForEach(orders.filter { !$0.isFulfilled && isMatching($0) }) { order in
                    NavigationLink(destination: OrderDetailView(order: order)) {
                        orderRow(order: order)
                    }
                }
                .onDelete { offsets in
                    deleteFulfilled(false, at: offsets)
                }
            }


            // Fulfilled Orders
            Section(header: Text("Erledigte Bestellungen")) {
                ForEach(orders.filter { $0.isFulfilled && isMatching($0) }) { order in
                    NavigationLink(destination: OrderDetailView(order: order)) {
                        orderRow(order: order)
                    }
                }

                .onDelete { offsets in
                    deleteFulfilled(true, at: offsets)
                }
            }
        }
        .navigationTitle(customer.name ?? "Kunde")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddOrderView(customer: customer)) {
                    Label("Neue Bestellung", systemImage: "cart.badge.plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: EditCustomerView(customer: customer)) {
                    Label("Bearbeiten", systemImage: "pencil")
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suche nach Produkt...")

    }

    // MARK: - Order Row View
    @ViewBuilder
    private func orderRow(order: Order) -> some View {
        VStack(alignment: .leading) {
            Text(order.productName ?? "Unbekannt")
                .font(.headline)
            Text("Anzahl: \(order.quantity)")
                .font(.subheadline)

            if let orderDate = order.date {
                Text("Datum: \(orderDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Datum: -")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Delete Orders
    private func deleteFulfilled(_ isFulfilled: Bool, at offsets: IndexSet) {
        let filtered = orders.filter { $0.isFulfilled == isFulfilled }
        for index in offsets {
            viewContext.delete(filtered[index])
        }
        do {
            try viewContext.save()
        } catch {
            print("Fehler beim Löschen der Bestellung: \(error.localizedDescription)")
        }
    }
    private func isMatching(_ order: Order) -> Bool {
        guard !searchText.isEmpty else { return true }
        return order.productName?.localizedCaseInsensitiveContains(searchText) ?? false
    }

}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let customer = Customer(context: context)
    customer.name = "Max Mustermann"
    customer.phone = "01234 567890"
    customer.email = "max@example.com"
    customer.notes = "Wichtiger Kunde\nMag Sonderrabatte."

    return NavigationStack {
        CustomerDetailView(customer: customer)
            .environment(\.managedObjectContext, context)
    }
}
