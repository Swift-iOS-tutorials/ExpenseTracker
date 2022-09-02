//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Dennis Shar on 27/08/2022.
//

import Foundation
import Combine
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String,Double)]



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
    
    func accumulateTransactions() -> TransactionPrefixSum{
        guard !transactions.isEmpty else { return [] }// if emtpy return empty dic
        
        let today = "02/17/2022".dateParssed()
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        
        var sum: Double = .zero
        var accumulatedSum = TransactionPrefixSum()
        
        for date in stride(from: dateInterval.start, to: today, by: 60*60*24){
            let dailyExpences = transactions.filter {$0.dateParsed == date && $0.isExpense}
            let dailyTotal = dailyExpences.reduce(0) {$0 - $1.signedAmount}
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            accumulatedSum.append((date.formatted(),sum))
        }
        return accumulatedSum
    }
}
