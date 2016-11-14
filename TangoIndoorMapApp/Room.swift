//
//  Room.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox

class Room: MGLPolygon, Indoor {
    var floor: Floor?
    var id: String?
    var type: String?
    private var _name: String?
    var name: String {
        return _name ?? "no name"
    }
    var marker: Marker?
    var color: UIColor {
        get {
            switch type! {
            case "cafeteria": return UIColor.orange
            case "auditorium": return UIColor.blue
            case "tyo", "työ": return UIColor.darkGray
            case "toilet", "wc": return UIColor.red
            case "elevator", "hissi": return UIColor.cyan
            default: return UIColor.black
            }
        }
    }
    
    func manualInit(floor: Floor, id: String, type: String, name: String, center centerLongitudeLatitude: [Double]){
        self.floor = floor
        self.id = id
        self.type = type
        self._name = name
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLongitudeLatitude[1], longitude: centerLongitudeLatitude[0])
        marker = Marker(coordinate: centerCoordinate, title: name, subtitle: nil, masterPolygon: self, type: .Room)
    }
}
