//
//  TangoLibrary.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 14/07/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import Mapbox

protocol TangoMapData {
    var area: Area {get}
}

struct MapData: TangoMapData {
    
    
    static let sharedInstance = MapData()
    
    /// FIX
    /// Area("area.geojson")
    let area = Area(fileName: "otaniemi.geojson")
    
    
}
