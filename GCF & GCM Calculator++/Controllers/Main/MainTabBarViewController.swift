//
//  MainTabBarViewController.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 12/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .orange
        
        let gcfLcmNav = UINavigationController(rootViewController: GCFLCMViewController())
        gcfLcmNav.tabBarItem.title = "GCF & LCM"
        
        let factorsNav = UINavigationController(rootViewController: FactorsViewController())
        factorsNav.tabBarItem.title = "Factors"
        
        viewControllers = [gcfLcmNav, factorsNav]
    }
}
