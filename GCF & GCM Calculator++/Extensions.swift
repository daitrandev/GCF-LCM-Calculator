//
//  Extensions.swift
//  GCF & LCM Calculator
//
//  Created by Dai Tran on 9/21/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit

extension UIView {
    func constraintTo(top: NSLayoutYAxisAnchor?,
                      bottom: NSLayoutYAxisAnchor?,
                      left: NSLayoutXAxisAnchor?,
                      right: NSLayoutXAxisAnchor?,
                      topConstant: CGFloat = 0,
                      bottomConstant: CGFloat = 0,
                      leftConstant: CGFloat = 0,
                      rightConstant: CGFloat = 0) {
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topConstant).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: bottomConstant).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftConstant).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: rightConstant).isActive = true
        }
    }
}

extension UITextField {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.orange.cgColor
    }
}

extension UILabel {
    func makeRound() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
    }
}


extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
