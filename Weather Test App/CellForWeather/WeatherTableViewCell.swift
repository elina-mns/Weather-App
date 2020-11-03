//
//  WeatherTableViewCell.swift
//  Weather Test App
//
//  Created by Elina Mansurova on 2020-10-30.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static let identifier = "WeatherTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell",
                     bundle: nil)
    }
    
    func configure(with model: DailyWeatherEntry) {
        self.highTempLabel.textAlignment = .center
        self.lowTempLabel.textAlignment = .center
        
        self.lowTempLabel.text = "\(Int(model.temperatureLow))°"
        self.highTempLabel.text = "\(Int(model.temperatureHigh))°"
        self.dayLabel.text = getDayForDate(Date(timeIntervalSince1970: Double(model.time)))
        let icon = model.icon.lowercased()
        if icon.contains("clear1") {
            self.iconImageView.image = UIImage(named: "clear1")
        } else if icon.contains("rain1") {
            self.iconImageView.image = UIImage(named: "rain1")
        } else {
            self.iconImageView.image = UIImage(named: "cloud1")
        }
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: inputDate)
    }
}
