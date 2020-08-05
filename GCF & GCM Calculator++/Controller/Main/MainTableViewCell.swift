//
//  MainTableViewCell.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: class {
    func presentCopiedAlert(message: String)
    func updateInput(inputTextFieldText: String, separatedString: String)
}

class MainTableViewCell: UITableViewCell {

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
        textField.set(borderColor: UIColor.orange)
        textField.textAlignment = .center
        textField.layer.masksToBounds = true
        textField.returnKeyType = .done
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .orange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        let buttonImage = UIImage(named: "copy-orange")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var separatedString: String = " "
    
    private var item: MainViewModel.CellLayoutItem? {
        didSet {
            guard let item = item else { return }
            
            textField.placeholder = item.textFieldPlaceHolder
            textField.backgroundColor = item.isEnabled ? .white : .gray
            textField.isEnabled = item.isEnabled
            textField.text = item.textFieldText
            
            label.text = item.labelText
        }
    }
    
    var delegate: MainTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        addSubview(textField)
        
        label.constraintTo(top: topAnchor, bottom: nil, left: contentView.leftAnchor, right: nil, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        addSubview(copyButton)
        
        textField.constraintTo(top: label.bottomAnchor, bottom: bottomAnchor, left: contentView.leftAnchor, right: copyButton.leftAnchor, topConstant: 0, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
        
        copyButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        copyButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
        copyButton.widthAnchor.constraint(equalTo: copyButton.heightAnchor).isActive = true
        copyButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        textField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    func configure(with item: MainViewModel.CellLayoutItem) {
        self.item = item
    }
    
    @objc func didTapCopy() {
        UIPasteboard.general.string = textField.text!
        delegate?.presentCopiedAlert(message: "Copied")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        if (!sender.text!.contains(",") && !sender.text!.contains(" ")) {
            separatedString = ""
        }
        
        guard let inputTextFieldText = sender.text else { return }
        delegate?.updateInput(
            inputTextFieldText: inputTextFieldText,
            separatedString: separatedString
        )
    }
}

extension MainTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.tag == 1 || textField.tag == 2) {
            return false
        }
        
        if (string == "") {
            return true
        }
        
        if (string == " " && separatedString == ",") {
            return false
        }
        
        if (string == "," && separatedString == " ") {
            return false
        }
        
        if (string == " " || string == ",") {
            separatedString = string
            return true
        }
        
        for character in string {
            if (!"0123456789".contains(character)) {
                return false
            }
        }
        
        return true
    }
}
