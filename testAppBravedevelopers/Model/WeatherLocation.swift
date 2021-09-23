//
//  WeatherLocation.swift
//  testAppBravedevelopers
//
//  Created by pavel on 21.09.21.
//

import Foundation

struct WeatherLocation: Decodable  {
    var product: String
    var dataseries: [Dataseries]
}

struct Dataseries: Decodable {
    var timepoint: Int
    var cloudcover: Int
    var seeing: Int
    var transparency: Int
    var lifted_index: Int
    var rh2m: Int
    var wind10m: Wind
    var temp2m: Int
    var prec_type: String
}

struct Wind: Decodable {
    var direction: String
    var speed: Int
}
