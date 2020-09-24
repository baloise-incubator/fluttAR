//
//  LocationNode.swift
//  Runner
//
//  Created by marco on 24.09.20.
//

import Foundation

class ScavengerHuntNode {
  var id:Int
  var lat:CLLocationDegrees
  var long:CLLocationDegrees
  var alt:CLLocationDistance
  var isTapped:boolean
    
    init(id: Int, lat: CLLocationDegrees, long: CLLocationDegrees, alt: CLLocationDistance, isTapped: boolean) {
        self.id = id
        self.lat = lat
        self.long = long
        self.isTapped = isTapped
    }
}
