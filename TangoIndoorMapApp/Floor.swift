//
//  Floor.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox

class Floor: FloorProtocol {
    let building: Building
    let floorNumber: Int
    private var _rooms: [Room]?
    var rooms: [Room] { return _rooms! }
    
    init?(building: Building, fileName: String) {
        self.building = building
        
        /// Check floor number
        guard let floorNumberAsInt = Int(fileName.components(separatedBy: "_").last!) as Int? else {
            return nil
        }
        floorNumber = floorNumberAsInt
        
        
        /// Check if there is a floor plan file
        guard let geoJSON = MapHelper.getJSON(filename: fileName, type: "geojson") as JSON? else {
            print("Cannot read geoJSON file: \(fileName)")
            return nil
        }
        print("Can read geoJSON file: \(fileName)")
        setRooms(rooms: &_rooms, geoJSON: geoJSON)
        
    }
    
    private func setRooms( rooms: inout [Room]?, geoJSON: JSON) {
        let features = geoJSON["features"]
        
        rooms = features.map {
            (_, feature: JSON) -> Room? in
            let id: String = feature["properties", "id"].string ?? ""
            let type = feature["properties", "type"].string ?? ""
            let name = feature["properties", "name"].string ?? ""
            
            //            print("  Floor().setRooms(): Set center")
            var center: [Double] = [0, 0]
            if let _center = feature["center"].rawValue as? [Double] {
                center = _center
            }
            if let longitudeLatitude = feature["geometry", "coordinates"][0].rawValue as? [[[Double]]] {
                var coordinates: [CLLocationCoordinate2D] = longitudeLatitude.flatMap { $0 }.map{
                    coord -> CLLocationCoordinate2D in
                    //                    print("\(coord.count), \(coord)")
                    return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
                }
                //                print("    Room().init(): Set room")
                let room = Room(coordinates: &coordinates, count: UInt(coordinates.count))
                //                print("    Room().manualInit() ")
                room.manualInit(floor: self, id: id, type: type, name: name, center: center)
                return room
            } else if let longitudeLatitude = feature["geometry", "coordinates"].rawValue as? [[[Double]]] {
                var coordinates: [CLLocationCoordinate2D] = longitudeLatitude.flatMap { $0 }.map{
                    coord -> CLLocationCoordinate2D in
                    //                    print("\(coord.count), \(coord)")
                    return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
                }
                let room = Room(coordinates: &coordinates, count: UInt(coordinates.count))
                room.manualInit(floor: self, id: id, type: type, name: name, center: center)
                return room
            } else {
                print("No coordinate")
                return nil
            }
            
            }.flatMap { $0 }  // Remove nil
    }
    
}
