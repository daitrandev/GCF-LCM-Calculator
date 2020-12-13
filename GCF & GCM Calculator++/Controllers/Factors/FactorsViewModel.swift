//
//  FactorsViewModel.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 12/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

protocol FactorsViewModelDelegate: class {
    func update(output: String?)
}

protocol FactorsViewModelType: class {
    var isPurchased: Bool { get }
    var delegate: FactorsViewModelDelegate? { get set }
    func clear()
    func didChange(input: String?)
}

final class FactorsViewModel: FactorsViewModelType {
    private var input: String? {
        didSet {
            guard let input = input,
                  let inputNumber = UInt(input) else {
                output = nil
                return
            }
            output = Calculator.factors(of: inputNumber)
                .map { String($0) }
                .joined(separator: " ")
        }
    }
    
    private var output: String? {
        didSet {
            delegate?.update(output: output)
        }
    }
    
    var isPurchased: Bool {
        GlobalKeychain.getBool(for: KeychainKey.isPurchased) ?? false
    }
        
    weak var delegate: FactorsViewModelDelegate?
    
    func didChange(input: String?) {
        self.input = input
    }
    
    func clear() {
        input = nil
    }
}
