//
//  geoJSONHelper.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 11/07/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox


enum MapHelper {
    static private func getAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
    static func getMapData() -> MapData {
        return getAppDelegate().mapDataSharedInstance
    }
    
    static func getPolylineAndCoordinates(fileName: String) -> (MGLPolyline, [[Double]])? {
        print(">>>> MapHelper.getPolylineAndCoordinates()")
        guard let geoJSON = getJSON(filename: fileName, type: "geojson") as JSON? , geoJSON != JSON.null else {
            print("    Cannot read geoJSON file: \(fileName)")
            return nil
        }
        guard let longitudeLatitude: [[Double]] = getCoordinatesFromGeoJSON(geoJSON: geoJSON) else {
            print("    No longitudeLatitude")
            return nil
        }
        let polyline = getPolyline(longitudeLatutide: longitudeLatitude)
        return (polyline, longitudeLatitude)
    }
    
    static func getPolyline(longitudeLatutide: [[Double]]) -> MGLPolyline {
        var coords: [CLLocationCoordinate2D] = getCLLocationCoordinate2DArrayFromDoubleArray(longitudeLatutide: longitudeLatutide)
        return MGLPolyline(coordinates: &coords, count: UInt(coords.count))
    }
    
    static func getCLLocationCoordinate2DArrayFromDoubleArray(longitudeLatutide: [[Double]]) -> [CLLocationCoordinate2D] {
        return longitudeLatutide.map { coord in
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }
    }
    
    static func getCoordinatesFromGeoJSON(geoJSON :JSON) -> [[Double]]? {
        let coordinates = geoJSON["features"][0]["geometry", "coordinates"]
        if let longitudeLatitude = coordinates.rawValue as? [[Double]] {
            return longitudeLatitude
        } else if let longitudeLatitude = coordinates[0].rawValue as? [[Double]] {
            return longitudeLatitude
        } else {
            //            print("    features:")
            //            print(geoJSON["features"])
            //            print("    geometry:")
            //            print(geoJSON["features", "geometry"])
            //            print(coordinates)
            return nil
        }
    }
    
    static func getRoomColor(color: String) -> UIColor {
        switch color {
        case "toilet": return UIColor.red
        default: return UIColor.blue
        }
        
    }
    static let geoJSONNotConnectedFiles: [String] = [
        //        "Aalto TUAS-talo_1",
        //        "Aalto TUAS-talo_2"
    ]
    
    static let geoJSONConnectedFiles: [String] = [
        //        "Aalto TUAS-talo_2_connected"
    ]
    
    static let buildingNameAndFloors: [String:[String]] = [
        "Aalto TUAS-talo": ["1", "2"],
        "jonathan": ["1", "2", "3"]
    ]
    
    static func getJSON(filename:String, type:String = "geojson") -> JSON {
        if let path = Bundle.main.path(forResource: filename, ofType: type) {
            do {
                let data = try NSData(contentsOf: NSURL(fileURLWithPath: path) as URL, options: NSData.ReadingOptions.mappedIfSafe)
                let jsonObj = JSON(data: data as Data)
                if jsonObj != JSON.null {
                    //                    print("jsonData:\(jsonObj)")
                    return jsonObj
                } else {
                    GeneralHelper.log(message: "could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                GeneralHelper.log(message: error.localizedDescription)
            }
        } else {
            GeneralHelper.log(message: "Invalid filename/path: \(filename).")
        }
        return JSON.null
    }
    
    static func getMarker(coordinate longitudeLatitude:[Double], title: String?, type subtitle: String?) -> MGLPointAnnotation {
        let marker = MGLPointAnnotation()
        marker.coordinate = CLLocationCoordinate2D(latitude: longitudeLatitude[1], longitude: longitudeLatitude[0])
        marker.title = title
        marker.subtitle = subtitle
        return marker
    }
    
    static func getPolygon(coordinates longitudeLatitude: [[Double]]) -> MGLPolygon? {
        guard var coordinates = getCoordinates(longitudeLatitude: longitudeLatitude) as [CLLocationCoordinate2D]? else {
            return nil
        }
        return MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
    }
    
    /// Reduce a sequence of dictionary with merge
    static func reduceDictionaryWithMerge(accumulator: [String:MGLPolygon], current: [String:MGLPolygon]) -> [String:MGLPolygon] {
        var ac = accumulator; ac.merge(other: current); return ac
    }
    
    static func getCoordinates(longitudeLatitude: [[Double]]) -> [CLLocationCoordinate2D]? {
        guard longitudeLatitude.count > 0 else { return nil }
        
        let coordinates: [CLLocationCoordinate2D] = longitudeLatitude.map{
            coord -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
        }
        return coordinates
    }
    
    static func getFloorNumberFromFileName(fileName: String) -> Int? {
        guard let floorNumberAsInt = Int(fileName.components(separatedBy: "_").last!) as Int? else {
            return nil
        }
        return floorNumberAsInt
    }
    
    static func getViewFrame(frameSize: ViewFrameSize) -> CGRect {
        let bounds = UIScreen.main.bounds
        switch frameSize {
        case .FiveOverSix: return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: bounds.width, height: bounds.height/6*5))
        case .FullScreen: return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: bounds.width, height: bounds.height))
        case .HalfUp: return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: bounds.width, height: bounds.height/2))
        case .HalfDown: return CGRect(origin: CGPoint(x: 0, y: bounds.height/2), size: CGSize(width: bounds.width, height: bounds.height/2))
        }
        
    }
    
}





extension Dictionary {
    mutating func merge(other: Dictionary) {
        for (k, v) in other {
            if self.keys.contains(k) {
                print("   DUPLICATE \(k) - \(v)")
            }
            self[k] = v }
    }
}
