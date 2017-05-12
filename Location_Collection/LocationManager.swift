//
//  LocationManager.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 26/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
   private static let REGION_IDENTIFIER = "IDLERegion"
   private static let REGION_RADIUS = 100.0
    
    static let  sharedManager = LocationManager()
    
    let distanceFiter = 50.0
    
    fileprivate var locaitonManager : CLLocationManager = CLLocationManager()
    fileprivate var locationShareModel = LocationShareModel()
    fileprivate var isAppInBackground : Bool = false
    fileprivate var isSignificantLocationUpdate : Bool = false
    fileprivate var regionToMonitor : CLRegion?
    
    required override init() {
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        // App will Enter Background
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // App Will Enter Foreground
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        // App Will Terminate
        
         notificationCenter.addObserver(self, selector: #selector(appWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    
    }
    
    func startLocationUpdate() {
        isSignificantLocationUpdate = false
        setupLocationManager()
        startLocationManager()
    }
    
    func startLocationManager(){
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locaitonManager.requestAlwaysAuthorization()
        }else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            self.locaitonManager.startUpdatingLocation()
        }
    }
    
    
    func setupLocationManager() {
        self.locaitonManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locaitonManager.distanceFilter = distanceFiter
        self.locaitonManager.delegate = self
        self.locaitonManager.allowsBackgroundLocationUpdates = true;
    }
    
    
    func stopLocationManagerAfter10s(){
        print("Stopping Location Update")
        self.locaitonManager.stopUpdatingLocation()
    }
    
    func stopSignificantLocationUpdate(){
        isSignificantLocationUpdate = false
        isAppInBackground = true
        self.locaitonManager.stopMonitoringSignificantLocationChanges()
    }
    
    func restartLocationUpdate() {
        print("Restarting Location Update")
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if isSignificantLocationUpdate {
            stopSignificantLocationUpdate()
        }
        
        self.locaitonManager.stopUpdatingLocation()
        startLocationManager()
    }
    
    // Request location update will fire only once
    func requestLocationUpdate(){
        print("Request Location Update")
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if isSignificantLocationUpdate {
            stopSignificantLocationUpdate()
        }
        
        self.locaitonManager.stopUpdatingLocation()
        
        self.locaitonManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locaitonManager.distanceFilter = distanceFiter
        self.locaitonManager.delegate = self
        self.locaitonManager.allowsBackgroundLocationUpdates = true;
        self.locaitonManager.requestAlwaysAuthorization()
        self.locaitonManager.requestLocation()

    }
    
    func startSignificantChangeLocationUpdates() {
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        isSignificantLocationUpdate = true
        
        self.locaitonManager = CLLocationManager()
        self.locaitonManager.delegate = self
        self.locaitonManager.startMonitoringSignificantLocationChanges()
    }
    
    func appMovedToBackground(){
        print("Application Moved To Background")
        isAppInBackground = true
        self.locaitonManager.stopUpdatingLocation()
        self.locaitonManager.startUpdatingLocation()
        self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
        self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
    }
    
    func appMovedToForeground() {
        print("Applicaiton Moved To Foreground")
        isAppInBackground = false
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if isSignificantLocationUpdate {
            stopSignificantLocationUpdate()
        }
        
        if let region = regionToMonitor {
            self.locaitonManager.stopMonitoring(for: region)
        }
        
        self.locaitonManager.stopUpdatingLocation()
        startLocationUpdate()
    }
    
    func appWillTerminate(){
        print("Application Will Terminate")
        isAppInBackground = true
        
        self.locaitonManager.stopUpdatingLocation()
        
        startSignificantChangeLocationUpdates()
        
    }
    
    func setupRegionToMonitor(_ iDleLocation : CLLocation){
        
        print("Setting Up Region Monitor")
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        isSignificantLocationUpdate = false
        isAppInBackground = true
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            
            regionToMonitor = CLCircularRegion(center: iDleLocation.coordinate, radius: LocationManager.REGION_RADIUS, identifier: LocationManager.REGION_IDENTIFIER)
            self.locaitonManager.startMonitoring(for: regionToMonitor!)
        }
        
        
    }
    
}


extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways {
            print("Location Manager Permission Given")
            self.locaitonManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if isAppInBackground {
            
            if locationShareModel.backgroundTimer != nil{
                return
            }
            
            self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
            self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
            
            self.locationShareModel.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(requestLocationUpdate), userInfo: nil, repeats: false)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Updated")
        
        // If the user is IDLE for 5 minutes turn off the location and Start Significant location update. 
        if let lastUserLocation = LocationDataAccess.getLastInsertedUserLocation(), isAppInBackground {
            
            let lastLocation : CLLocation = CLLocation(latitude: lastUserLocation.latitude, longitude: lastUserLocation.longitude)
            
            // if Distance Between location is less than 100m and time difference is greater than 5 minute turn off GPS
            
            if locations.last!.distance(from: lastLocation) < 100 && locations.last!.timestamp.timeIntervalSince(lastUserLocation.collectedTime as! Date) > 300 {
                
                stopLocationManagerAfter10s()
//                startSignificantChangeLocationUpdates()
                
                setupRegionToMonitor(locations.last!)
                
                return
            }
        
        } 
        
        LocationDataAccess.insertLocationToDataBase(userLocation: locations.last!)
        
        
        if isAppInBackground {
            
            print("Application is in Background")
        
            if locationShareModel.backgroundTimer != nil{
                return
            }
            
            self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
            self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
            
            self.locationShareModel.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(restartLocationUpdate), userInfo: nil, repeats: false)
           
            
            if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
                self.locationShareModel.stopLocationManagerAfter10sTimer?.invalidate()
                self.locationShareModel.stopLocationManagerAfter10sTimer = nil
            }
            
            
            self.locationShareModel.stopLocationManagerAfter10sTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(stopLocationManagerAfter10s), userInfo: nil, repeats: false)
            

        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User Entered In to The region")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User Left The Region")
        // TODO : User have exits the idle position. Stop monitoring region and remove the existing regions. and start location update.
        
        self.locaitonManager.stopMonitoring(for: regionToMonitor!)
        self.startLocationUpdate()
        self.appMovedToBackground()
        
    }
}
