//
//  AddItemView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var category: Category

    @State private var name = ""
    @State private var price = ""
    @State private var quantity = "1"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveItem() }
                        .disabled(name.isEmpty || price.isEmpty || quantity.isEmpty)
                }
            }
        }
    }

    private func saveItem() {
        let newItem = Item(context: viewContext)
        newItem.name = name
        newItem.price = Double(price) ?? 0.0
        newItem.quantity = Int64(quantity) ?? 1
        newItem.totalPrice = (Double(price) ?? 0.0) * Double(Int32(quantity) ?? 1)
        newItem.category = category
        
        updateCategoryTotals()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    private func updateCategoryTotals() {
        let items = category.items?.allObjects as? [Item] ?? []
        category.totalItems = Int32(items.count)
        category.totalPrice = items.reduce(0) { $0 + $1.totalPrice }

        do {
            try viewContext.save()
        } catch {
            print("Error updating category totals: \(error)")
        }
    }
}
