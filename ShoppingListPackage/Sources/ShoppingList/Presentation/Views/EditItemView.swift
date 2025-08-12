import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var quantity: Int
    @State private var note: String
    @FocusState private var isNameFieldFocused: Bool
    
    private let originalItem: ShoppingItem
    private let onSave: (ShoppingItem) -> Void
    
    init(item: ShoppingItem, onSave: @escaping (ShoppingItem) -> Void) {
        self.originalItem = item
        self.onSave = onSave
        self._name = State(initialValue: item.name)
        self._quantity = State(initialValue: item.quantity)
        self._note = State(initialValue: item.note)
    }
    
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
                
                Section("Status") {
                    Toggle("Bought", isOn: .constant(originalItem.isBought))
                        .disabled(true)
                        .accessibilityLabel("Item status")
                        .accessibilityValue(originalItem.isBought ? "Bought" : "Not bought")
                }
                
                Section("Timestamps") {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(originalItem.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Created on \(originalItem.createdAt, style: .date)")
                    
                    HStack {
                        Text("Modified")
                        Spacer()
                        Text(originalItem.modifiedAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Last modified on \(originalItem.modifiedAt, style: .date)")
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel editing")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedItem = originalItem
                        updatedItem.updateContent(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            quantity: quantity,
                            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onSave(updatedItem)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hasNoChanges)
                    .accessibilityLabel("Save changes")
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }
    
    private var hasNoChanges: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedName == originalItem.name &&
               quantity == originalItem.quantity &&
               trimmedNote == originalItem.note
    }
}