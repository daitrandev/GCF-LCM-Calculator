//
//  FactorsViewModel.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 12/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

protocol FactorsViewModelType: class {
    func clear()
    func didChange(input: String)
}

final class FactorsViewModel: FactorsViewModelType {
    private var input: String?
    private var output: String?
        
    weak var delegate: GCFLCMViewModelDelegate?
    
    func clear() {
        
    }
    
    func didChange(input: String) {
        
    }
}
