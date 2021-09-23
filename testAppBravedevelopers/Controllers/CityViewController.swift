//
//  CityViewController.swift
//  testAppBravedevelopers
//
//  Created by pavel on 21.09.21.
//

import UIKit

class CityViewController: UIViewController, LabelChangeDelegate {
    
    lazy var myString = [String]()
    let cityTableView = UITableView()
    var myFavoriteCity = FavoriteCity(arrayCity: [String]())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showTableView()
    }
    
    
    func changeLabelWithText(_ text: [String]?) {
        guard  let sentText = text else {return}
        myString = sentText
    }
    

    func showTableView() {
        cityTableView.frame = view.bounds
        cityTableView.register(CityTableViewCell.self, forCellReuseIdentifier: "cell")
        cityTableView.delegate = self
        cityTableView.dataSource = self
        view.addSubview(cityTableView)
    }
}


extension CityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myString.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cityTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = myString[indexPath.row]
        
        return cell
    }
    
    
    //name section and count
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var countSection = 1
        countSection = section
        let nameSection = "Your cityes"
        
        return nameSection
    }
    
    
    //pass data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailCityViewController()
        let selectedName = myString[indexPath.row]
        detailVC.tempInTheCity = selectedName
        self.present(detailVC, animated: true, completion: nil)
    }
}
