//
//  T2GModel.swift
//  Table2GridConcept
//
//  Created by Michal Švácha on 20/03/15.
//  Copyright (c) 2015 Michal Švácha. All rights reserved.
//

import Foundation

class Model: NSObject {
    var data: [[String : String]] = []
    
    var count: Int {
        get {
            return self.data.count
        }
    }
    
    func sort() {
        let result = self.data.sorted {
            switch ($0["type"],$1["type"]) {
            case let (lhs,rhs) where lhs == rhs:
                return $0["name"] < $1["name"]
            case let (lhs, rhs):
                return lhs > rhs
            }
        }
        
        self.data = result
    }
    
    func setupDummyModel() {
        for index in 1...128 {
            var entry = [String : String]()
            let numberString = String(format: "%02d", index)
            entry["name"] = "Entry n. \(numberString)"
            entry["type"] = index % 4 == 0 ? "folder" : "file"
            self.data.append(entry)
        }
    }
}