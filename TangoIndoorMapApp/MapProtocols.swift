//
//  MapProtocols.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import Mapbox


/// Building, Room
protocol Indoor {
    var name: String { get }
}

protocol MarkerProtocol {
    var polygon: MGLPolygon? { get }
    //    var type: MarkerType { get }
}

protocol FloorProtocol {
    var building: Building { get }
    var floorNumber: Int { get }
}