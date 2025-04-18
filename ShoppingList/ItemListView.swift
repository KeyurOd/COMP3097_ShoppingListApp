//
//  ItemListView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//
//  done by Vatsal Prajapati (101414010)
//  Description: Displays a list of items under a selected category, allows item editing/deleting, and shows summary.

import SwiftUI
import CoreData

struct ItemListView: View {
    var category: Category
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var items: FetchedResults<Item>

    @State private var showAddItem = false
    @State private var selectedItem: Item?

    init(category: Category) {
        self.category = category
        _items = FetchRequest(
            entity: Item.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
            predicate: NSPredicate(format: "category == %@", category)
        )
    }

    var body: some View {
        VStack {
            summaryView()
                .padding(.horizontal)

            List {
                ForEach(items) { item in
                    itemRow(item: item)
                        .swipeActions {
                            Button("Edit") {
                                selectedItem = item
                            }
                            .tint(.blue)

                            Button("Delete", role: .destructive) {
                                deleteItem(item)
                            }
                        }
                }
            }
        }
        .navigationTitle(category.name ?? "Items")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddItem.toggle() }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView(category: category)
        }
        .sheet(item: $selectedItem) { item in
            EditItemView(item: item)
        }
    }

    // This will show the total, tax, and number of items in this category
    private func summaryView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📋 Category Summary").font(.headline).padding(.bottom, 5)
            Text("Original Price: $\(originalPrice(), specifier: "%.2f")")
            Text("Total Tax: $\(totalTax(), specifier: "%.2f")")
            Text("Total Price: $\(totalPrice(), specifier: "%.2f")").foregroundColor(.blue)
            Text("Total Items: \(items.count)").foregroundColor(.gray)
        }
    }

    private func originalPrice() -> Double {
        return items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }

    private func totalTax() -> Double {
        return originalPrice() * (category.taxRate / 100)
    }

    private func totalPrice() -> Double {
        return originalPrice() + totalTax()
    }

    private func itemRow(item: Item) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name ?? "Unknown Item").font(.headline)
                Text("Price: $\(item.price, specifier: "%.2f") x \(item.quantity)").foregroundColor(.gray)
            }
            Spacer()
            Text("Total: $\(item.totalPrice, specifier: "%.2f")").foregroundColor(.blue)
        }
        .padding(.vertical, 6)
    }

    private func deleteItem(_ item: Item) {
        withAnimation {
            let category = item.category
            viewContext.delete(item)

            // category totals
            let items = category?.items?.allObjects as? [Item] ?? []
            category?.totalItems = Int32(items.count)
            category?.totalPrice = items.reduce(0) { $0 + $1.totalPrice }

            do {
                try viewContext.save()
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
}
