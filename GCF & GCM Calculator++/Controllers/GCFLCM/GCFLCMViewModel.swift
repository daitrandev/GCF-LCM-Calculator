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

protocol MainViewModelType {
    var inputText: String { get }
    var isPurchased: Bool { get }
    var delegate: GCFLCMViewModelDelegate? { get set }
    var cellLayoutItems: [GCFLCMViewModel.CellLayoutItem] { get }
    func clear()
    func didChange(inputString: String)
}

class GCFLCMViewModel: MainViewModelType {
    struct CellLayoutItem {
        let outputOption: OutputOption
        var content: String?
    }
    
    var inputText: String = "" {
        didSet {
            let inputNumbers = inputText
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            
            var cellLayoutItems = self.cellLayoutItems
            if inputNumbers.count > 1 {
                cellLayoutItems[0].content = CalculatorUtilities.GCF(stringNumbers: inputNumbers)
                cellLayoutItems[1].content = CalculatorUtilities.LCM(stringNumbers: inputNumbers)
            } else if inputNumbers.count > 0 {
                cellLayoutItems[0].content = inputNumbers[0]
                cellLayoutItems[1].content = inputNumbers[0]
            } else {
                cellLayoutItems[0].content = nil
                cellLayoutItems[1].content = nil
            }
            
            self.cellLayoutItems = cellLayoutItems
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
        inputText = ""
    }
    
    func didChange(inputString: String) {
        inputText = inputString
    }
}
