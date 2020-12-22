//
//  FactorsViewController.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 12/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class FactorsViewController: BaseViewController {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var outputTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    private let viewModel: FactorsViewModelType
    
    override init() {
        viewModel = FactorsViewModel()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isPurchased {
            removeAds()
            
            navigationItem.leftBarButtonItem = nil
            return
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "unlock"),
            style: .plain,
            target: self,
            action: #selector(didTapUnlock)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        inputTextField.attributedPlaceholder = NSAttributedString(
            string: "A positive number",
            attributes: [
                .foregroundColor: UIColor.lightGray
            ]
        )
        inputTextField.delegate = self
        inputTextField.addTarget(
            self,
            action: #selector(inputEditingChanged),
            for: .editingChanged
        )
        
        navigationController?.navigationBar.isTranslucent = false
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "refresh"),
            style: .plain,
            target: self,
            action: #selector(didTapRefresh)
        )
        
        if !viewModel.isPurchased {
            setupAds()
        }
        
        if #available(iOS 13, *) {
            navigationController?.navigationBar.barTintColor = .systemBackground
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont(name: "Roboto-Bold", size: 18) as Any
            ]
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont(name: "Roboto-Bold", size: 18) as Any
            ]
        }
        navigationController?.navigationBar.tintColor = .orange
        
        navigationItem.title = "Find Factors"
    }
    
    @objc func inputEditingChanged(_ sender: UITextField) {
        viewModel.didChange(input: sender.text)
    }
    
    @objc private func didTapRefresh() {
        inputTextField.text = nil
        viewModel.clear()
    }
    
    @objc private func didTapUnlock() {
        configureTabbar(isHidden: true)
        
        let vc = PurchasingPopupViewController()
        vc.delegate = self
        tabBarController?.present(vc, animated: true)
    }
    
    override func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        stackView.insertArrangedSubview(bannerView, at: 0)
    }
    
    override func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        // Do nothing
    }
}

extension FactorsViewController: PurchasingPopupViewControllerDelegate {
    func removeAds() {
        configureTabbar(isHidden: false)
        
        bannerView?.removeFromSuperview()
        navigationItem.leftBarButtonItem = nil
    }
    
    func didDismiss() {
        configureTabbar(isHidden: false)
    }
}

extension FactorsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let isNotNumber = string.first(where: { !$0.isNumber }) != nil
        return !isNotNumber
    }
}

extension FactorsViewController: FactorsViewModelDelegate {
    func update(output: String?) {
        placeholderLabel.isHidden = !output.isNilOrEmpty
        outputTextView.text = output
    }
}
