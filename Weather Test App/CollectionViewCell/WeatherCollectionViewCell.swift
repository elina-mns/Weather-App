//
//  WeatherCollectionViewCell.swift
//  Weather Test App
//
//  Created by Elina Mansurova on 2020-11-03.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!

    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    func configure(with model: HourlyWeatherEntry) {
        self.tempLabel.text = "\(model.temperature)°"
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(named: "clear1")
        self.iconImageView.backgroundColor = .clear
        self.tempLabel.backgroundColor = .clear
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
