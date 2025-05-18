//
//  Page.swift
//  FarmerApp
//
//  Created by Aryan Mathur on 5/17/25.
//

import SwiftUI

enum Page: String, CaseIterable {
    case page1 = "calendar.badge.clock.rtl"
    case page2 = "pencil.tip"
    case page3 = "sparkles"
    case page4 = "person.2.fill"
    
    var title: String {
        switch self {
        case .page1: "Welcome to FutureFrame"
        case .page2: "Log hours"
        case .page3: "Synthesize"
        case .page4: "Join the Time Machine Revolution"
        }
    }
    
    var subTitle: String {
        switch self {
        case .page1: "The app that helps you reflect on your time"
        case .page2: "Log hours of Work, Social Media, Rest, etc. into your account."
        case .page3: "Smart suggestions based on user data in addition to future scenario generator"
        case .page4: "Join us and help save your time."
        }
    }
    
    var index: CGFloat {
        switch self {
        case .page1: 0
        case .page2: 1
        case .page3: 2
        case .page4: 3
        }
    }
    
    /// fetches the next page, if its not the last page
    var nextPage: Page {
        let index = Int(self.index) + 1
        if index < 4 {
            return Page.allCases[index]
        }
        
        return self
    }
    
    // Fetches the previous page, if its not the first page
    var previousPage: Page {
        let index = Int(self.index) - 1
        if index >= 0 {
            return Page.allCases[index]
        }
        
        return self
    }
}
