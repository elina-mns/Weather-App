//
//  ViewController.swift
//  Weather Test App
//
//  Created by Elina Mansurova on 2020-10-30.
//

import UIKit
import CoreLocation

// 1. User's location: CoreLocation
// 2. List of weather for the upcoming days using TableView
// 3. Hourly forecast for the current day using a horizontal orientation: Custom Cell - Collection View
// 4. API / request to get the data about weather

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet var table: UITableView!
    var types = [DailyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        //register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)

        table.delegate = self
        table.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    //Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let location = currentLocation else { return }
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(latitude),\(longitude)?exclude=[flags,minutely]"
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            //Validation
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            //Convert data to models/object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error: \(error)")
            }
            guard let result = json else { return }
            
            let entries = result.daily.data
            self.types.append(contentsOf: entries)
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            //Update user interface
            
        }) .resume()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: types[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
