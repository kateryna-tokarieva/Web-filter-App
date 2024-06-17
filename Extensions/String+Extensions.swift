//
//  String+Extension.swift
//  WebsiteFilter
//
//  Created by Екатерина Токарева on 04/02/2023.
//

import Foundation

extension String {
    var isValidFilter: Bool {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        if self.count < 2 {
            return false
        }
        if let _ = self.rangeOfCharacter(from: whitespaceCharacterSet) {
            return false
        }
        return true
    }
    
    var isValidUrl: Bool {
        self.hasPrefix("http://") || self.hasPrefix("https://")
    }
}
