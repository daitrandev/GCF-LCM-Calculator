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
    func updateInputText(inputTextFieldText: String, separatedString: String)
}

class MainTableViewCell: UITableViewCell {

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 5
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
        label.textAlignment = .center
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        let buttonImage = UserDefaults.standard.bool(forKey: isLightThemeKey) ? UIImage(named: "copy-blue") : UIImage(named: "copy-orange")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var separatedString: String = " "
    
    var cellModel: CellModel? {
        didSet {
            guard let cellModel = cellModel else { return }
            
            textField.placeholder = cellModel.textFieldPlaceHolder
            textField.keyboardAppearance = cellModel.isLightTheme ? .light : .dark
            textField.backgroundColor = cellModel.isEnabled ? .white : .gray
            textField.isEnabled = cellModel.isEnabled
            textField.text = cellModel.textFieldText
            textField.makeRound()
            
            label.text = cellModel.labelText
            label.backgroundColor = .orange
            label.makeRound()
        }
    }
    
    var delegate: MainTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(label)
        addSubview(textField)
        
        label.constraintTo(top: topAnchor, bottom: bottomAnchor, left: contentView.leftAnchor, right: nil, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        guard let isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool else { return }
        if !isFreeVersion {
            textField.constraintTo(top: topAnchor, bottom: bottomAnchor, left: label.rightAnchor, right: rightAnchor, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
        } else {
            addSubview(copyButton)
            
            textField.constraintTo(top: topAnchor, bottom: bottomAnchor, left: label.rightAnchor, right: copyButton.leftAnchor, topConstant: 8, bottomConstant: -8, leftConstant: 8, rightConstant: -8)
            
            copyButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
            copyButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
            copyButton.widthAnchor.constraint(equalTo: copyButton.heightAnchor).isActive = true
            copyButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        }
        
        textField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
        backgroundColor = .clear
    }
    
    @objc func didTapCopy() {
        if let textFieldText = textField.text {
            UIPasteboard.general.string = textFieldText
            delegate?.presentCopiedAlert(message: NSLocalizedString("Copied", comment: ""))
        } else {
            delegate?.presentCopiedAlert(message: NSLocalizedString("Nothing to copy", comment: ""))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        if (!sender.text!.contains(",") && !sender.text!.contains(" ")) {
            separatedString = ""
        }
        
        guard let inputTextFieldText = sender.text else { return }
        
        delegate?.updateInputText(inputTextFieldText: inputTextFieldText, separatedString: separatedString)
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
        } else if (string == "," && separatedString == " ") {
            return false
        } else if (string == " " || string == ",") {
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
