import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = 1
    @State private var note = ""
    @FocusState private var isNameFieldFocused: Bool
    
    let onSave: (String, Int, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $name)
                        .focused($isNameFieldFocused)
                        .accessibilityLabel("Item name")
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                        .accessibilityLabel("Quantity")
                        .accessibilityValue("\(quantity)")
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .accessibilityLabel("Optional note")
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel adding item")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, quantity, note)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Save item")
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
}