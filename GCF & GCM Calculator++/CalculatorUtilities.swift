//
//  CalculatorUtilities.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import Foundation

class CalculatorUtilities {
    
    static func GCF(number1: Int, number2: Int) -> Int {
        if (number1 == 0) {
            return number2
        } else if (number2 == 0) {
            return number1
        }
        
        return GCF(number1: number2, number2: number1 % number2)
    }
    
    static func LCM(number1: Int, number2: Int) -> Int? {        
        let gcf = GCF(number1: number1, number2: number2)
        
        if (gcf == 0) {
            return 0
        }
                
        return number2.multipliedReportingOverflow(by: number1 / gcf).overflow ? nil : (number1 / gcf) * number2
    }
    
    static func GCF(stringNumbers: [String]) -> String? {
        
        var gcf = 0
        
        var noNumberInStringNumbers: Bool = true
        
        for stringNum in stringNumbers {
            if (stringNum == "") {
                continue
            }
            
            guard let num = Int(stringNum) else { return nil }
            
            noNumberInStringNumbers = false
            
            gcf = GCF(number1: gcf, number2: num)
        }
        
        return noNumberInStringNumbers ? nil : String(gcf)
    }
    
    static func LCM(stringNumbers: [String]) -> String? {
        
        guard var lcm = Int(stringNumbers[0]) else { return nil }
        
        for i in 1..<stringNumbers.count {
            if (stringNumbers[i] == "") {
                continue
            }
            
            guard let num = Int(stringNumbers[i]) else { return nil }
            
            guard let LCM = LCM(number1: lcm, number2: num) else { return nil }
            
            lcm = LCM
        }
        
        return String(lcm)
    }
}
