//
//  BaseViewController.swift
//  GCF & LCM Calculator
//
//  Created by DaiTran on 12/12/2020.
//  Copyright © 2020 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BaseViewController: UIViewController {
    var bannerView: GADBannerView?
    var interstitial: GADInterstitial?
    
    init() {
        super.init(
            nibName: String(describing: type(of: self)),
            bundle: .main
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAds() {
        bannerView = createAndLoadBannerAds()
        interstitial = createAndLoadInterstitial()
    }
    
    func configureTabbar(isHidden: Bool) {
        if isHidden {
            tabBarController?.tabBar.layer.zPosition = -1
            tabBarController?.tabBar.isUserInteractionEnabled = false
            return
        }
        tabBarController?.tabBar.layer.zPosition = 0
        tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    private func createAndLoadBannerAds() -> GADBannerView {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        bannerView.adUnitID = bannerAdsUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        return bannerView
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        let interstitial = GADInterstitial(adUnitID: interstialAdsUnitID)
        
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
}

extension BaseViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension BaseViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
}
