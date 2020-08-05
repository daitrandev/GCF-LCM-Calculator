//
//  MainViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds

class MainViewController: UIViewController {
    
    let cellId = "cellId"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var cellModels = [
        CellModel(labelText: NSLocalizedString("Input", comment: ""), textFieldText: nil, textFieldPlaceHolder: NSLocalizedString("InputPlaceHolder", comment: ""), isLightTheme: isLightTheme, isEnabled: true),
        CellModel(labelText: NSLocalizedString("GCF", comment: ""), textFieldText: nil, textFieldPlaceHolder: NSLocalizedString("GCFPlaceHolder", comment: ""), isLightTheme: isLightTheme, isEnabled: false),
        CellModel(labelText: NSLocalizedString("LCM", comment: ""), textFieldText: nil, textFieldPlaceHolder: NSLocalizedString("LCMPlaceHolder", comment: ""), isLightTheme: isLightTheme, isEnabled: false)
    ]
    
    let isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true
        
    var isLightTheme: Bool = {
        if let isLightTheme = UserDefaults.standard.object(forKey: isLightThemeKey) as? Bool {
            return isLightTheme
        }
        UserDefaults.standard.set(true, forKey: isLightThemeKey)
        return true
    }()
    
    var bannerView: GADBannerView?
    
    var interstitial: GADInterstitial?
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.constraintTo(top: view.layoutMarginsGuide.topAnchor, bottom: view.layoutMarginsGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
        
        loadColor(isLightTheme: isLightTheme)
        
        if isFreeVersion {
            setupAds()
        }
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("MainTitle", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(didTapRefresh))
    }
    
    private func setupAds() {
        bannerView = createAndLoadBannerAds()
        
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFreeVersion {
            presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
        }
    }
    
    private func loadColor(isLightTheme: Bool) {
        navigationController?.navigationBar.barTintColor = isLightTheme ? .white : .black
        navigationController?.navigationBar.tintColor = UIColor.orange
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        
        view.backgroundColor = isLightTheme ? .white : .black
        
        setNeedsStatusBarAppearanceUpdate()
        
        tableView.reloadData()
    }
    
    @objc private func didTapRefresh() {
        for i in 0..<cellModels.count {
            cellModels[i].textFieldText = nil
        }
        updateCellTextField()
    }
    
    private func updateCellTextField() {
        for i in 0..<tableView.visibleCells.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
            cell.cellModel = cellModels[i]
        }
    }
}

extension MainViewController: MainTableViewCellDelegate {
    func presentCopiedAlert(message: String) {
        self.presentAlert(title: message, message: "", isUpgradeMessage: false)
    }
    
    func updateInputText(inputTextFieldText: String, separatedString: String) {
        let stringNumbers = inputTextFieldText.components(separatedBy: separatedString)
        
        cellModels[0].textFieldText = inputTextFieldText
        cellModels[1].textFieldText = CalculatorUtilities.GCF(stringNumbers: stringNumbers)
        cellModels[2].textFieldText = CalculatorUtilities.LCM(stringNumbers: stringNumbers)
        
        updateCellTextField()
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainTableViewCell
        cell.cellModel = cellModels[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func presentAlert(title: String, message: String, isUpgradeMessage: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: {(action) in
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension MainViewController : GADInterstitialDelegate {
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
