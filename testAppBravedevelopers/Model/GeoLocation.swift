//
//  GeoLocation.swift
//  testAppBravedevelopers
//
//  Created by pavel on 21.09.21.
//

import Foundation
import MapKit

class GeoLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
