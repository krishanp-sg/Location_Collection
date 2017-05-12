//
//  CommonHelper.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 27/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit

class CommonHelper: NSObject {
    
    static func convertDateToString(dateToConvert : Date) -> String {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        let myStringafd = formatter.string(from: yourDate!)
        
        return myStringafd
    }

}
