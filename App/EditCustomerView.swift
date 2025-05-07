import SwiftUI

struct EditCustomerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var customer: Customer

    @State private var name: String
    @State private var phone: String
    @State private var email: String
    @State private var notes: String

    init(customer: Customer) {
        self.customer = customer
        _name = State(initialValue: customer.name ?? "")
        _phone = State(initialValue: customer.phone ?? "")
        _email = State(initialValue: customer.email ?? "")
        _notes = State(initialValue: customer.notes ?? "")
    }

    var body: some View {
        Form {
            Section(header: Text("Kundendaten bearbeiten")) {
                TextField("Name", text: $name)
                TextField("Telefonnummer", text: $phone)
                TextField("E-Mail", text: $email)
                TextField("Notizen", text: $notes)
            }

            Button(action: saveChanges) {
                Text("Änderungen speichern")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Kunde bearbeiten")
    }

    private func saveChanges() {
        customer.name = name
        customer.phone = phone
        customer.email = email
        customer.notes = notes

        do {
            try viewContext.save()
            print("Änderungen gespeichert!")
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let customer = Customer(context: context)
    customer.name = "Testkunde"
    return EditCustomerView(customer: customer)
        .environment(\.managedObjectContext, context)
}
