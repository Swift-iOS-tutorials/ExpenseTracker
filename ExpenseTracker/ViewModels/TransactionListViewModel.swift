//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Dennis Shar on 27/08/2022.
//

import Foundation
import Combine

typealias TransactionGroup = [String: [Transaction]]



// Observable object turn every class into a pblisher and can notify about chnages in it to the view
final class TransactionListViewModel: ObservableObject{
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init (){
        getTrabsactions()
    }
    
    func getTrabsactions(){
        guard let url = URL (string: "https://designcode.io/data/transactions.json") else {
            print ("Invalid url")
            return
        
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, responce) -> Data in
                guard let httpResponce = responce as? HTTPURLResponse, httpResponce.statusCode == 200 else {
                    dump(responce)
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching transactions:", error.localizedDescription)
                case .finished:
                    print("Finished fetching transaction")
                }
            } receiveValue: { [weak self] result in
                self?.transactions = result
                dump(self?.transactions) // dup is same as print 
            }
            .store(in: &cancellables)

    }
    
    func groupTransactionByMOnth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] }// if emtpy return empty dic
        
        let groupedTransactions = TransactionGroup(grouping: transactions)  { $0.month }
        return groupedTransactions
   }
}
