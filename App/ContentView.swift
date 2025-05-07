import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Customer.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Customer.name, ascending: true)
        ]
    ) private var customers: FetchedResults<Customer>

    var body: some View {
        NavigationStack {
            List {
                ForEach(customers) { customer in
                    NavigationLink(destination: CustomerDetailView(customer: customer)) {
                        VStack(alignment: .leading) {
                            Text(customer.name ?? "Kein Name")
                                .font(.headline)
                            Text(customer.phone ?? "")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Kundenliste")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddCustomerView().environment(\.managedObjectContext, viewContext)) {
                        Label("Neuer Kunde", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
