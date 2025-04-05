//
//  EditCategoryView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//
//  done by Keyur Odedara (101413667) &
//  Vatsal Prajapati (101414010)
//  Description: This view allows users to edit a selected shopping category’s name and tax rate.

import SwiftUI

struct EditCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var category: Category

    @State private var name: String
    @State private var taxRate: String

    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name ?? "")
        _taxRate = State(initialValue: String(format: "%.2f", category.taxRate))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Category Details")) {
                    TextField("Category Name", text: $name)
                    TextField("Tax Rate (%)", text: $taxRate)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveChanges() }
                        .disabled(name.isEmpty || taxRate.isEmpty)
                }
            }
        }
    }

    // we will save updated name and tax rate for this category
    private func saveChanges() {
        category.name = name
        category.taxRate = Double(taxRate) ?? 0.0

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save category: \(error)")
        }
    }
}
