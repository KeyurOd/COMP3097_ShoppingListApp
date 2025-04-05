//
//  ExpenseSummaryView.swift
//  ShoppingList
//
//  Created by Keyur Odedara on 2025-02-12.
//
//  done by Vatsal Prajapati (101414010)
//  Description: Displays analytics- spending breakdown per category and highlights of max tax/spending using Charts.

import SwiftUI
import Charts
import CoreData

struct ExpenseSummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    spendingChart()
                        .padding()
                    highlightsSection()
                }
                .padding()
            }
            .navigationTitle("Expense Summary")
        }
    }

    // The bar chart will show total spent per category
    private func spendingChart() -> some View {
        VStack(alignment: .leading) {
            Text(" Spending Breakdown")
                .font(.headline)

            Chart(categories, id: \.self) { category in
                BarMark(
                    x: .value("Category", category.name ?? "Unknown"),
                    y: .value("Total Spent", category.totalPrice)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 200)
        }
    }

    // we will show the most expensive and highest-taxed categories
    private func highlightsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(" Highlights")
                .font(.headline)

            Text(" Most Expensive Category: \(mostExpensiveCategory()?.name ?? "N/A") ($\(mostExpensiveCategory()?.totalPrice ?? 0, specifier: "%.2f"))")
                .font(.subheadline)

            Text(" Highest Taxed Category: \(highestTaxCategory()?.name ?? "N/A") (\(highestTaxCategory()?.taxRate ?? 0, specifier: "%.2f")%)")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func mostExpensiveCategory() -> Category? {
        return categories.max(by: { $0.totalPrice < $1.totalPrice })
    }

    private func highestTaxCategory() -> Category? {
        return categories.max(by: { $0.taxRate < $1.taxRate })
    }
}
