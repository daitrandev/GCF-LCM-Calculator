//
//  GCFLCMViewController.swift
//  GCF & GCM Calculator++
//
//  Created by Dai Tran on 10/30/17.
//  Copyright © 2017 DaiTranDev. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class GCFLCMViewController: BaseViewController {
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    private let cellId = "cellId"
    
    private var contentSizeObserver: NSKeyValueObservation?
    
    private var viewModel: GCFLCMViewModelType
    
    override init() {
        viewModel = GCFLCMViewModel()
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
        
        setupViews()
        loadTheme()
        
        if !viewModel.isPurchased {
            setupAds()
        }
        
        navigationItem.title = "GCF & LCM Calculator"
        navigationController?.tabBarItem.title = "GCF & LCM"
    }
    
    deinit {
        contentSizeObserver?.invalidate()
    }
    
    private func setupViews() {
        tableView.register(
            UINib(nibName: String(describing: OutputCell.self), bundle: .main),
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
        configureTabbar(isHidden: true)
        
        let vc = PurchasingPopupViewController()
        vc.delegate = self
        tabBarController?.present(vc, animated: true)
    }
    
    @objc private func didTapRefresh() {
        inputTextField.text = nil
        viewModel.clear()
    }
    
    @objc func inputEditingChanged(_ sender: UITextField) {
        viewModel.didChange(inputString: sender.text!)
    }
    
    override func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        stackView.insertArrangedSubview(bannerView, at: 0)
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
        configureTabbar(isHidden: false)
        
        bannerView?.removeFromSuperview()
        navigationItem.leftBarButtonItem = nil
    }
    
    func didDismiss() {
        configureTabbar(isHidden: false)
    }
}

extension GCFLCMViewController: GCFLCMViewModelDelegate {
    func reloadTableView() {
        for cell in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            let cell = cell as? OutputCell
            cell?.configure(with: viewModel.cellLayoutItems[indexPath.row])
        }
    }
}

extension GCFLCMViewController: OutputCellDelegate {
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

extension GCFLCMViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cellLayoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(
                withIdentifier: cellId,
                for: indexPath
            ) as? OutputCell else {
                return UITableViewCell()
        }
        cell.configure(with: viewModel.cellLayoutItems[indexPath.row])
        cell.delegate = self
        return cell
    }
}
