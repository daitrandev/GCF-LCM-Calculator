//
//  OutputOption.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 8/15/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

enum OutputOption: String {
    case GCF
    case LCM
    
    var description: String {
        switch self {
        case .GCF:
            return "Greatest Common Factor"
            
        case .LCM:
            return "Least Common Muptiple"
        }
    }
}
