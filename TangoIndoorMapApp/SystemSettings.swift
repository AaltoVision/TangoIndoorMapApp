//
//  Constants.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 11/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit


enum AreaCenterCoordinates {
    // lat, lon
    // Add new coordinates from Google
    static let otaniemi = (60.1859386248525, 24.8258086191415)
    static let newYork = (60.1859386248525, 24.8258086191415)
    
}

enum MarkerImageDisplayMode {
    case None
    case Test
    case Unique
}

enum MarkerType {
    case Room
    case Building
}

enum MapVCConstants {
    static let mapViewFrameSize = ViewFrameSize.FiveOverSix
    static let roomMarkerHideZoomLevel:Double = 18.5
    static let doorButtonGreyFileName = "doorButtonGrey-60"
    static let doorButtonBlueFileName = "doorButtonBlue-60"
    static let clickFloorViewButtonGreyFileName = "click_grey"
    static let clickFloorViewButtonBlueFileName = "click_blue"
    static let defaultCenterCoordinate = CLLocationCoordinate2DMake(AreaCenterCoordinates.otaniemi.0, AreaCenterCoordinates.otaniemi.1)
    static let floorDataTypesAsArray: [FloorDataType] = [.Manual, .Tango, .FloorView]
    static let defaultFloorPickerData =  ["Click a building"]
}


enum PolygonType {
    case Outline
    case Default
    
    var color: UIColor {
        get {
            switch self {
            case .Outline:
                return UIColor(colorLiteralRed: 1.0, green: 0.18, blue: 0.0, alpha: 1.0)
            default:
                return UIColor(colorLiteralRed: 0.51, green: 0.33, blue: 0.91, alpha: 1.0)
            }
        }
    }
}

enum ViewFrameSize {
    case FiveOverSix
    case FullScreen
    case HalfUp
    case HalfDown
}

enum FloorDataType: String {
    case Manual = "Manual"
    case Tango = "Tango"
    case FloorView = "FloorView"
}



















enum ZoomLevelConstants {
    static let model: String = UIDevice.current.modelName
    static var zoomLevelForFloorPlanView: Double {
        switch model {
        case "iPod Touch 5":        return 14
        case "iPod Touch 6":        return 14
        case "iPhone 4":        return 14
        case "iPhone 4s":         return 14
        case "iPhone 5":        return 14
        case "iPhone 5c":         return 14
        case "iPhone 5s":         return 14
        case "iPhone 6":        return 14
        case "iPhone 6 Plus":         return 15
        case "iPhone 6s":         return 14
        case "iPhone 6s Plus":        return 15
        case "iPhone SE":         return 14
        case "iPad 2":        return 16
        case "iPad 3":        return 16
        case "iPad 4":        return 16
        case "iPad Air":        return 16
        case "iPad Air 2":        return 16
        case "iPad Mini":         return 15
        case "iPad Mini 2":         return 15
        case "iPad Mini 3":         return 15
        case "iPad Mini 4":         return 15
        case "iPad Pro":        return 16.41
        default: return 16
        }
    }
    
    static var zoomLevelForMapView: Double {
        return zoomLevelForFloorPlanView - 2
    }
    static let maxZoomLevel: Double = 20.0
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
