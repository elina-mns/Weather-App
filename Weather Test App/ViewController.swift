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
    var hourlyTypes = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?

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
            let current = result.currently
            self.current = current
            self.hourlyTypes = result.hourly.data
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
            //Update user interface
            
        }) .resume()
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))

        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
    
        let icon = current?.icon.lowercased() ?? ""
        if icon.contains("clear") {
            let myCustomView = UIImageView()
            let myImage: UIImage = UIImage(named: "clear")!
            myCustomView.image = myImage
            headerView.insertSubview(myCustomView, at: 0)
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            myCustomView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
            myCustomView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
            myCustomView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
            myCustomView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        } else if icon.contains("rain") {
            let myCustomView = UIImageView()
            let myImage: UIImage = UIImage(named: "rain")!
            myCustomView.image = myImage
            headerView.insertSubview(myCustomView, at: 0)
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            myCustomView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
            myCustomView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
            myCustomView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
            myCustomView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        } else {
            let myCustomView = UIImageView()
            let myImage: UIImage = UIImage(named: "foggy")!
            myCustomView.image = myImage
            headerView.insertSubview(myCustomView, at: 0)
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            myCustomView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
            myCustomView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
            myCustomView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
            myCustomView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0).isActive = true
        }
    
        tempLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        
        guard let currentWeather = self.current else { return UIView() }
        tempLabel.text = "\(currentWeather.temperature)°"
        summaryLabel.text = self.current?.summary
        
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
        return headerView
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyTypes)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: types[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
