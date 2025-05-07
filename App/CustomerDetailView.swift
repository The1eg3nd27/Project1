import SwiftUI

struct CustomerDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var customer: Customer

    @FetchRequest private var orders: FetchedResults<Order>

    init(customer: Customer) {
        self.customer = customer
        _orders = FetchRequest<Order>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Order.isFulfilled, ascending: true), // open first
                NSSortDescriptor(keyPath: \Order.date, ascending: false)        // newest first
            ],
            predicate: NSPredicate(format: "customer == %@", customer)
        )
    }

    var body: some View {
        List {
            // Kontakt section
            Section(header: Text("Kontakt")) {
                TextField("Name", text: Binding(
                    get: { customer.name ?? "" },
                    set: { newValue in
                        customer.name = newValue
                        try? viewContext.save()
                    }
                ))
                .textFieldStyle(.roundedBorder)

                TextField("Telefon", text: Binding(
                    get: { customer.phone ?? "" },
                    set: { newValue in
                        customer.phone = newValue
                        try? viewContext.save()
                    }
                ))
                .textFieldStyle(.roundedBorder)

                TextField("E-Mail", text: Binding(
                    get: { customer.email ?? "" },
                    set: { newValue in
                        customer.email = newValue
                        try? viewContext.save()
                    }
                ))
                .textFieldStyle(.roundedBorder)
            }

            Section(header: Text("Notizen")) {
                TextField("Notizen", text: Binding(
                    get: { customer.notes ?? "" },
                    set: { newValue in
                        customer.notes = newValue
                        try? viewContext.save()
                    }
                ))
                .textFieldStyle(.roundedBorder)
            }

            // Open Orders Section
            Section(header: Text("Offene Bestellungen")) {
                let openOrders = orders.filter { !$0.isFulfilled }

                if openOrders.isEmpty {
                    Text("Keine offenen Bestellungen")
                        .foregroundColor(.gray)
                } else {
                    ForEach(openOrders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            orderRow(order: order)
                        }
                    }

                    .onDelete { offsets in
                        deleteOrders(offsets: offsets, from: openOrders)
                    }
                }
            }

            // Fulfilled Orders Section
            Section(header: Text("Erledigte Bestellungen")) {
                let fulfilledOrders = orders.filter { $0.isFulfilled }

                if fulfilledOrders.isEmpty {
                    Text("Keine erledigten Bestellungen")
                        .foregroundColor(.gray)
                } else {
                    ForEach(fulfilledOrders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            orderRow(order: order)
                        }
                    }

                    .onDelete { offsets in
                        deleteOrders(offsets: offsets, from: fulfilledOrders)
                    }
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
    }

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


    private func deleteOrders(offsets: IndexSet, from list: [Order]) {
        for index in offsets {
            let order = list[index]
            viewContext.delete(order)
        }

        do {
            try viewContext.save()
        } catch {
            print("Fehler beim Löschen der Bestellung: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let customer = Customer(context: context)
    customer.name = "Max Mustermann"
    return CustomerDetailView(customer: customer)
        .environment(\.managedObjectContext, context)
}
