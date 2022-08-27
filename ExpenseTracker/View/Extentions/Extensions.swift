//
//  Extensions.swift
//  ExpenseTracker
//
//  Created by Dennis Shar on 08/08/2022.
//

import Foundation
import SwiftUI

extension Color {
    static let background = Color("Background")
    static let icon = Color("Icon")
    static let text = Color("Text")
    static let systemBackground = Color(uiColor: .systemBackground)
}

extension DateFormatter {
    static let allNumericUSA: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        
        return formater
    }()
}

extension String {
    func dateParssed () -> Date {
        guard let parsedDate = DateFormatter.allNumericUSA.date(from: self) else {return Date()}
        return parsedDate
    }
}
