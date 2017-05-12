//
//  Location+CoreDataProperties.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 27/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var collectedTime: NSDate?
    @NSManaged public var collectedTimeInHumanReadable: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var accuracy: Int16
    
    
    func isEqualToCoreLocation(_ location : CLLocation) -> Bool{
        var isEqual : Bool = false
        
        if(location.coordinate.latitude == self.latitude && location.coordinate.longitude == self.longitude && location.timestamp.timeIntervalSince(self.collectedTime as! Date) <= 10) {
            isEqual = true
        }
        
        
        return isEqual
    }

}
