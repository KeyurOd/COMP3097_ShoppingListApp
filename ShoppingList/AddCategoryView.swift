//
//  AddCategoryView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//
//   done by Keyur Odedara (101413667) &
//   Vatsal Prajapati (101414010)
//  Description: Here this view allows the user to add a new shopping category with a name and tax rate.

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var taxRate = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                    TextField("Tax Rate (%)", text: $taxRate)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                // Cancel and Save buttons
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveCategory() }
                        .disabled(name.isEmpty || taxRate.isEmpty)
                }
            }
        }
    }

    // It saves the new category into Core Data
    private func saveCategory() {
        let newCategory = Category(context: viewContext)
        newCategory.name = name
        newCategory.taxRate = Double(taxRate) ?? 0.0
        newCategory.totalItems = 0
        newCategory.totalPrice = 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save category: \(error)")
        }
    }
}
