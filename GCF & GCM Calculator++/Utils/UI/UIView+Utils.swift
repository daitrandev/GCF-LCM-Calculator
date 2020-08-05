//
//  UIView.swift
//  GCF & LCM Calculator
//
//  Created by Dai.Tran on 8/5/20.
//  Copyright © 2020 DaiTranDev. All rights reserved.
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

extension UIView {
    func set(borderColor: UIColor) {
        self.layer.borderColor = borderColor.cgColor
    }
}
