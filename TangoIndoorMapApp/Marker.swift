//
//  Marker.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox


class Marker: MGLPointAnnotation, MarkerProtocol {
    
    private weak var _polygon: MGLPolygon?
    var polygon: MGLPolygon? { return _polygon }
    let type: MarkerType
    
    init(coordinate :CLLocationCoordinate2D, title: String?, subtitle: String?, masterPolygon polygon: MGLPolygon, type: MarkerType) {
        self._polygon = polygon
        self.type = type
        
        super.init()
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
