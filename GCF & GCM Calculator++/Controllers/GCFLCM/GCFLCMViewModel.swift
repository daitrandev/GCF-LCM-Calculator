//
//  MainViewModel.swift
//  GCF & LCM Calculator
//
//  Created by Dai.Tran on 8/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

protocol GCFLCMViewModelDelegate: class, MessageDialogPresentable {
    func reloadTableView()
}

protocol GCFLCMViewModelType: class {
    var input: String? { get }
    var isPurchased: Bool { get }
    var delegate: GCFLCMViewModelDelegate? { get set }
    var cellLayoutItems: [GCFLCMViewModel.CellLayoutItem] { get }
    func clear()
    func didChange(inputString: String)
}

final class GCFLCMViewModel: GCFLCMViewModelType {
    struct CellLayoutItem {
        let outputOption: OutputOption
        var content: String?
    }
    
    var input: String? {
        didSet {
            guard let inputNumbers = input?
                    .components(separatedBy: .whitespaces)
                    .filter({ !$0.isEmpty }) else {
                cellLayoutItems[0].content = nil
                cellLayoutItems[1].content = nil
                return
            }
            
            if inputNumbers.count == 1 {
                cellLayoutItems[0].content = inputNumbers[0]
                cellLayoutItems[1].content = inputNumbers[0]
                return
            }
            
            cellLayoutItems[0].content = Calculator.GCF(stringNumbers: inputNumbers)
            cellLayoutItems[1].content = Calculator.LCM(stringNumbers: inputNumbers)
        }
    }
        
    var cellLayoutItems: [CellLayoutItem] {
        didSet {
            delegate?.reloadTableView()
        }
    }
    
    var isPurchased: Bool {
        GlobalKeychain.getBool(for: KeychainKey.isPurchased) ?? false
    }
    
    weak var delegate: GCFLCMViewModelDelegate?
    
    init() {
        cellLayoutItems = [
            CellLayoutItem(outputOption: .GCF),
            CellLayoutItem(outputOption: .LCM)
        ]
    }
    
    func clear() {
        input = nil
    }
    
    func didChange(inputString: String) {
        input = inputString
    }
}
