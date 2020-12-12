//
//  GCFLCMViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds

class GCFLCMViewController: UIViewController {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    private let cellId = "cellId"
    
    private var contentSizeObserver: NSKeyValueObservation?
    
    private var bannerView: GADBannerView?
    
    private var interstitial: GADInterstitial?
    
    private var viewModel: MainViewModelType
    
    init() {
        viewModel = GCFLCMViewModel()
        super.init(
            nibName: String(describing: GCFLCMViewController.self),
            bundle: .main
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        setupViews()
        loadTheme()
        setupAds()
        
        title = "GCF & LCM Calculator"
    }
    
    deinit {
        contentSizeObserver?.invalidate()
    }
    
    private func setupAds() {
        if !viewModel.isPurchased {
            bannerView = createAndLoadBannerAds()
            
            interstitial = createAndLoadInterstitial()
        }
    }
    
    private func setupViews() {
        tableView.register(
            UINib(nibName: String(describing: MainCell.self), bundle: .main),
            forCellReuseIdentifier: cellId
        )
        tableView.dataSource = self
        
        contentSizeObserver = tableView
            .observe(\.contentSize) { [weak self] (tableView, change) in
                self?.tableViewHeightConstraint.constant = tableView.contentSize.height
            }
        
        inputTextField.attributedPlaceholder = NSAttributedString(
            string: "Numbers seperate by spaces",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.lightGray
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
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "unlock"),
                style: .plain,
                target: self,
                action: #selector(didTapUnlock)
            )
        }
    }
    
    private func loadTheme() {
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
    }
    
    @objc private func didTapUnlock() {
        let vc = PurchasingPopupViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc private func didTapRefresh() {
        inputTextField.text = nil
        viewModel.clear()
    }
    
    @objc func inputEditingChanged(_ sender: UITextField) {
        viewModel.didChange(inputString: sender.text!)
    }
}

extension GCFLCMViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        
        if let lastCharacter = textField.text?.last,
            (string == " " && lastCharacter == " ") {
            return false
        }
        
        if string != " " && string.first(where: { !$0.isNumber }) != nil {
            return false
        }
        
        return true
    }
}

extension GCFLCMViewController: PurchasingPopupViewControllerDelegate {
    func removeAds() {
        bannerView?.removeFromSuperview()
        tableView.tableHeaderView = nil
        navigationItem.leftBarButtonItem = nil
    }
}

extension GCFLCMViewController: GCFLCMViewModelDelegate {
    func reloadTableView() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            let cell = cell as? MainCell
            cell?.configure(with: viewModel.cellLayoutItems[indexPath.row])
        }
    }
}

extension GCFLCMViewController: MainCellDelegate {
    func didTapCopy(content: String) {
        UIPasteboard.general.string = content
        showMessageDialog(
            title: "Success",
            message: "Copied",
            actionName: "Close",
            action: nil
        )
    }
}

extension GCFLCMViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellLayoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(
                withIdentifier: cellId,
                for: indexPath
            ) as? MainCell else {
                return UITableViewCell()
        }
        cell.configure(with: viewModel.cellLayoutItems[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    private func createAndLoadBannerAds() -> GADBannerView {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        bannerView.adUnitID = bannerAdsUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        return bannerView
    }
}

extension GCFLCMViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        stackView.insertArrangedSubview(bannerView, at: 0)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension GCFLCMViewController : GADInterstitialDelegate {
    private func createAndLoadInterstitial() -> GADInterstitial? {
        let interstitial = GADInterstitial(adUnitID: interstialAdsUnitID)
        
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
}
