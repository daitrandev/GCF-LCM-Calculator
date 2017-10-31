//
//  MainViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let value = UserDefaults.standard.object(forKey: "ThemeIndex") as? Int {
            currentThemeIndex = value
        } else {
            UserDefaults.standard.set(1, forKey: "ThemeIndex")
        }
        
        loadColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        if (!sender.text!.characters.contains(",") && !sender.text!.characters.contains(" ")) {
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
        
        cell.tag = indexPath.row
        
        textFieldArray[indexPath.row] = cell.textField
        
        if (cell.tag == 0) {
            cell.textField.backgroundColor = UIColor.white
        } else {
            cell.textField.backgroundColor = UIColor.gray
        }
        
        return cell
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
        
        if (textField.tag == 1 || textField.tag == 2) {
            return false
        }
        
        for character in string.characters {
            if (!allowingCharacters.characters.contains(character)) {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MainViewController: HomeViewControllerDelegate {
    func loadColor() {
        currentThemeIndex = UserDefaults.standard.integer(forKey: "ThemeIndex")
        
        self.tableView.backgroundColor = mainBackgroundColor[currentThemeIndex]
        
        navigationController?.navigationBar.barTintColor = mainBackgroundColor[currentThemeIndex]
        navigationController?.navigationBar.tintColor = UIColor.orange
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: mainBackgroundColor[1 - currentThemeIndex]]
        
        if #available(iOS 11, *) {
            let attributes = [NSAttributedStringKey.foregroundColor : mainBackgroundColor[1 - currentThemeIndex]]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
        
        if (currentThemeIndex == 0) {
            UIApplication.shared.statusBarStyle = .default
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        tableView.reloadData()
    }
}
