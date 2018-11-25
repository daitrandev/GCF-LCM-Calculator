//
//  MainViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let textFieldPlaceHolder = [NSLocalizedString("InputPlaceHolder", comment: ""),
                                NSLocalizedString("GCFPlaceHolder", comment: ""),
                                NSLocalizedString("LCMPlaceHolder", comment: "")]
    
    let labelText = [NSLocalizedString("Input", comment: ""),
                     NSLocalizedString("GCF", comment: ""),
                     NSLocalizedString("LCM", comment: "")]
    
    let allowingCharacters = "0123456789"
    
    var textFieldArray: [UITextField?] = [UITextField?](repeating: nil, count: 3)
    
    var currentThemeIndex: Int = 0
    
    var seperateString: String = " "
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let keyboardAppearance: [UIKeyboardAppearance] = [UIKeyboardAppearance.light, UIKeyboardAppearance.dark]
    
    var bannerView: GADBannerView!
    
    var interstitial: GADInterstitial?
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        bannerView.adUnitID = "ca-app-pub-7005013141953077/2670035887"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        interstitial = createAndLoadInterstitial()
        
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if UserDefaults.standard.object(forKey: "ThemeIndex") == nil {
            UserDefaults.standard.set(0, forKey: "ThemeIndex")
        }
        
        loadColor()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("MainTitle", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showUpgradeMessageAlert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        if (!sender.text!.contains(",") && !sender.text!.contains(" ")) {
            seperateString = ""
        }
        
        let numbers = sender.text?.components(separatedBy: seperateString)
        
        textFieldArray[1]?.text = CalculatorUtilities.GCF(stringNumbers: numbers!)
        textFieldArray[2]?.text = CalculatorUtilities.LCM(stringNumbers: numbers!)
    }
    
    @IBAction func OnRefreshAction(_ sender: Any) {
        for i in 0..<textFieldArray.count {
            textFieldArray[i]?.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let homeVC = nav.topViewController as? HomeViewController {
            homeVC.delegate = self
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        cell.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        cell.textField.placeholder = textFieldPlaceHolder[indexPath.row]
        cell.textField.makeRound()
        cell.textField.addTarget(self, action: #selector(self.textFieldEditingChanged(_:)), for: .editingChanged)
        cell.textField.delegate = self
        cell.textField.keyboardAppearance = keyboardAppearance[currentThemeIndex]
        
        cell.label.text = labelText[indexPath.row]
        cell.label.backgroundColor = UIColor.orange
        cell.label.makeRound()
        
        cell.textField.tag = indexPath.row
        
        textFieldArray[indexPath.row] = cell.textField
        
        if (cell.textField.tag == 0) {
            cell.textField.backgroundColor = UIColor.white
        } else {
            cell.textField.backgroundColor = UIColor.gray
        }
        
        return cell
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.tag == 1 || textField.tag == 2) {
            return false
        }
        
        if (string == "") {
            return true
        }
        
        if (string == " " && seperateString == ",") {
            return false
        } else if (string == "," && seperateString == " ") {
            return false
        } else if (string == " " || string == ",") {
            seperateString = string
            return true
        }
        
        for character in string {
            if (!allowingCharacters.contains(character)) {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(action) in
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Upgarde", comment: ""), style: .default, handler: { (action) in
            self.setNeedsStatusBarAppearanceUpdate()
            self.rateApp(appId: "id1304954640", completion: { print("Rate app status: \($0)")})
        }))
        
        return alert
    }
    
    func showUpgradeMessageAlert() {
        let alert = createAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""))
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: HomeViewControllerDelegate {
    func loadColor() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        
        self.tableView.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        navigationController?.navigationBar.tintColor = UIColor.orange
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
        
        view.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        setNeedsStatusBarAppearanceUpdate()
        
        tableView.reloadData()
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
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-7005013141953077/6898368584")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        showUpgradeMessageAlert()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
