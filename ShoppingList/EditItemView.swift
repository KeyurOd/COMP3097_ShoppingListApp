//
//  EditItemView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var item: Item
    
    @State private var name: String
    @State private var price: String
    @State private var quantity: String

    init(item: Item) {
        self.item = item
        _name = State(initialValue: item.name ?? "")
        _price = State(initialValue: String(item.price))
        _quantity = State(initialValue: String(item.quantity))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Item Details")) {
                    TextField("Item Name", text: $name)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                        .disabled(name.isEmpty || price.isEmpty || quantity.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        item.name = name
        item.price = Double(price) ?? 0.0
        item.quantity = Int64(quantity) ?? 1
        item.totalPrice = (Double(price) ?? 0.0) * Double(Int32(quantity) ?? 1)

        updateCategoryTotals()

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    private func updateCategoryTotals() {
        let items = item.category?.items?.allObjects as? [Item] ?? []
        item.category?.totalItems = Int32(items.count)
        item.category?.totalPrice = items.reduce(0) { $0 + $1.totalPrice }

        do {
            try viewContext.save()
        } catch {
            print("Error updating category totals: \(error)")
        }
    }

}
