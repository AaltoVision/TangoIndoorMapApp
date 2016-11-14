//
//  MapVCHelper.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 26/08/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

enum MapVCHelper {
    static func getStrngAsImage(text:String, bounds: CGRect) -> UIImage? {
        let width = bounds.width
        let height = bounds.height
        let size: CGSize = CGSize(width: width, height: height)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let UIContext = UIGraphicsGetCurrentContext()
        
        
        UIContext!.setFillColor(UIColor.clear.cgColor)
        UIContext!.fill(CGRect(x: 0, y:0, width:size.width, height:size.height))
        
        var snapshot: UIImage?
        let NStext = text as NSString
        
        let textSize = NStext.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        let rect = CGRect(x:bounds.size.width/2 - textSize.width/2,
            y:bounds.size.height/2 - textSize.height/2,
            width: textSize.width,
            height: textSize.height)
        NStext.draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        snapshot = UIGraphicsGetImageFromCurrentImageContext()
        
        
        UIGraphicsEndImageContext()
        return snapshot
        
    }
    
    static func loadTransparentUIView(parentView: UIView, transparentView: inout TransparentViewOverMGLMapView?, delegate:ClickOverMGLMapViewDelegate,  floorView: FloorView) {
        let frame = MapHelper.getViewFrame(frameSize: MapVCConstants.mapViewFrameSize)
        transparentView = TransparentViewOverMGLMapView.init(frame: frame)
        transparentView!.delegate = delegate
        transparentView!.floorView = floorView
        parentView.addSubview(transparentView!)
        parentView.bringSubview(toFront: transparentView!)
    }
    
    static func removeTransparentViewOverMGLMapView(view: UIView, transparentViewOverMGLMapView: inout TransparentViewOverMGLMapView?){
        log.info("")
        guard let tView = transparentViewOverMGLMapView else { log.info("     it was nil");return }
        if view.subviews.contains(tView) {
            transparentViewOverMGLMapView!.removeFromSuperview()
        }
        transparentViewOverMGLMapView = nil
        log.info("     removed and nil-ed")
    }
    
    static func loadStreetViewImageView(parentView: UIView, imageView: inout UIImageView?, imageName: String) {
        if let image = UIImage(named: imageName) {
            loadStreetViewImageView(parentView: parentView, imageView: &imageView, image: image)
        }
    }
    
    static func loadStreetViewImageView(parentView: UIView, imageView: inout UIImageView?, image: UIImage) {
        if let _ = imageView {
            updateStreetViewImageView(imageView: &imageView, image: image)
        } else {
            let height = parentView.bounds.height / 6
            let frame = CGRect(
                x: 0,
                y: parentView.bounds.height - height,
                width:parentView.bounds.width,
                height:height
            )
            
            imageView = UIImageView(image: image)
            imageView?.frame = frame
            
            imageView!.contentMode = .scaleAspectFit
            imageView!.autoresizingMask = [
                .flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin,
                .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth
            ]
            parentView.addSubview(imageView!)
            parentView.bringSubview(toFront: imageView!)
        }
    }
    
    static func updateStreetViewImageView( imageView: inout UIImageView?, image: UIImage) {
        log.info("Uploading streetView image")
        imageView?.image = image
        
    }
    
    static func showStreetViewPointAnnotation(view: MGLMapView, annotation: inout MGLPointAnnotation?, coord longitudeLatitude: [Double]) {
        
        if let _ = annotation {
            view.removeAnnotation(annotation!)
        }
        annotation = MGLPointAnnotation()
        annotation?.coordinate = CLLocationCoordinate2D(latitude: longitudeLatitude[1], longitude: longitudeLatitude[0])
        view.addAnnotation(annotation!)
    }
    
    static func showToastMessageAtTheBottom(view: UIView, frame: CGRect, message: String, duration: TimeInterval = 2.0) {
        let position = CGPoint(x: frame.width/2, y: frame.height - 40)
        view.makeToast(message, duration: duration, position: position)
    }
}


//struct MapState {
//    var floorDataType:FloorDataType
//    
//    var rooms = [Room]()
//    
//    mutating func updateRooms(newRooms: [Room], mapView: MGLMapView) {
//        removeAllRooms(mapView)
//    }
//    
//    private func addRooms(mapView: MGLMapView){
//        
//    }
//    
//    private func removeAllRooms(mapView: MGLMapView) {
//        mapView.removeAnnotations(rooms)
//        mapView.removeAnnotations(rooms.map{ room in room.marker! })
//    }
//}
