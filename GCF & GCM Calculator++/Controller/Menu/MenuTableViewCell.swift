//
//  MenuTableViewCell.swift
//  BaseConverter
//
//  Created by Macbook on 2/23/19.
//  Copyright © 2019 Dai Tran. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    var cellModel: Menu? {
        didSet {
            guard let cellModel = cellModel else { return }
            iconImageView.image = UIImage(named: cellModel.menuSection.rawValue)
            titleLabel.text = NSLocalizedString(cellModel.title, comment: "")
        }
    }
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isLightTheme: Bool? {
        didSet {
            guard let isLightTheme = isLightTheme else { return }
            titleLabel.textColor = isLightTheme ? .black : .white
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.constraintTo(top: contentView.topAnchor, bottom: nil, left: contentView.leftAnchor, right: nil, topConstant: 8, bottomConstant: 0, leftConstant: 8, rightConstant: 0)
        iconImageView.widthAnchor.constraint(equalToConstant: frame.height / 2).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor).isActive = true
        
        titleLabel.constraintTo(top: iconImageView.topAnchor, bottom: iconImageView.bottomAnchor, left: iconImageView.rightAnchor, right: rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 8, rightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
