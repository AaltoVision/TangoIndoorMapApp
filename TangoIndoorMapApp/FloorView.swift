//
//  FloorView.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 22/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import Mapbox

protocol FloorViewProtocol {
    var polyline: MGLPolyline { get }
    var coordinates: [[Double]] { get }
    
}

class FloorView: FloorProtocol, FloorViewProtocol {
    let building: Building
    let floorNumber: Int
    let polyline: MGLPolyline
    private let longitudeLatitude: [[Double]]
    var coordinates: [[Double]] {
        return longitudeLatitude
    }
    
    init?(building: Building, fileName: String) {
        self.building = building
        guard let floorNumberAsInt = MapHelper.getFloorNumberFromFileName(fileName: fileName),
            let (_polyline, _coordinates) = MapHelper.getPolylineAndCoordinates(fileName: fileName)
            else {
                return nil
        }
        floorNumber = floorNumberAsInt
        (polyline, longitudeLatitude) = (_polyline, _coordinates)
        
    }
    
    
}
