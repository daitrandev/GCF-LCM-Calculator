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
    private let cellId = "cellId"
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(
            MainTableViewCell.self,
            forCellReuseIdentifier: cellId
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var bannerView: GADBannerView?
    
    private var interstitial: GADInterstitial?
    
    private var viewModel: MainViewModelType
    
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?) {
        viewModel = MainViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
    
    private func setupAds() {
        if !viewModel.isPurchased {
            bannerView = createAndLoadBannerAds()
            
            interstitial = createAndLoadInterstitial()
        }
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.constraintTo(
            top: view.layoutMarginsGuide.topAnchor,
            bottom: view.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor
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
                .font: UIFont(name: "Roboto-Bold", size: 18)!
            ]
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.black,
                .font: UIFont(name: "Roboto-Bold", size: 18)!
            ]
        }
        navigationController?.navigationBar.tintColor = UIColor.orange
    }
    
    @objc private func didTapUnlock() {
        let vc = PurchasingPopupViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc private func didTapRefresh() {
        viewModel.clear()
    }
}

extension MainViewController: PurchasingPopupViewControllerDelegate {
    func removeAds() {
        bannerView?.removeFromSuperview()
        tableView.tableHeaderView = nil
        navigationItem.leftBarButtonItem = nil
    }
}

extension MainViewController: MainViewModelDelegate {
    func reloadTableView() {
        for i in 0..<tableView.visibleCells.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
            cell.configure(with: viewModel.cellLayoutItems[indexPath.row])
        }
    }
}

extension MainViewController: MainTableViewCellDelegate {
    func presentCopiedAlert(message: String) {
        self.presentAlert(title: message, message: "", isUpgradeMessage: false)
    }
    
    func updateInput(inputTextFieldText: String, separatedString: String) {
        viewModel.update(
            inputTextFieldText: inputTextFieldText,
            separatedString: separatedString
        )
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellLayoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(
                withIdentifier: cellId,
                for: indexPath
            ) as? MainTableViewCell else {
                return UITableViewCell()
        }
        cell.configure(with: viewModel.cellLayoutItems[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
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
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: {(action) in
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
