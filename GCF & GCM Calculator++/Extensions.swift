//
//  Extensions.swift
//  GCF & LCM Calculator
//
//  Created by Dai Tran on 9/21/18.
//  Copyright © 2018 DaiTranDev. All rights reserved.
//

import UIKit

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
        return visibleViewController
    }
}
