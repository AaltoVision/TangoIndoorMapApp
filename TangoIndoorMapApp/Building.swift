//
//  Building.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 16/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Mapbox

class Building: MGLPolygon, Indoor {
    
    private var _name: String?
    var name: String {
        return _name ?? "no name"
    }
    var centerCoordinate: CLLocationCoordinate2D?
    var marker: Marker?
    
    private var _floors: [String:Floor]?
    var floors: [String:Floor]? { return _floors }
    
    
    // Geojson created with Tango
    private var _floorsTango: [String:Floor]?
    var floorsTango: [String:Floor]? { return _floorsTango }
    
    // IndoorView
    private var _floorViews: [String:FloorView]?
    var floorViews: [String:FloorView]? { return _floorViews }
    
    
    /// This MUST BE called manually AFTER the instantiation
    /// In Swift one cannot call a convenience initializer of its super class
    func manualInit(name: String, outlineGeometry longitudeLatitude: [[Double]]){
        self._name = name
        var centerLongitudeLatitude: [Double] {
            var sumLL = longitudeLatitude.reduce([0.0, 0.0]) {
                (accumulator, current) in
                var ac = accumulator; ac[0] += current[0];  ac[1] += current[1]
                return ac
            }
            return [sumLL[0] / Double(longitudeLatitude.count), sumLL[1] / Double(longitudeLatitude.count)]
        }
        
        centerCoordinate = CLLocationCoordinate2D(latitude: centerLongitudeLatitude[1], longitude: centerLongitudeLatitude[0])
        
        
        marker = Marker(coordinate: centerCoordinate!, title: name, subtitle: nil, masterPolygon: self, type: .Building)
        
        /***************/
        /*  BUG TO FIX */
        // This is an ad-hoc fix
        _floors = nil
        _floorViews = nil
        _floorsTango = nil
        // _floors is not a property of MGLPolygon and it is not initalized in super.init()
        // Somehow this is not yet initialized properly
        /***************/
        
        setFloors()
        
    }
    
    private func setFloors(){
        guard let floorNumberAsList = MapHelper.buildingNameAndFloors[name] else {
            return }
        
        _floors = [String:Floor]()
        
        let fileNamesAsList = floorNumberAsList.map{ getFloorFileName(floorNumber: $0) }
        (0..<fileNamesAsList.count).forEach { i in
            print("fileNamesAsList.count: \(fileNamesAsList.count), i:\(i)")
            let fileName = fileNamesAsList[i]
            let floorNumber = floorNumberAsList[i]
            let floor = Floor(building: self, fileName: fileName)
            self._floors![floorNumber] = floor
        }
        //        for floorNumberAsString in floorNumberAsList {
        //            let floor = Floor(building: self, fileName: getFloorFileName(floorNumberAsString))
        //            self._floors![floorNumberAsString] = floor
        //        }
        
        setFloorsTango(floorNumberAsList: floorNumberAsList)
        setFloorViews(floorNumberAsList: floorNumberAsList)
    }
    
    private func setFloorViews(floorNumberAsList: [String]) {
        let floorViewFileNameAsList: [String] = floorNumberAsList.map{ floorNumber in
            return getFloorViewFileName(floorNumber: floorNumber)
            }.filter{ fileName in
                guard MapHelper.getJSON(filename: fileName) != JSON.null else {
                    return false
                }
                return true
        }
        
        guard floorViewFileNameAsList.count > 0 else { print("     floorViewFileNameAsList.count == 0");return }
        print("    floorViewFileNameAsList.count: \(floorViewFileNameAsList.count)")
        _floorViews = [String:FloorView]()
        floorViewFileNameAsList.forEach { fileName in
            let floorView = FloorView(building: self, fileName: fileName)
            if floorView == nil { print("     ERROR: FloorView.init failed, \(fileName)")}
            let floorNumber = fileName.components(separatedBy: "_").last!
            _floorViews![floorNumber] = floorView
        }
        print("    setFloorViews DONE. floorViews.count = \(_floorViews!.count)")
    }
    
    private func setFloorsTango(floorNumberAsList: [String]) {
        print("Building.setFloorsTango()")
        /// floorNumberAsList = ["1", "2"]
        /// ==> fileNames = ["tango_1", "tango_2"]
        
        let manualFileNamesAsList = floorNumberAsList.map{ getFloorFileName(floorNumber: $0) }
        
        let floorTangoFileNameAsList: [String] = manualFileNamesAsList.filter{
            fileName in
            let buildingName = fileName.components(separatedBy: "_").first!
            let floorNumber = fileName.components(separatedBy: "_").last!
            let tangoFileName = "\(buildingName)-tango_\(floorNumber)"
            
            guard let _ = MapHelper.getJSON(filename: tangoFileName) as JSON? else {
                print("Cannot read geoJSON file: \(tangoFileName)")
                return false
            }
            return true
            
            
            }.map{fileName in
                let buildingName = fileName.components(separatedBy: "_").first!
                let floorNumber = fileName.components(separatedBy: "_").last!
                let tangoFileName = "\(buildingName)-tango_\(floorNumber)"
                return tangoFileName
        }
        
        floorTangoFileNameAsList.forEach{
            fileName in
            print(fileName)
        }
        
        
        print("    floorTangoFileNameAsList.count: \(floorTangoFileNameAsList.count)")
        guard floorTangoFileNameAsList.count > 0 else { return }
        // Check if file exists, given its path
        
        
        _floorsTango = [String:Floor]()
        floorTangoFileNameAsList.forEach { fileName in
            let floor = Floor(building: self, fileName: fileName)
            let floorNumber = fileName.components(separatedBy: "_").last!
            self._floorsTango![floorNumber] = floor
        }
        
        print("    Building.setFloorsTango() Done!")
        
    }
    
    private func getFloorFileName(floorNumber: String) -> String {
        return name + "_" + floorNumber
    }
    
    private func getFloorViewFileName(floorNumber: String) -> String {
        return name + "-floorView_" + floorNumber
    }
    
    private func getAvailableFileNamesAsArray(floorNumberAsList: [String], getFileName: (String) -> String) -> [String] {
        let availableFileNames: [String] = floorNumberAsList.map{ floorNumber in
            return getFileName(floorNumber)
            }.filter{ fileName in
                guard let _ = MapHelper.getJSON(filename: fileName) as JSON? else {
                    return false
                }
                return true
        }
        return availableFileNames
    }
    
    
}
