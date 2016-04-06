//
//  WeatherTableViewModel.swift
//  WhatsTheWeatherIn
//
//  Created by Marin Bencevic on 18/10/15.
//  Copyright © 2015 marinbenc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON

import Alamofire

extension NSDate {
	var dayString:String {
		let formatter = NSDateFormatter()
		formatter.setLocalizedDateFormatFromTemplate("d M")
		return formatter.stringFromDate(self)
	}
}

class WeatherTableViewModel {

	var disposeBag = DisposeBag()

	//MARK: Model
	var weather: Weather? {
		didSet {
			if weather?.cityName != nil {
				updateModel()
			}
		}
	}
	//MARK: UI
	
	var cityName = PublishSubject<String?>()
	var degrees = PublishSubject<String?>()
	var weatherDescription = PublishSubject<String?>()
	private var forecast:[WeatherForecast]?
	var weatherImage = PublishSubject<UIImage?>()
	var backgroundImage = PublishSubject<UIImage?>()
	var tableViewData = PublishSubject<[(String, [WeatherForecast])]>()
    var errorAlertController = PublishSubject<UIAlertController>()
	
	func updateModel() {
		cityName.on(.Next(weather?.cityName))
		if let temp = weather?.currentWeather?.temp {
			degrees.on(.Next(String(temp)))
		}
		weatherDescription.on(.Next(weather?.currentWeather?.description))
		if let id = weather?.currentWeather?.imageID {
			setWeatherImageForImageID(id)
			setBackgroundImageForImageID(id)
		}
		forecast = weather?.forecast
		if forecast != nil {
			sendTableViewData()
		}
	}
	
	func setWeatherImageForImageID(imageID: String) {
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
			if let url = NSURL(string: Constants.baseImageURL + imageID + Constants.imageExtension) {
				if let data = NSData(contentsOfURL: url) {
					dispatch_async(dispatch_get_main_queue()) { () -> Void in
						self.weatherImage.on(.Next(UIImage(data: data)))
					}
				}
			}
		}
	}
	
	//TODO:
	func setBackgroundImageForImageID(imageID: String) {
	}
	
	
	
	//Parses the forecast data into an array of (date, forecasts for that day) tuple
	func sendTableViewData() {
		if let currentForecast = forecast {
			
			var forecasts = [[WeatherForecast]]()
			var days = [String]()
			days.append(NSDate(timeIntervalSinceNow: 0).dayString)
			var tempForecasts = [WeatherForecast]()
			for forecast in currentForecast {
				if days.contains(forecast.date.dayString) {
					tempForecasts.append(forecast)
				} else {
					days.append(forecast.date.dayString)
					forecasts.append(tempForecasts)
					tempForecasts.removeAll()
					tempForecasts.append(forecast)
				}
			}
			tableViewData.on(.Next(Array(zip(days, forecasts))))
		}
	}
	
	//MARK: Weather fetching
    
	var searchText:String? {
		didSet {
			if let text = searchText {
				let urlString = Constants.baseURL + text.stringByReplacingOccurrencesOfString(" ", withString: "%20") + Constants.urlParams
				getWeatherForRequest(urlString)
			}
		}
	}
	
	func getWeatherForRequest(urlString: String) {
        APIClient.call(Method.GET, urlString: urlString)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { json in
                    self.weather = Weather(jsonObject: json)
                },
                onError: { error in
                    let gotError = error as NSError
                    self.postError("\(gotError.code)", message: gotError.domain)
            })
            .addDisposableTo(disposeBag)
	}
	
	func postError(title: String, message: String) {
        errorAlertController.on(.Next(UIAlertController(title: title, message: message, preferredStyle: .Alert)))
	}

}