//
//  ContentView.swift
//  iExpense
//
//  Created by Magomet Bekov on 10.10.2022.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

class Expenses: ObservableObject {
    var personalItems: [ExpenseItem] {
        items.filter { $0.type == "Personal"}
    }
    
    var businessItems: [ExpenseItem] {
        items.filter { $0.type == "Business"}
    }
    
    @Published var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ContentView: View {
    @StateObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            List {
                Section{
                    ForEach(expenses.personalItems) { item in
                        HStack {
                            Text(item.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                                .foregroundColor(item.amount < 10 ? .green : item.amount < 100 ? .yellow : .red)
                        }
                        
                    }
                    .onDelete(perform: removePersonalItems)
                    .accessibilityElement()
                    .accessibilityLabel("Book")
                    
                } header: {
                    Text("Personal")
                }
                Section{
                    ForEach(expenses.items.filter{$0.type == "Business"}) { item in
                        HStack {
                            Text(item.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                                .foregroundColor(item.amount < 10 ? .green : item.amount < 100 ? .yellow : .red)
                        }
                    }
                    .onDelete(perform: removeBusinessItems)
                    .accessibilityElement()
                    .accessibilityLabel("Book")
                } header: {
                    Text("Business")
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Book")
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }
    
        func removeItems(at offsets: IndexSet) {//        expenses.items.remove(atOffsets: offsets)
        }
    
    func removePersonalItems(at offsets: IndexSet) {
        //expenses.personalItems.remove(atOffsets: offsets)
        for offset in offsets{
            if let found = expenses.items.firstIndex(where: {$0.id == expenses.personalItems[offset].id}){
                expenses.items.remove(at: found)
            }
        }
    }
    
    func removeBusinessItems(at offsets: IndexSet) {
        for offset in offsets {
            if let found = expenses.items.firstIndex(where: {$0.id == expenses.businessItems[offset].id}) {
                expenses.items.remove(at: found)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
