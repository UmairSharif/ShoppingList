import SwiftUI

public struct ShoppingListView: View {
    @StateObject private var viewModel: ShoppingListViewModel
    @State private var searchText: String = ""
    @State private var filterSegment: FilterSegment = .all
    
    private enum FilterSegment: Int, CaseIterable, Identifiable {
        case all
        case toBuy
        case bought
        
        var id: Int { rawValue }
        var title: String {
            switch self {
            case .all: return "All"
            case .toBuy: return "To Buy"
            case .bought: return "Bought"
            }
        }
    }
    
    public init(viewModel: ShoppingListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack { mainContent }
    }

    @ViewBuilder
    private var mainContent: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading items...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                quickFilterView
                contentListOrEmptyState
            }
        }
        .navigationTitle("Shopping List")
        .toolbarTitleMenu { toolbarTitleMenuContent }
        .toolbar { secondaryToolbar }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search items")
        .onChange(of: searchText) { newValue in
            Task { await viewModel.searchItems(query: newValue) }
        }
        .searchSuggestions { searchSuggestionsView }
        .sheet(isPresented: $viewModel.showingAddSheet) { addItemSheet }
        .sheet(isPresented: $viewModel.showingEditSheet) { editItemSheet }
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.dismissError() })) {
            Button("OK") { viewModel.dismissError() }
        } message: { Text(viewModel.errorMessage ?? "") }
        .background(backgroundView)
        .scrollContentBackground(.hidden)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: viewModel.filteredItems)
        .onAppear { onAppearActions() }
    }

    private var quickFilterView: some View {
        Picker("Filter", selection: $filterSegment) {
            ForEach(FilterSegment.allCases) { segment in
                Text(segment.title).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .onChange(of: filterSegment) { newValue in
            Task { await applySegment(newValue) }
        }
        .accessibilityLabel("Quick filter list")
    }

    @ViewBuilder
    private var contentListOrEmptyState: some View {
        if viewModel.filteredItems.isEmpty {
            EmptyStateView(
                hasItems: !viewModel.items.isEmpty,
                searchText: viewModel.filter.searchText
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            itemsListView
        }
    }

    private var itemsListView: some View {
        List {
            let toBuyItems = viewModel.filteredItems.filter { !$0.isBought }
            let boughtItems = viewModel.filteredItems.filter { $0.isBought }

            if !toBuyItems.isEmpty {
                Section("To Buy") {
                    ForEach(toBuyItems) { item in
                        ShoppingItemRow(
                            item: item,
                            onToggleBought: { Task { await viewModel.toggleItemBought(item) } },
                            onEdit: { viewModel.showEditSheet(for: item) },
                            onDelete: { Task { await viewModel.deleteItem(item) } }
                        )
                        .accessibilityIdentifier("shopping-item-\(item.id)")
                    }
                }
            }

            if !boughtItems.isEmpty {
                Section("Bought") {
                    ForEach(boughtItems) { item in
                        ShoppingItemRow(
                            item: item,
                            onToggleBought: { Task { await viewModel.toggleItemBought(item) } },
                            onEdit: { viewModel.showEditSheet(for: item) },
                            onDelete: { Task { await viewModel.deleteItem(item) } }
                        )
                        .accessibilityIdentifier("shopping-item-\(item.id)")
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.loadItems() }
    }

    @ViewBuilder
    private var toolbarTitleMenuContent: some View {
        Picker(
            "Sort by",
            selection: Binding(
                get: { viewModel.filter.sortOrder.rawValue },
                set: { newRaw in
                    Task {
                        var newFilter = viewModel.filter
                        newFilter.sortOrder = SortOrder(rawValue: newRaw) ?? newFilter.sortOrder
                        await viewModel.updateFilter(newFilter)
                    }
                }
            )
        ) {
            ForEach(SortOrder.allCases) { order in
                Text(order.displayName).tag(order.rawValue)
            }
        }

        Divider()

        Toggle(
            "Show To Buy",
            isOn: Binding(
                get: { viewModel.filter.showNotBought },
                set: { newValue in
                    Task {
                        var newFilter = viewModel.filter
                        newFilter.showNotBought = newValue
                        await viewModel.updateFilter(newFilter)
                        updateSegmentFromFilter()
                    }
                }
            )
        )

        Toggle(
            "Show Bought",
            isOn: Binding(
                get: { viewModel.filter.showBought },
                set: { newValue in
                    Task {
                        var newFilter = viewModel.filter
                        newFilter.showBought = newValue
                        await viewModel.updateFilter(newFilter)
                        updateSegmentFromFilter()
                    }
                }
            )
        )
    }

    private var secondaryToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button {
                viewModel.showAddSheet()
            } label: {
                Image(systemName: "plus").foregroundColor(.blue)
            }
            .accessibilityLabel("Add new item")

            if viewModel.isSyncing {
                ProgressView().scaleEffect(0.8)
            } else {
                Button {
                    Task { await viewModel.syncItems() }
                } label: {
                    Image(systemName: "arrow.clockwise").foregroundColor(.blue)
                }
                .accessibilityLabel("Sync items")
            }
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [Color(.systemGroupedBackground), Color(.secondarySystemGroupedBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var addItemSheet: some View {
        AddItemView { name, quantity, note in
            Task { await viewModel.addItem(name: name, quantity: quantity, note: note) }
        }
    }

    @ViewBuilder
    private var editItemSheet: some View {
        if let editingItem = viewModel.editingItem {
            EditItemView(item: editingItem) { updatedItem in
                Task { await viewModel.updateItem(updatedItem) }
            }
        }
    }

    private var searchSuggestionsView: some View {
        ForEach(searchSuggestions, id: \.self) { suggestion in
            Text(suggestion).searchCompletion(suggestion)
        }
    }

    // MARK: - Helpers
    private func applySegment(_ segment: FilterSegment) async {
        var newFilter = viewModel.filter
        switch segment {
        case .all:
            newFilter.showBought = true
            newFilter.showNotBought = true
        case .toBuy:
            newFilter.showBought = false
            newFilter.showNotBought = true
        case .bought:
            newFilter.showBought = true
            newFilter.showNotBought = false
        }
        await viewModel.updateFilter(newFilter)
    }

    private func updateSegmentFromFilter() {
        let showBought = viewModel.filter.showBought
        let showNotBought = viewModel.filter.showNotBought
        if showBought && showNotBought {
            filterSegment = .all
        } else if !showBought && showNotBought {
            filterSegment = .toBuy
        } else if showBought && !showNotBought {
            filterSegment = .bought
        } else {
            filterSegment = .all
            Task { await applySegment(.all) }
        }
    }

    private func onAppearActions() {
        if searchText.isEmpty {
            searchText = viewModel.filter.searchText
        }
        updateSegmentFromFilter()
    }

    private var searchSuggestions: [String] {
        let fromItems = viewModel.items.map { $0.name }
        let deduped = uniquePreservingOrder(fromItems)
        if searchText.isEmpty {
            return Array(deduped.prefix(6))
        } else {
            let matches = deduped.filter { $0.localizedCaseInsensitiveContains(searchText) }
            return Array(matches.prefix(6))
        }
    }

    private func uniquePreservingOrder(_ array: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for value in array {
            let key = value.lowercased()
            if !seen.contains(key) {
                seen.insert(key)
                result.append(value)
            }
        }
        return result
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search items...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Search shopping items")
        }
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    let hasItems: Bool
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasItems ? "magnifyingglass" : "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(hasItems ? "No items match your search" : "Your shopping list is empty")
                .font(.headline)
                .foregroundColor(.gray)
            
            if !hasItems {
                Text("Tap the + button to add your first item")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
