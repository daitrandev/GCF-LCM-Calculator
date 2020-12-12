//
//  MainCell.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 8/15/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

protocol MainCellDelegate: class {
    func didTapCopy(content: String)
}

class MainCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var copyButton: UIButton!
    
    weak var delegate: MainCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.backgroundColor = .gray
        textField.isEnabled = false
        
        copyButton.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
    }
    
    func configure(with item: GCFLCMViewModel.CellLayoutItem) {
        titleLabel.text = item.outputOption.rawValue
        textField.attributedPlaceholder = NSAttributedString(
            string: item.outputOption.description,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
            ]
        )
        textField.text = item.content
    }
    
    @objc private func didTapCopy() {
        delegate?.didTapCopy(content: textField.text!)
    }
}
