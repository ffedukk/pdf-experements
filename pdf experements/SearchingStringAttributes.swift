//
//  SearchingStringRepresentation.swift
//  pdf experements
//
//  Created by 18592232 on 18.12.2020.
//

import Foundation

class SearchingStringAttributes {
    let weight: Float
    var ranges: [NSRange]?
    
    init(weight: Float) {
        self.weight = weight
    }
    
    func setHighlightRanges(_ ranges: [NSRange]) {
        self.ranges = ranges
    }
}
