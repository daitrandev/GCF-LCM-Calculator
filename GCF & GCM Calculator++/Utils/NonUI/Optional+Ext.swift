//
//  Optional+Ext.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 13/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }
}
