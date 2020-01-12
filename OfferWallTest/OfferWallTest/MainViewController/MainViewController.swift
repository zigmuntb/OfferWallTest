//
//  MainViewController.swift
//  OfferWallTest
//
//  Created by Arsenkin Bogdan on 12.01.2020.
//  Copyright © 2020 Arsenkin Bogdan. All rights reserved.
//

import UIKit
import WebKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!
    
    var firstModels = [TrendingModel]()
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        showAndHideSpinner(on: true)
        performFirstRequest()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        showAndHideSpinner(on: true)
        performSecondRequest(id: firstModels[counter].id)
        
        if counter == firstModels.count - 1{
            counter = 0
        } else {
            counter += 1
        }
        
    }
    
    func performFirstRequest() {
        guard let url = URL(string: "https://demo0040494.mockable.io/api/v1/trending") else { return }
        NetworkManager<[TrendingModel]>.requestData(with: url, fail: { [weak self] (errorMessage) in
            self?.showAndHideSpinner(on: false)
            self?.showErrorAlert(message: errorMessage)
        })  { [weak self] (models) in
            self?.showAndHideSpinner(on: false)
            self?.firstModels = models
            self?.performSecondRequest(id: models[self?.counter ?? 0].id)
            self?.counter += 1
        }
    }
    
    func performSecondRequest(id: Int) {
        guard let url = URL(string: "https://demo0040494.mockable.io/api/v1/object/\(id)") else { return }
        NetworkManager<ObjectModel>.requestData(with: url, fail: { [weak self] (errorMessage) in
            self?.showAndHideSpinner(on: false)
            self?.showErrorAlert(message: errorMessage)
        }) { [weak self] (model) in
            self?.showAndHideSpinner(on: false)
            if model.url == nil {
                self?.textLabel.isHidden = false
                self?.webView.isHidden = true
                if let content = model.contents {
                    self?.textLabel.text = content
                }
            } else {
                self?.textLabel.isHidden = true
                self?.webView.isHidden = false
                if let urlString = model.url {
                    guard let url = URL(string: urlString) else { return }
                    self?.webView.load(URLRequest(url: url))
                }
                
            }
        }
    }
    
    func showAndHideSpinner(on: Bool) {
        if on {
            loadSpinner.startAnimating()
            loadSpinner.isHidden = false
        } else {
            loadSpinner.stopAnimating()
            loadSpinner.isHidden = true
        }
        
    }
}
