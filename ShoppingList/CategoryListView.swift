//
//  CategoryListView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//

import SwiftUI
import CoreData

struct CategoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    @State private var showAddCategory = false
    @State private var selectedCategory: Category?
    @State private var showEditCategory = false

    var body: some View {
        NavigationView {
            VStack {
                
                summaryView()
                    .padding(.horizontal)

                List {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: ItemListView(category: category)) {
                            categoryRow(category: category)
                        }
                        .swipeActions {
                            Button("Edit") {
                                selectedCategory = category
                            }
                            .tint(.blue)

                            Button("Delete", role: .destructive) {
                                deleteCategoryByID(category)
                            }
                        }
                    }
                    .onDelete(perform: deleteCategory)
                }

                .listStyle(PlainListStyle())
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory.toggle() }) {
                        Label("Add Category", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ExpenseSummaryView()) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                    }
                }

            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView()
            }
            .sheet(item: $selectedCategory) { category in
                EditCategoryView(category: category)
            }

        }
    }

    private func summaryView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📊 Summary")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text("Original Price: $\(originalPrice(), specifier: "%.2f")")
                .font(.subheadline)
            Text("Total Tax: $\(totalTax(), specifier: "%.2f")")
                .font(.subheadline)
            Text("Total Price: $\(totalPrice(), specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.blue)
            Text("Total Items: \(totalItems())")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5)
    }

    private func originalPrice() -> Double {
        return categories.reduce(0) { total, category in
            let categoryOriginalPrice = category.items?.allObjects
                .compactMap { ($0 as? Item)?.price ?? 0.0 * Double(($0 as? Item)?.quantity ?? 1) }
                .reduce(0, +) ?? 0.0
            return total + categoryOriginalPrice
        }
    }

    private func totalTax() -> Double {
        return categories.reduce(0) { total, category in
            let categoryTax = originalPrice() * (category.taxRate / 100)
            return total + categoryTax
        }
    }

    private func totalPrice() -> Double {
        return originalPrice() + totalTax()
    }


    private func totalItems() -> Int {
        return categories.reduce(0) { $0 + Int($1.totalItems) }
    }

    private func categoryRow(category: Category) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(category.name ?? "Unknown Category")
                    .font(.headline)
                Text("Tax: \(category.taxRate, specifier: "%.2f")%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Total Price: $\(category.totalPrice, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            Spacer()
            Text("\(category.totalItems) Items")
                .font(.subheadline)
                .padding(5)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(5)
        }
        .padding(.vertical, 6)
    }
    private func deleteCategoryByID(_ category: Category) {
        withAnimation {
            viewContext.delete(category)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }

    private func deleteCategory(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach { category in
                viewContext.delete(category)
            }

            do {
                try viewContext.save()
            } catch {
                print("Error deleting category: \(error)")
            }
        }
    }
}
