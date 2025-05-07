import SwiftUI

struct AddCustomerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var notes = ""

    var body: some View {
        Form {
            Section(header: Text("Kundendaten")) {
                TextField("Name", text: $name)
                TextField("Telefonnummer", text: $phone)
                TextField("E-Mail", text: $email)
                TextField("Notizen", text: $notes)
            }

            Button(action: addCustomer) {
                Text("Kunde speichern")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Neuer Kunde")
    }

    private func addCustomer() {
        let newCustomer = Customer(context: viewContext)
        newCustomer.name = name
        newCustomer.phone = phone
        newCustomer.email = email
        newCustomer.notes = notes
        newCustomer.noShowCount = 0

        do {
            try viewContext.save()
            print("Kunde gespeichert!")
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddCustomerView()
}
