//
//  HomeViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import MessageUI

protocol HomeViewControllerDelegate:class {
    func loadColor()
}

class HomeViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var themeButton: UIButton!
    @IBOutlet weak var feedbackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    
    let mainBackgroundColor:[UIColor] = [UIColor.white, UIColor.black]
    
    let mainTintColorNavigationBar:[UIColor?] = [nil, UIColor.orange]
    
    weak var delegate: HomeViewControllerDelegate?
    
    var currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
    
    var labelArray:[UILabel?] = []
       
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIndex == 0 ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        labelArray = [themeLabel, feedbackLabel, rateLabel, shareLabel]
        
        themeLabel.text = NSLocalizedString("Theme", comment: "")
        feedbackLabel.text = NSLocalizedString("Feedback", comment: "")
        rateLabel.text = NSLocalizedString("Rate", comment: "")
        shareLabel.text = NSLocalizedString("Share", comment: "")
        
        loadColor()
        
        navigationController?.navigationBar.topItem?.title = NSLocalizedString("Home", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func OnThemeAction(_ sender: Any) {
        currentThemeIndex = 1 - currentThemeIndex
        UserDefaults.standard.setValue(currentThemeIndex, forKey: "ThemeIndex")
        loadColor()
    }
    
    @IBAction func OnDoneAction(_ sender: Any) {
        delegate?.loadColor()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnFeedbackAction(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["universappteam@gmail.com"])
        mailComposerVC.setSubject("[GCF&LCM-Calculator++ Feedback]")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnRateAction(_ sender: Any) {
        let appId = "id1304954640"
        rateApp(appId: appId) { success in
            print("RateApp \(success)")
        }
    }
    
    @IBAction func OnShareAction(_ sender: Any) {
        let appId = "id1304954640"
        let message: String = "https://itunes.apple.com/app/\(appId)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true)
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
    
    func loadColor() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        view.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        setNeedsStatusBarAppearanceUpdate()
        
        for i in 0..<labelArray.count {
            labelArray[i]?.textColor = mainBackgroundColor[1 - currentThemeIndex]
        }
        
        navigationController?.navigationBar.tintColor = UIColor.orange
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
