//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Dennis Shar on 08/08/2022.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    // Decalare the view model here in order to make it run as soon as the app is up
    @StateObject var transactionsListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionsListVM)
        }
    }
}
