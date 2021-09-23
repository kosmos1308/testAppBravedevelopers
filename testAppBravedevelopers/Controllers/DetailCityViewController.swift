//
//  DetailCityViewController.swift
//  testAppBravedevelopers
//
//  Created by pavel on 21.09.21.
//

import UIKit

class DetailCityViewController: UIViewController {
    
    private let cityLabel = UILabel()
    private let closeButton = UIButton()
    var tempInTheCity = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        createLabels()
        createCloseButton()
    }
    
    
    //MARK: - create labels (label shows temperature in the city)
    func createLabels() {
        cityLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        cityLabel.center = view.center
        cityLabel.font = UIFont(name: "Avenir Medium", size: 25)
        cityLabel.text = tempInTheCity
        cityLabel.textAlignment = .center
        cityLabel.numberOfLines = 0
        view.addSubview(cityLabel)
    }
    
    
    //MARK: - create close button + action
    func createCloseButton() {
        closeButton.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
