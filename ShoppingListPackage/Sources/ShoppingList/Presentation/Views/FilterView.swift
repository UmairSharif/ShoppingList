import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBought: Bool
    @State private var showNotBought: Bool
    @State private var sortOrder: SortOrder
    
    private let originalFilter: ShoppingListFilter
    private let onSave: (ShoppingListFilter) -> Void
    
    init(filter: ShoppingListFilter, onSave: @escaping (ShoppingListFilter) -> Void) {
        self.originalFilter = filter
        self.onSave = onSave
        self._showBought = State(initialValue: filter.showBought)
        self._showNotBought = State(initialValue: filter.showNotBought)
        self._sortOrder = State(initialValue: filter.sortOrder)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Show Items") {
                    Toggle("Bought Items", isOn: $showBought)
                        .accessibilityLabel("Show bought items")
                    
                    Toggle("Not Bought Items", isOn: $showNotBought)
                        .accessibilityLabel("Show not bought items")
                    
                    if !showBought && !showNotBought {
                        Text("At least one option must be selected")
                            .font(.caption)
                            .foregroundColor(.red)
                            .accessibilityLabel("Warning: At least one option must be selected")
                    }
                }
                
                Section("Sort Order") {
                    Picker("Sort by", selection: $sortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            Text(order.displayName)
                                .tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("Sort order")
                }
                
                Section("Current Search") {
                    if originalFilter.searchText.isEmpty {
                        Text("No active search")
                            .foregroundColor(.secondary)
                            .accessibilityLabel("No active search filter")
                    } else {
                        HStack {
                            Text("Searching for:")
                            Spacer()
                            Text("\"\(originalFilter.searchText)\"")
                                .foregroundColor(.blue)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Currently searching for \(originalFilter.searchText)")
                        
                        Text("Clear the search bar to see all items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Tip: Clear the search bar to see all items")
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel filter changes")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        var newFilter = originalFilter
                        newFilter.showBought = showBought
                        newFilter.showNotBought = showNotBought
                        newFilter.sortOrder = sortOrder
                        onSave(newFilter)
                        dismiss()
                    }
                    .disabled(!showBought && !showNotBought)
                    .accessibilityLabel("Apply filter changes")
                }
            }
        }
    }
}