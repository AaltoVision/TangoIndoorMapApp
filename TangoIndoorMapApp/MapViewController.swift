//
//  ViewController.swift
//  TangoAaltoDev
//
//  Created by Park Seyoung on 30/05/16.
//  Copyright © 2016 Park Seyoung. All rights reserved.
//

import Mapbox
import Toast_Swift

protocol SimpleMessengerDelegate {
    func showSearchResult(result: String)
    
    var isPopoverViewOn: Bool { get set }
}

class MapViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate, UISearchBarDelegate, SimpleMessengerDelegate, MGLMapViewDelegate, ClickOverMGLMapViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
//    @available(iOS 2.0, *)
//    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }

    
    func loadStreetViewImage(index: Int) {
        let imageName = clickedBuilding!.name + "_" + currentFloorNumber + "_\(index)"
        log.info(imageName)
        if let image = UIImage(named: imageName) {
            MapVCHelper.loadStreetViewImageView(parentView: view, imageView: &streetViewImageView, imageName: imageName)
            let coord = clickedBuilding!.floorViews![currentFloorNumber]!.coordinates[index]
            MapVCHelper.showStreetViewPointAnnotation(view: mapView!, annotation: &streetViewImageViewPointAnnotation, coord: coord)
        } else {
            let message = "This floorView has no Images"
            MapVCHelper.showToastMessageAtTheBottom(view: view, frame: mapView.frame, message: message)
        }
    }
    
    func showSearchResult(result: String) {
        let results = mapData?.area.buildings.filter{ $0.name == result }
        guard let resultBuilding = results!.first else { return }
        clickedBuilding = resultBuilding
    }
    
    var currentFloorNumber: String {
        let currentRow = floorPicker.selectedRow(inComponent: 0)
        return floorPickerData[currentRow]
    }
    
    var streetViewImageViewPointAnnotation: MGLPointAnnotation?
    var streetViewImageView: UIImageView?
    var stringImageView: UIImageView!
    var floorPicker: UIPickerView!
    var floorDataTypePicker: UIPickerView!
    var searchBar: UISearchBar!
    var clickFloorViewButton: UIButton?
    var transparentViewOverMGLMapView: TransparentViewOverMGLMapView? {
        willSet {
            
        }
        didSet {
            log.info(">>>> \(transparentViewOverMGLMapView)")
            if let _ = transparentViewOverMGLMapView {
                loadclickFloorViewButton()
            }
        }
    }
    
    private func loadclickFloorViewButton() {
        log.info("    loading button")
        let buttonImage = UIImage(named: MapVCConstants.clickFloorViewButtonBlueFileName)! as UIImage
        buttonImage.accessibilityIdentifier = MapVCConstants.clickFloorViewButtonBlueFileName
        
        let frame = CGRect(
            x: showRoomMarkerButton.frame.minX,
            y: showRoomMarkerButton.frame.minY - 100,
            width: buttonImage.size.width,
            height: buttonImage.size.height)
        
        clickFloorViewButton = UIButton(type: .custom)
        if let clickFloorViewButton = clickFloorViewButton {
            clickFloorViewButton.frame = frame
            clickFloorViewButton.addTarget(self, action: #selector(toggleClickabilityOnFloorView), for: .touchUpInside)
            clickFloorViewButton.clipsToBounds = true
            clickFloorViewButton.setImage(buttonImage, for: .normal)
            view.addSubview(clickFloorViewButton)
            view.bringSubview(toFront: clickFloorViewButton)
        }
        
    }
    
    private func disableClickabilityOnFloorView(){
        guard let _ = transparentViewOverMGLMapView, let _ = clickFloorViewButton else { return }
        setButtonImage(button: clickFloorViewButton!, imageName: MapVCConstants.clickFloorViewButtonGreyFileName)
        transparentViewOverMGLMapView!.removeFromSuperview()
        /// Hide floorViewImageView
        unloadStreetViewImageView()
    }
    
    private func unloadStreetViewImageView(){
        guard let _ = streetViewImageView else { return }
        streetViewImageView?.removeFromSuperview()
        streetViewImageView = nil
        unloadStreetViewImageViewPointAnnotation()
    }
    
    private func unloadStreetViewImageViewPointAnnotation() {
        guard let _ = streetViewImageViewPointAnnotation else { return }
        mapView.removeAnnotation(streetViewImageViewPointAnnotation!)
        streetViewImageViewPointAnnotation = nil
    }
    
    private func enableClickabilityOnFloorView(){
        guard let _ = transparentViewOverMGLMapView, let _ = clickFloorViewButton else { return }
        setButtonImage(button: clickFloorViewButton!, imageName: MapVCConstants.clickFloorViewButtonBlueFileName)
        view.addSubview(transparentViewOverMGLMapView!)
        view.bringSubview(toFront: transparentViewOverMGLMapView!)
        //        zoomIn(mapView!.centerCoordinate, zoomLevel: ZoomLevelConstants.maxZoomLevel)
        
    }
    
    func toggleClickabilityOnFloorView(sender: UIButton!){
        if let imageName = sender.currentImage!.accessibilityIdentifier , imageName == MapVCConstants.clickFloorViewButtonBlueFileName {
            disableClickabilityOnFloorView()
        } else {
            enableClickabilityOnFloorView()
        }
    }
    
    private func setButtonImage(button: UIButton, imageName: String){
        guard let image = UIImage(named: imageName) else { return }
        image.accessibilityIdentifier = imageName
        button.setImage(image, for: .normal)
        
    }
    
    private var searchView: SearchTableViewController?
    private var mapData: MapData?
    private var currentRoomColor: UIColor?
    var mapView: MGLMapView!
    private var floorPickerData: [String] = MapVCConstants.defaultFloorPickerData {
        didSet {
            floorPicker.reloadAllComponents()
        }
    }
    
    
    
    //    private var floorTangoPickerData = ["Manual", "Tango", "IndoorView"]
    private var floorDataTypePickerData: [String] = MapVCConstants.floorDataTypesAsArray.map{ $0.rawValue }
    var floorDataTypeState = FloorDataType.Manual {
        didSet{
            cleanFeaturesAfterFloorDateTypeStateChange()
            print(">>>> floorDataTypeState.didSet setFloorPicker()")
            setFloorPicker()
        }
    }
    
    private func cleanFeaturesAfterFloorDateTypeStateChange(){
        roomsDisplayed = [Room]()
        floorViewPolyline = nil
        removeClickFloorViewButton()
    }
    
    private func removeClickFloorViewButton(){
        if let _ = clickFloorViewButton {
            clickFloorViewButton!.removeFromSuperview()
            clickFloorViewButton = nil
            /// souji
        }
    }
    
    private var floorViewPolyline: MGLPolyline? {
        willSet {
            log.info("floorViewPolyline = \(newValue)")
            if newValue == nil {
                if let _ = transparentViewOverMGLMapView {
                    MapVCHelper.removeTransparentViewOverMGLMapView(view: view, transparentViewOverMGLMapView: &transparentViewOverMGLMapView)
                }
                removeClickFloorViewButton()
                unloadStreetViewImageView()
            }
            roomsDisplayed = [Room]()
            
            if let _ = clickedBuilding!.floorsTango?[currentFloorNumber] , newValue != nil {
                log.debug("Set rooms")
                roomsDisplayed = clickedBuilding!.floorsTango![currentFloorNumber]!.rooms
            }
        }
        
        didSet(oldFloorViewPolyline) {
            updateFloorViewPolyline(old: oldFloorViewPolyline, new: floorViewPolyline)
            if floorViewPolyline != nil && transparentViewOverMGLMapView == nil {
                guard let floorViews:[String:FloorView] = clickedBuilding!.floorViews , floorDataTypeState == .FloorView else {
                    return
                }
                
                let currentPickerRow = floorPicker.selectedRow(inComponent: 0)
                print("    floorPicker.selectedRowInComponent(0) == \(currentPickerRow)")
                print("    floorViews[floorDataTypePickerData[currentPickerRow]]!")
                if let floorView: FloorView = floorViews[floorPickerData[currentPickerRow]] {
                    print(">>>> Load TransparentUIView()")
                    MapVCHelper.loadTransparentUIView(parentView: view, transparentView: &transparentViewOverMGLMapView, delegate: self, floorView: floorView)
                } else {
                    print("      floorViews[floorDataTypePickerData[currentPickerRow]] == nil\n    \(floorDataTypePickerData)")
                }
                
            }
        }
    }
    
    private func updateFloorViewPolyline(old: MGLPolyline?, new: MGLPolyline?) {
        if let _ = old {
            mapView!.removeAnnotation(old!)
        }
        if let _ = new {
            mapView!.addAnnotation(new!)
            zoomIn(obj: clickedBuilding!, zoomLevel: ZoomLevelConstants.maxZoomLevel)
        }
    }
    
    private var roomsDisplayed = [Room]() {
        willSet {
            /// Remove old floor data
            mapView!.removeAnnotations(roomsDisplayed)
            mapView!.removeAnnotations(roomsDisplayed.map{ room in room.marker! })
        }
        didSet {
            mapView!.addAnnotations(roomsDisplayed)
            let roomMarkers = roomsDisplayed.map{ room in room.marker! }
            if zoomLevelObserver >= MapVCConstants.roomMarkerHideZoomLevel {
                mapView!.addAnnotations(roomMarkers)
            } else {
                hiddenRoomMarkersAsArray = roomMarkers
            }
            
        }
    }
    
    private func showBuildingOutlineAndMarker(building: Building?){
        guard building != nil else { return }
        roomsDisplayed = [Room]()
        floorViewPolyline = nil
        mapView.addAnnotation(building!)
        if let marker = building!.marker { mapView.addAnnotation(marker) }
    }
    
    private func hideBuildingOutlineAndMarker(building: Building){
        mapView.removeAnnotation(building)
        if let marker = building.marker { mapView.removeAnnotation(marker) }
    }
    
    var clickedBuilding: Building? {
        willSet {
            /// Draw old building's outline & marker
            log.verbose("clickedBuilding.willSet")
            
            showBuildingOutlineAndMarker(building: clickedBuilding)
        }
        didSet {
            /// Erase new building's outline & marker
            log.verbose("clickedBuilding.didSet")
            
            setFloorPicker()
            
            if let _ = clickedBuilding {
                updateSearchBarAfterBuildingClicked(name: clickedBuilding!.name)
                zoomIn(obj: clickedBuilding!)
                hideBuildingOutlineAndMarker(building: clickedBuilding!)
                showFloor()
            }
            
        }
    }
    
    private func zoomIn(coord: CLLocationCoordinate2D, zoomLevel: Double = ZoomLevelConstants.zoomLevelForFloorPlanView) {
        mapView.setCenter(coord, zoomLevel: zoomLevel, animated: true)
    }
    
    private func zoomIn(obj: Building, zoomLevel: Double = ZoomLevelConstants.zoomLevelForFloorPlanView) {
        mapView.setCenter(obj.centerCoordinate!, zoomLevel: zoomLevel, animated: true)
    }
    
    private func initDefaultLocation(coords: CLLocationCoordinate2D, zoomLevel: Double) {
        mapView.setCenter(coords, zoomLevel: zoomLevel, animated: false)
    }
    
    private func updateSearchBarAfterBuildingClicked(name: String){
        searchBar.text = "in:" + name + " "
    }
    
    
    private func showFloor(){
        print(">>> showFirstFloor() @ \(floorDataTypeState)")
        
        func floorPickerDataIsNotEmpty() -> Bool {
            return floorPickerData != ["No data"] && floorPickerData != MapVCConstants.defaultFloorPickerData
        }
        
        guard let building = clickedBuilding , floorPickerDataIsNotEmpty() else { return }
        let currentRow: Int = floorPicker.selectedRow(inComponent: 0)
        let currentFloor = floorPickerData[currentRow]
        
        let first = floorPickerData.sorted().first!
        print("    first: \(first)")
        print("    ")
        switch floorDataTypeState {
        case .Manual: roomsDisplayed = building.floors![currentFloor]!.rooms
            
        case .Tango: roomsDisplayed = building.floorsTango![currentFloor]!.rooms
            
        case .FloorView: floorViewPolyline = building.floorViews![currentFloor]!.polyline
        }
        
    }
    
    private func setFloorPicker() {
        
        log.verbose("setFloorPicker()")
        if let building = clickedBuilding {
            switch floorDataTypeState {
            case .Manual: floorPickerData = getFloorNamesSortedAsList(stringAndfloors: building.floors) ?? ["No data"]
                
            case .Tango: floorPickerData = getFloorNamesSortedAsList(stringAndfloors: building.floorsTango) ?? ["No data"]
                
            case .FloorView: floorPickerData = getFloorNamesSortedAsList(stringAndfloors: building.floorViews) ?? ["No data"]
            }
            showFloor()
            
        } else {
            floorPickerData = MapVCConstants.defaultFloorPickerData
        }
        log.verbose("setFloorPicker Done")
    }
    
    private func getFloorNamesSortedAsList(stringAndfloors: [String:AnyObject]?) -> [String]? {
        print("    getFloorNamesSortedAsList called, length:\(stringAndfloors?.count)")
        guard let sf = stringAndfloors , sf.count > 0 else { log.debug("    return nil"); return nil }
        let fpd = Array(sf.keys).sorted()
        log.debug("    \(fpd)")
        return Array(sf.keys).sorted()
    }
    
    
    
    private var mapViewGestureRecognizers: [UIGestureRecognizer]?
    //    private var singleTap: UITapGestureRecognizer {
    //        return UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard as () -> ()))
    //    }
    
    func keyboardWillDisappear(notification: NSNotification){
        //        log.debug("keyboardWillApper: \(view.gestureRecognizers) \n \(view.subviews)")
        mapView.gestureRecognizers = mapViewGestureRecognizers
    }
    
    func keyboardWillApper(notification: NSNotification){
        
        //        view.addGestureRecognizer(singleTap)
        log.debug("keyboardWillApper: \(view.gestureRecognizers) \n \(view.subviews)")
        mapView.gestureRecognizers = nil
    }
    
    private func loadMapView(){
        let mapViewFrame = MapHelper.getViewFrame(frameSize: MapVCConstants.mapViewFrameSize)
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let keys = NSDictionary(contentsOfFile: path), let styleString = keys["MGLMapboxStylePokemon"] as? String {
            let styleURL = URL(string: styleString)
            mapView = MGLMapView(frame: mapViewFrame, styleURL: styleURL)
        } else {
            mapView = MGLMapView(frame: mapViewFrame)
        }
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        /// Load Search Bar
        loadSearchController()
        
        
        /// Load floor picker
        loadPicker()
        
        
        /// Load Map view
        loadMapView()
        
        initDefaultLocation(coords: MapVCConstants.defaultCenterCoordinate, zoomLevel: ZoomLevelConstants.zoomLevelForMapView)
        
        /// FIX
        //  getPolygonsForLocations(MapVCConstants.defaultCenterCoordinate)
        
        
        log.verbose("model: \(ZoomLevelConstants.model)\t zoomLevel: \(ZoomLevelConstants.zoomLevelForMapView)")
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        mapView.delegate = self
        
        
        /// Load geoJSON map data
        if self.mapData == nil {
            self.setMapDataDelegate()
        }
        
        /// Save all mapView gestureRecognizers for keyboard dismissal
        if let gestureRecognizers = mapView.gestureRecognizers {
            mapViewGestureRecognizers = gestureRecognizers
        }
        
        /// 
        loadShowRoomMarkerButton()
        
        /// Load Keyboard listener
        hideKeyboardWhenTappedAround()
        log.debug("viewDidLoad: \(view.gestureRecognizers)")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillApper), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /// All the drawings MUST happen here.
        drawOtaniemi()
        //        guard let stringImage = getStrngAsImage("Hahaha") else {return }
        //        stringImageView = UIImageView(image: stringImage)
        //        stringImageView.frame = CGRect(
        //            x: (view.bounds.width - stringImageView.image!.size.width)/2,
        //            y: (view.bounds.width - stringImageView.image!.size.height)/2,
        //            width: stringImageView.image!.size.width,
        //            height: stringImageView.image!.size.height)
        //        view.addSubview(stringImageView)
        
        /// Hide during deveopment. It doesn't allow you to click undearneath the circle
        //        mapView.showsUserLocation = true
        
    }
    
    private func setMapDataDelegate() {
        mapData = MapHelper.getMapData()
    }
    
    private func drawOtaniemi() {
        self.mapData?.area.buildings.forEach {
            building in
            mapView.addAnnotation(building)
            if let marker = building.marker {
                mapView.addAnnotation(marker)
            }
        }
    }
    
    // Remove all floor plan on Map if a new marker is clicked
    private func removeAllAnnotations(){
        mapView.removeAnnotations(mapView.annotations!)
    }
    
    private var zoomLevelObserver: Double = 0.0 {
        didSet {
            if zoomLevelObserver < MapVCConstants.roomMarkerHideZoomLevel {
                hideRoomMarkers()
            } else {
                //                log.debug("show! \(zoomLevelObserver)")
                showRoomMarkers()
            }
        }
    }
    
    private var hiddenRoomMarkersAsArray: [MGLAnnotation]?
    private func hideRoomMarkers(){
        guard hiddenRoomMarkersAsArray == nil else {return}
        hiddenRoomMarkersAsArray = mapView.annotations!.filter{ annotation in
            guard let marker = annotation as? Marker else { return false }
            return marker.type == .Room }
        mapView.removeAnnotations(hiddenRoomMarkersAsArray!)
        setShowRoomMarkerButtonImage(imageName: MapVCConstants.doorButtonGreyFileName)
    }
    
    private func showRoomMarkers(){
        guard let _ = hiddenRoomMarkersAsArray else {return}
        mapView.addAnnotations(hiddenRoomMarkersAsArray!)
        hiddenRoomMarkersAsArray = nil
        setShowRoomMarkerButtonImage(imageName: MapVCConstants.doorButtonBlueFileName)
    }
    
    private func setShowRoomMarkerButtonImage(imageName: String){
        let buttonImage = UIImage(named: imageName)! as UIImage
        showRoomMarkerButton.setImage(buttonImage, for: .normal)
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///////////////////////  Picker delegates   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == floorPicker {
            return floorPickerData.count
        } else {
            return floorDataTypePickerData.count
        }
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == floorPicker {
            return floorPickerData[row]
        } else {
            return floorDataTypePickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == floorPicker {
            getDataForFloorPicker(row: row)
        } else {
            floorDataTypeState = MapVCConstants.floorDataTypesAsArray[row]
            
            setFloorPicker()
        }
    }
    
    private func setFloorViewPolyline(floorNumberAsString: String) {
        guard let floorViews = clickedBuilding?.floorViews , floorDataTypeState == .FloorView else { return }
        
        guard let floorView = floorViews[floorNumberAsString] else { return }
        log.debug("Set new floorView polyline")
        floorViewPolyline = floorView.polyline
        
        log.debug("Is there a tango scanned file?")
    }
    
    func getDataForFloorPicker(row: Int) -> String? {
        /// Manual data VS. Tango data
        let currentFloorNumber = floorPickerData[row]
        
        guard let building = clickedBuilding else { return currentFloorNumber }
        
        switch floorDataTypeState {
        case .Manual where building.floors != nil: roomsDisplayed = building.floors![currentFloorNumber]!.rooms
        case .Tango where building.floorsTango != nil: roomsDisplayed = building.floorsTango![currentFloorNumber]!.rooms
        case .FloorView: setFloorViewPolyline(floorNumberAsString: currentFloorNumber)
        default: roomsDisplayed = [Room]()
        }
        
        return currentFloorNumber
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///////////////////////  MGLAnnotationImage   /////////////////////////
    ///////////////////////////////////////////////////////////////////////
    func getImageForAnnotationFromTitle(title: String) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: title)
        
        if annotationImage == nil {
            guard let image = MapVCHelper.getStrngAsImage(text: title, bounds:view.bounds) else { return nil }
            
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: title)
        }
        return annotationImage
    }
    
    func getImageForAnnotation(annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let marker = annotation as? Marker,
            let title = marker.title
            , marker.type == MarkerType.Room else {
                return nil
        }
        return getImageForAnnotationFromTitle(title: title)
    }
    
    func getImageForAnnotation(annotation: MGLAnnotation, mode: MarkerImageDisplayMode) -> MGLAnnotationImage? {
        
        switch mode {
        case .None: return nil
        case .Test: return getImageForAnnotationFromTitle(title: "WC")
        default: return getImageForAnnotation(annotation: annotation)
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///////////////////////  Mapbox delegates   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let marker = annotation as? Marker , marker.type == MarkerType.Room else {
            return nil
        }
        return getImageForAnnotation(annotation: annotation, mode: .None)
    }
    
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        zoomLevelObserver = mapView.zoomLevel
        //        log.info(zoomLevelObserver)
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        return UIColor.black
        
        //        return UIColor.whiteColor()
    }
    
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        if let _ = annotation as? Building {
            return PolygonType.Outline.color
        } else if let room = annotation as? Room {
            if floorDataTypeState == .FloorView {
                return UIColor.blue
            } else {
                return room.color
            }
        } else {
            return currentRoomColor ?? PolygonType.Default.color
        }
    }
    //    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
    //        
    //    }
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation){
        // Invoked when a marker is clicked
        /*
         1. The clicked marker is hidden
         2. The map is centered to the marker
         3. The floor plan and the floor control buttons are visible.
         */
        guard let marker = annotation as? Marker,
            let building = marker.polygon as? Building else { return }
        
        clickedBuilding = building
        
    }
    
    /// Allow callout view to appear when an annotation is tapped.
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return !(annotation is MGLUserLocation)
        
    }
    
    /// Debug: It returns an empty array
    func mapView(_ mapView: MGLMapView, didAdd annotationViews: [MGLAnnotationView]) {
        let userLocationAnnotationView = annotationViews.filter{
            $0.annotation is MGLUserLocation
            }.first
        guard let _ = userLocationAnnotationView else { return }
        mapView.sendSubview(toBack: userLocationAnnotationView!)
        
        log.debug(annotationViews.count)
    }
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////  Search popOverView   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    
    private var popoverViewAnchor: CGPoint {
        log.debug("searchBar.frame.maxY: \(searchBar.frame.minY), \(searchBar.frame.maxY), \(searchBar.bounds.height) \(searchBar.layer.position.y)")
        
        _ = searchBar.bounds.height + searchBar.layer.position.y// + searchBar.frame.maxY// + 100
        return CGPoint(x: searchBar.bounds.midX, y: 425)
    }
    
    private var popOverBaseViewController: UIViewController?
    
    var isPopoverViewOn = false {
        didSet {
            if !isPopoverViewOn {
                dismissKeyboard()
                //                dismissKeyboard(popOverBaseViewController!.view)
            }
        }
    }
    
    private func showPopoverView(){
        log.verbose("Showing popover view")
        searchView = SearchTableViewController()
        searchView!.modalPresentationStyle = .popover
        searchView!.delegate = self
        
        let searchVC = searchView!.popoverPresentationController
        searchVC?.permittedArrowDirections = []  // Hide arrow
        searchVC?.delegate = self
        
        searchVC?.sourceView = contentViewController.view
        searchVC?.backgroundColor = UIColor.orange
        
        
        /// If there's any presented-view, make that as a presenting-view
        var presentingVC: UIViewController = view.window!.rootViewController!
        while presentingVC.presentedViewController != nil && !presentingVC.presentedViewController!.isBeingDismissed {
            presentingVC = presentingVC.presentedViewController!
        }
        popOverBaseViewController = presentingVC
        //        hideKeyboardWhenTappedAround(popOverBaseViewController!)
        log.debug("showPopoverView() \(view.gestureRecognizers)\n \(popOverBaseViewController!.view.gestureRecognizers)")
        searchVC?.sourceRect = CGRect(
            x: popoverViewAnchor.x,
            y: popoverViewAnchor.y,
            width: 0,
            height: 0)
        presentingVC.present(
            searchView!,
            animated: true,
            completion: nil)
        
        isPopoverViewOn = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        log.verbose("Text did change:\t \(searchText)")
        
        if clickedBuilding?.name != searchText.components(separatedBy: "in:").last {
            clickedBuilding = nil
        }
//        searchText.isEmpty
        if !isPopoverViewOn && searchText != ""{
            log.debug("Show popover View")
            showPopoverView()
        }
        
        searchView?.results = mapData!.area.buildings.filter {
            $0.name.lowercased().contains(searchText.lowercased())
            }.map{ $0.name }
        
        searchView?.tableView.reloadData()
    }
    
    
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        log.debug("Popover view dismissed")
        isPopoverViewOn = false
    }
    
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////  UIButton   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    var showRoomMarkerButton: UIButton!
    
    func showRoomMarkerButtonClicked() {
        /* Case 1: A building is clicked => Zoom in
         * Case 2: No building is clicked => Toast message
         */
        
        if let _ = clickedBuilding {
            /// 0.2 is to ensure that the markers are shown. Exact value, i.e., roomMarkerHideZoomLevel won't be immediately captured in the delegate method
            mapView.setCenter(clickedBuilding!.centerCoordinate!, zoomLevel: MapVCConstants.roomMarkerHideZoomLevel + 0.2, animated: true)
        } else {
            let message = "Click a building in order to see floor plans"
            let position = CGPoint(x: mapView.frame.width/2, y: mapView.frame.height - 40)
            view.makeToast(message, duration: 2.0, position: position)
        }
        
    }
    
    
    func loadShowRoomMarkerButton() {
        
        enum ShowRoomMarkerButtonConstants {
            static var marginRight:CGFloat = 10
            static var marginButtom:CGFloat = 50
        }
        
        let buttonImage = UIImage(named: MapVCConstants.doorButtonGreyFileName)! as UIImage
        
        showRoomMarkerButton = UIButton(type: .custom)
        let x = mapView.frame.width - ShowRoomMarkerButtonConstants.marginRight - buttonImage.size.width
        let y = mapView.frame.height - ShowRoomMarkerButtonConstants.marginButtom - buttonImage.size.height
        showRoomMarkerButton.frame = CGRect(x:x, y:y, width:buttonImage.size.width, height:buttonImage.size.height)
        
        showRoomMarkerButton.addTarget(self, action: #selector(showRoomMarkerButtonClicked), for: .touchUpInside)
        showRoomMarkerButton.layer.cornerRadius = 10
        showRoomMarkerButton.layer.borderWidth = 3
        showRoomMarkerButton.layer.borderColor = UIColor.white.cgColor
        showRoomMarkerButton.clipsToBounds = true
        setShowRoomMarkerButtonImage(imageName: MapVCConstants.doorButtonGreyFileName)
        view.addSubview(showRoomMarkerButton)
        
    }
    
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////  Keyboard shower/hider   ////////////////////////
    ///////////////////////////////////////////////////////////////////////
    
    
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////  Search Bar   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    func loadSearchController(){
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 20, height: searchBar.bounds.height)
        searchBar.layer.position = CGPoint(x: view.bounds.width/2, y: 40)
        
        searchBar.placeholder = "Search building/room"
        searchBar.sizeToFit()
        
        view.addSubview(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clickedBuilding = nil
    }
    
    ///////////////////////////////////////////////////////////////////////
    /////////////////////  Picker   ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    func loadPicker() {
        print("Loadpicker()")
        let height = view.bounds.height/6
        
        //        enum floorPickerGeometry {
        //            static let x: CGFloat = view.bounds.width / 2
        //            static let y: CGFloat = view.bounds.height - height
        //            static let width: CGFloat =  view.bounds.width / 2
        //            static let height: CGFloat = view.bounds.height/6
        //        }
        floorPicker = UIPickerView()
        floorPicker.dataSource = self
        floorPicker.delegate = self
        floorPicker.frame = CGRect(x:view.bounds.width / 2, y:view.bounds.height - height, width:view.bounds.width / 2, height:view.bounds.height/6)
        print("Add sub view")
        view.addSubview(floorPicker)
        
        
        //        enum floorTangoPickerGeometry {
        //            static let x: CGFloat = 0
        //            static let y: CGFloat = view.bounds.height - height
        //            static let width: CGFloat =  view.bounds.width / 2
        //            static let height: CGFloat = view.bounds.height/6
        //        }
        floorDataTypePicker = UIPickerView()
        floorDataTypePicker.dataSource = self
        floorDataTypePicker.delegate = self
        floorDataTypePicker.frame = CGRect(x:0, y:view.bounds.height - height, width:view.bounds.width / 2, height:view.bounds.height/6)
        print("Add sub view")
        view.addSubview(floorDataTypePicker)
        
    }
    
    
    
}

protocol ClickOverMGLMapViewDelegate {
    var view: UIView! { get }
    var searchBar: UISearchBar! { get }
    var mapView: MGLMapView! { get }
    var clickedBuilding: Building? { get set }
    var clickFloorViewButton: UIButton? { get }
    func loadStreetViewImage(index: Int)
}

class TransparentViewOverMGLMapView: UIView {
    
    
    var delegate: ClickOverMGLMapViewDelegate?
    
    private var mapView: MGLMapView? {
        return delegate?.mapView
    }
    
    var floorView: FloorView?
    
    private var floorViewPolyline: MGLPolyline? {
        return floorView?.polyline
    }
    private var polylineCoordinates: [[Double]]? {
        return floorView?.coordinates
    }
    
    private var minimumDistanceIndex: Int?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let index = minimumDistanceIndex else {
            let message = "Click on the path"
            MapVCHelper.showToastMessageAtTheBottom(view: delegate!.view, frame: mapView!.frame, message: message, duration: 1.0)
            return
        }
        
        delegate!.loadStreetViewImage(index: index)
        minimumDistanceIndex = nil
    }
    
    /**
     This is called by UIView.hitTest(point: CGPoint, withEvent event: UIEvent?)
     */
    
    private func pointOutsideSearchBar(point: CGPoint) -> Bool {
        return !delegate!.searchBar.frame.contains(point)
    }
    
    private func pointOutsideClickButton(point: CGPoint) -> Bool {
        return !(delegate!.clickFloorViewButton?.frame.contains(point))! 
    }
    
    private func pointOutsideAllUIElements(point: CGPoint) -> Bool {
        return pointOutsideSearchBar(point: point) && pointOutsideClickButton(point: point)
    }
    
    private func pointInside(point: CGPoint) -> Bool {
        guard let _ = delegate else { return false }
        return self.bounds.contains(point) && pointOutsideAllUIElements(point: point)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var numOfTouches: Int {
            return event?.allTouches?.count ?? 0
        }
        print("👉Transparent Image clicked. #touches: \(numOfTouches)")
        print("    pointOutsideSearchBar: \(pointOutsideSearchBar(point: point))")
        print("    num of coords: \(polylineCoordinates?.count)")
        
        guard let _ = mapView , pointInside(point: point) else { return false }
        let pointAsCoordinate = mapView!.convert(point, toCoordinateFrom: mapView)
        let (minimumDistanceIndex, minimumDistance) = polylineCoordinates!.map{ coords in
            let longitude = coords[0]
            let latitude = coords[1]
            let distance = sqrt(
                pow(pointAsCoordinate.longitude - longitude, 2) +
                    pow(pointAsCoordinate.latitude - latitude, 2)
            )
            return distance
            }.enumerated().reduce((-1, DBL_MAX)) { $0.1 < $1.1 ? $0 : $1 }
        
        let minimumDistanceThreshold: Double = 0.000009
        
        if minimumDistance < minimumDistanceThreshold {
            print("    👉Close enough! \(minimumDistance)")
            self.minimumDistanceIndex = minimumDistanceIndex
        } else {
            print("    👉Click closer! \(minimumDistance)")
        }
        
        
        
        return true
        
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(singleTap)
    }
    
    func dismissKeyboard() {
        log.verbose("Tapped! \n\t CURRENT:\(view) \n\t\t SUPER:\(view.superview!) \n\t\t SUPER.SUB:\(view.superview!.subviews)")
        view.superview?.endEditing(true)
    }
    
}
