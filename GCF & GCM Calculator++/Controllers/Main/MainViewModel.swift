//
//  MainViewModel.swift
//  GCF & LCM Calculator
//
//  Created by Dai.Tran on 8/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

protocol MainViewModelDelegate: class, MessageDialogPresentable {
    func reloadTableView()
}

protocol MainViewModelType {
    var inputText: String { get }
    var separator: String { get set }
    var isPurchased: Bool { get }
    var delegate: MainViewModelDelegate? { get set }
    var cellLayoutItems: [MainViewModel.CellLayoutItem] { get }
    func clear()
    func didChange(inputString: String)
}

class MainViewModel: MainViewModelType {
    struct CellLayoutItem {
        let outputOption: OutputOption
        var content: String?
    }
    
    var inputText: String = "" {
        didSet {
            let inputNumbers = inputText
                .components(separatedBy: separator)
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
    
    var separator: String = ""
    
    var cellLayoutItems: [CellLayoutItem] {
        didSet {
            delegate?.reloadTableView()
        }
    }
    
    var isPurchased: Bool {
        GlobalKeychain.getBool(for: KeychainKey.isPurchased) ?? false
    }
    
    weak var delegate: MainViewModelDelegate?
    
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
