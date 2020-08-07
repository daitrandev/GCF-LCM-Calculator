//
//  MainViewModel.swift
//  GCF & LCM Calculator
//
//  Created by Dai.Tran on 8/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

protocol MainViewModelDelegate: class {
    func reloadTableView()
}

protocol MainViewModelType {
    var isPurchased: Bool { get }
    var delegate: MainViewModelDelegate? { get set }
    var cellLayoutItems: [MainViewModel.CellLayoutItem] { get }
    func clear()
    func update(inputTextFieldText: String, separatedString: String)
}

class MainViewModel: MainViewModelType {
    struct CellLayoutItem {
        let labelText: String
        var textFieldText: String?
        let textFieldPlaceHolder: String
        let isEnabled: Bool
    }
    
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
            CellLayoutItem(
                labelText: "INPUT",
                textFieldText: nil,
                textFieldPlaceHolder: "Numbers seperate by spaces or commas",
                isEnabled: true
            ),
            CellLayoutItem(
                labelText: "GCF",
                textFieldText: nil,
                textFieldPlaceHolder: "Greatest common factor",
                isEnabled: false
            ),
            CellLayoutItem(
                labelText: "LCM",
                textFieldText: nil,
                textFieldPlaceHolder: "Least common multiple",
                isEnabled: false
            )
        ]
    }
    
    func clear() {
        for index in 0..<cellLayoutItems.count {
            cellLayoutItems[index].textFieldText = nil
        }
    }
    
    func update(inputTextFieldText: String, separatedString: String) {
        cellLayoutItems[0].textFieldText = inputTextFieldText
        
        let inputNumbers = inputTextFieldText.components(separatedBy: separatedString)
            .filter { !$0.isEmpty }
        
        var cellLayoutItems = self.cellLayoutItems
        if inputNumbers.count >= 2 {
            cellLayoutItems[1].textFieldText = CalculatorUtilities.GCF(stringNumbers: inputNumbers)
            cellLayoutItems[2].textFieldText = CalculatorUtilities.LCM(stringNumbers: inputNumbers)
        } else {
            cellLayoutItems[1].textFieldText = nil
            cellLayoutItems[2].textFieldText = nil
        }
        
        self.cellLayoutItems = cellLayoutItems
    }
}
