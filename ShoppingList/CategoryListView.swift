//
//  CategoryListView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-11.
//
//  done by Keyur Odedara (101413667)
//  Description: Shows a list of all categories, allows adding/editing/deleting, and displays a summary of expenses.

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

    // total calculations across all categories is showed
    private func summaryView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(" Summary").font(.headline).padding(.bottom, 5)
            Text("Original Price: $\(originalPrice(), specifier: "%.2f")")
            Text("Total Tax: $\(totalTax(), specifier: "%.2f")")
            Text("Total Price: $\(totalPrice(), specifier: "%.2f")").foregroundColor(.blue)
            Text("Total Items: \(totalItems())").foregroundColor(.gray)
        }
    }

    // helpful for calculations
    private func originalPrice() -> Double {
        return categories.reduce(0) { total, category in
            let items = category.items?.allObjects as? [Item] ?? []
            return total + items.reduce(0) { $0 + $1.price * Double($1.quantity) }
        }
    }

    private func totalTax() -> Double {
        return categories.reduce(0) { total, category in
            let catTotal = category.items?.allObjects as? [Item] ?? []
            let catPrice = catTotal.reduce(0) { $0 + $1.price * Double($1.quantity) }
            return total + (catPrice * (category.taxRate / 100))
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
                Text(category.name ?? "Unknown Category").font(.headline)
                Text("Tax: \(category.taxRate, specifier: "%.2f")%").foregroundColor(.gray)
                Text("Total Price: $\(category.totalPrice, specifier: "%.2f")").foregroundColor(.blue)
            }
            Spacer()
            Text("\(category.totalItems) Items")
                .padding(5)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(5)
        }
    }

    private func deleteCategoryByID(_ category: Category) {
        withAnimation {
            viewContext.delete(category)
            try? viewContext.save()
        }
    }

    private func deleteCategory(offsets: IndexSet) {
        withAnimation {
            offsets.map { categories[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
}
