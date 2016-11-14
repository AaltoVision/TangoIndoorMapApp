//
//  Area.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox

class Area {
    let name: String
    let buildings: [Building]
    
    init(fileName: String){
        self.name = fileName.components(separatedBy: ".").first!
        let geoJSON: JSON = MapHelper.getJSON(filename: name, type: "geojson")
        let emptyDict = [Building]()
        var noNameCount = 0
        var noName: String {
            get {
                noNameCount += 1
                return "no_name_\(noNameCount)"
            }
        }
        
        self.buildings = geoJSON["features"].map { (_, feature: JSON) -> Building in
            
            let BuildingName = feature["properties"]["name"].string ?? noName
            
            if let longitudeLatitude = feature["geometry", "coordinates"][0][0].rawValue as? [[Double]] {
                var coordinates: [CLLocationCoordinate2D] = longitudeLatitude.map{
                    coord -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
                }
                let building = Building(coordinates: &coordinates, count: UInt(coordinates.count))
                building.manualInit(name: BuildingName, outlineGeometry: longitudeLatitude)
                return building
                
            } else if let longitudeLatitude = feature["geometry", "coordinates"][0].rawValue as? [[Double]] {
                var coordinates: [CLLocationCoordinate2D] = longitudeLatitude.map{
                    coord -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
                }
                let building = Building(coordinates: &coordinates, count: UInt(coordinates.count))
                building.manualInit(name: BuildingName, outlineGeometry: longitudeLatitude)
                return building
            } else {
                var coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 0, longitude: 0)]
                let building = Building(coordinates: &coordinates, count: UInt(coordinates.count))
                return building
            }
            
        }
    }
}
