import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let onToggleBought: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggleBought) {
                Image(systemName: item.isBought ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isBought ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isBought ? "Mark as not bought" : "Mark as bought")
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.headline)
                        .strikethrough(item.isBought)
                        .foregroundColor(item.isBought ? .secondary : .primary)
                    
                    Spacer()
                    
                    if item.quantity > 1 {
                        Text("×\(item.quantity)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("Created: \(item.createdAt, style: .date)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    SyncStatusIndicator(status: item.syncStatus)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onToggleBought) {
                Label(
                    item.isBought ? "Mark as Not Bought" : "Mark as Bought",
                    systemImage: item.isBought ? "circle" : "checkmark.circle"
                )
            }
            
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundColor(.red)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .tint(.red)
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button(action: onToggleBought) {
                Image(systemName: item.isBought ? "circle" : "checkmark.circle")
            }
            .tint(item.isBought ? .orange : .green)
        }
    }
}

struct SyncStatusIndicator: View {
    let status: SyncStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .synced:
            return .green
        case .syncing:
            return .blue
        case .notSynced:
            return .orange
        case .failed:
            return .red
        }
    }
    
    private var statusText: String {
        switch status {
        case .synced:
            return "Synced"
        case .syncing:
            return "Syncing"
        case .notSynced:
            return "Not Synced"
        case .failed:
            return "Sync Failed"
        }
    }
}