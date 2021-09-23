//
//  MapViewController.swift
//  testAppBravedevelopers
//
//  Created by pavel on 21.09.21.
//

import UIKit
import MapKit
import CoreLocation


protocol LabelChangeDelegate: class {
    func changeLabelWithText(_ text: [String]?)
}


class MapViewController: UIViewController {
    
    weak var delegate: LabelChangeDelegate?
    private var mapView = MKMapView()
    private let geoButton = UIButton()
    private let searchButton = UIButton()
    
    private var locationManager: CLLocationManager?
    private var myLocation: CLLocation?
    private var latitudinalMeters: CLLocationDistance = 1000
    private var longitudinalMeters: CLLocationDistance = 1000
    private var myAnnotation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), title: "", subtitle: "")
    private var newCoordinate = CLLocationCoordinate2D()
    
    private let tempView = UIView()
    private let closeButton = UIButton()
    private let temperatureLabel = UILabel()
    private let starButton = UIButton()
    private var count: Int = 0
    
    var cityArray = [String]()
    var annotationsArray = [MKPointAnnotation]()
    var myLocationTemp = [Int]()
    var myFavoriteCity = FavoriteCity(arrayCity: [String]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMapView()
        createGeoButton()
        createSerchButton()
        setupLocation()
        showMyLocation()
    }
     
    
    //MARK: - create map
    func createMapView() {
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.addSubview(geoButton)
        mapView.addSubview(searchButton)
    }
    
    
    //MARK: - create geo button + action
    func createGeoButton() {
        geoButton.frame = CGRect(x: Int(view.bounds.width - 70), y: Int((view.bounds.height) - 170), width: 50, height: 50)
        geoButton.backgroundColor = .systemGray2
        geoButton.alpha = 0.8
        geoButton.setImage(UIImage(named: "white_target"), for: .normal)
        geoButton.tintColor = .white
        geoButton.layer.cornerRadius = 25
        geoButton.addTarget(self, action: #selector(didTapGeoButton), for: .touchUpInside)
    }
    
    
    @objc func didTapGeoButton() {
        count = 0
        setupLocation()
        showMyLocation()
        updateTempView()
        locationManager?.stopUpdatingLocation()
    }
    
    
    //MARK: - update tempView if you agan click geo button
    func updateTempView() {
        guard let temp = myLocationTemp.last else {return}
        let temperature = "Your location \ntemperature: \(temp)°C"
        showTemperatureView(temperature: temperature)
    }
    
    
    //MARK: - search button + action -> show search alert
    func createSerchButton() {
        searchButton.frame = CGRect(x: Int(view.bounds.width - 70), y: Int(view.bounds.height/2), width: 50, height: 50)
        searchButton.backgroundColor = .systemGray2
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.layer.cornerRadius = 25
        searchButton.alpha = 0.8
        searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
    }
    
    
    @objc func didTapSearchButton() {
        closeButtonTapped()
        showSearchAlert()
    }
    
    
    //MARK: - show search alert (tap searchButton)
    func showSearchAlert() {
        let searchAlert = UIAlertController(title: "Search place", message: "Enter the address of the place to see it on the map", preferredStyle: .alert)
        searchAlert.addTextField { namePlaceTextField in
            namePlaceTextField.placeholder = "Address"
        }
        let ok = UIAlertAction(title: "OK", style: .default) { action in
            self.setupPlacemark(adressPlace: searchAlert.textFields?.first?.text ?? "") //setup placemark
            self.count = 0
            guard let newCity = searchAlert.textFields?.first?.text else { return }
            self.cityArray.append(newCity)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        searchAlert.addAction(ok)
        searchAlert.addAction(cancel)
        present(searchAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - show error alert if adress didn't found
    func showErrorAlert() {
        let errorAlert = UIAlertController(title: "Error", message: "Adress didn't found.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(ok)
        present(errorAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - setup Location
    func setupLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    //MARK: - show my location + add annotation on the map
    func showMyLocation() {
        guard let latitude = myLocation?.coordinate.latitude else {return}
        guard let longitude = myLocation?.coordinate.longitude else {return}
        
        let initialLocation = CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
        let region = MKCoordinateRegion(center: initialLocation, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        mapView.setRegion(region, animated: true)
        
        //add annotation
        myAnnotation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude)), title: "Your location", subtitle: "Latitude \(Double(latitude)), Longitude \(Double(longitude))")
        mapView.addAnnotation(myAnnotation)
    }
    

    //MARK: - setup placemarket (new city)
    private func setupPlacemark(adressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { [self] (placemark, error) in
            if let error = error {
                print(error)
                showErrorAlert()
                return
            }
            
            guard let placemarks = placemark else { return }
            let place = placemark?.first
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace.capitalized)"
            annotation.subtitle = "latitude: \(newCoordinate.latitude), longitude: \(newCoordinate.longitude)"
            
            guard let placemarkLocation = place?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            annotationsArray.append(annotation)
            mapView.showAnnotations(annotationsArray, animated: true)
            newCoordinate = placemarkLocation.coordinate
           
            if newCoordinate != nil {
                showTemperatureInNewCity()
            }
        }
    }
    
    
    //MARK: - show view with temperature label, close button, star button + actions
    func showTemperatureView(temperature: String) {
        tempView.frame = CGRect(x: 20, y: 50, width: Int(view.bounds.width - 40), height: 80)
        tempView.backgroundColor = .white
        tempView.layer.cornerRadius = 15
        tempView.alpha = 0.8
        view.addSubview(tempView)
        
        temperatureLabel.frame = CGRect(x: 60, y: 10, width: Int(tempView.bounds.width - 120), height: 60)
        temperatureLabel.font = UIFont(name: "Avenir Medium", size: 25)
        temperatureLabel.textAlignment = .center
        temperatureLabel.numberOfLines = 0
        temperatureLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.minimumScaleFactor = 0.5
        temperatureLabel.text = temperature
        tempView.addSubview(temperatureLabel)
        
        closeButton.frame = CGRect(x: 5, y: 5, width: 25, height: 25)
        closeButton.layer.cornerRadius = 10
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        tempView.addSubview(closeButton)
        
        starButton.frame = CGRect(x: Int(tempView.bounds.width - 60), y: 15, width: 50, height: 50)
        starButton.setImage(UIImage(named: "gray_star"), for: .normal)
        starButton.setImage(UIImage(named: "yellow_star"), for: .selected)
        starButton.addTarget(self, action: #selector(starButtonTapped(sender:)), for: .touchUpInside)
        tempView.addSubview(starButton)
    }
    
    
    // click close button
    @objc func closeButtonTapped() {
        UIView.animate(withDuration: 0.3) { [self] in
            self.tempView.frame.origin.x += (tempView.frame.width + 60)
        }
    }
    
    
    // click star button
    @objc func starButtonTapped(sender: UIButton) {
        if sender.isTouchInside == true {
            count += 1
            if count % 2 == 0 {
                starButton.setImage(UIImage(named: "gray_star"), for: .normal)
                cityArray.removeLast()
                myFavoriteCity.arrayCity.removeLast()
            } else if count % 2 != 0 {
                starButton.setImage(UIImage(named: "yellow_star"), for: .normal)
                cityArray.append("\(temperatureLabel.text ?? "")")
                myFavoriteCity.arrayCity.append(temperatureLabel.text ?? "")
                dataToCityVC()
            }
        }
    }
    
    
    //MARK: - method show temperature in new city (search)
    func showTemperatureInNewCity() {
        let urlStringNewLocation = "https://www.7timer.info/bin/astro.php?lon=\(newCoordinate.latitude)&lat=\(newCoordinate.longitude)&unit=metric&output=json"
        guard let url = URL(string: urlStringNewLocation) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            guard error == nil else {return}
            
            do {
                let weatherLocation: WeatherLocation?
                weatherLocation = try JSONDecoder().decode(WeatherLocation.self, from: data)
                
                let temperature = weatherLocation?.dataseries.first?.temp2m
                guard let temperatureCity = temperature else { return }
                guard let nameCity = self.cityArray.last?.capitalized else {return} //a big first letter
                let text = "\(nameCity) \ntemperature: \(temperatureCity)°C"
                
                DispatchQueue.main.async {
                    self.showTemperatureView(temperature: text)
                }
            } catch let error {
                print(error)
            }
        }.resume()
        locationManager?.stopUpdatingLocation()
    }
    

    //MARK: - pass data
    func dataToCityVC() {
        guard let vcList = tabBarController?.viewControllers else {return}
        
        for controller in vcList {
            if let second = controller as? CityViewController {
                delegate = second as? LabelChangeDelegate
                delegate?.changeLabelWithText(myFavoriteCity.arrayCity) //передача массива
            }
        }
    }
}


//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    //show temperature in my location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = locations.last
        guard let coordinates = myLocation?.coordinate else {return}
        let urlStringLocation = "https://www.7timer.info/bin/astro.php?lon=\(coordinates.latitude)&lat=\(coordinates.longitude)&unit=metric&output=json"
        guard let url = URL(string: urlStringLocation) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            guard error == nil else {return}
            
            do {
                let weatherLocation: WeatherLocation?
                weatherLocation = try JSONDecoder().decode(WeatherLocation.self, from: data)
        
                let temperature = weatherLocation?.dataseries.first?.temp2m
                guard let temperatureCity = temperature else { return }
                
                let text = "Your location \ntemperature: \(temperatureCity)°C"
                self.myLocationTemp.append(temperatureCity)
            
                DispatchQueue.main.async {
                    self.showTemperatureView(temperature: text)
                }
            } catch let error {
                print(error)
            }
        }.resume()
        locationManager?.stopUpdatingLocation()
    }
    
    //show alert if error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let errorAlert = UIAlertController(title: "Error!", message: "We can't get your location", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(ok)
        present(errorAlert, animated: true, completion: nil)
    }
}
