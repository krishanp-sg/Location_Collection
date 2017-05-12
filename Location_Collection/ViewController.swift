//
//  ViewController.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 26/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onStartLocation(_ sender: Any) {
    
        let locationVC = LocationViewController()
        self.navigationController?.pushViewController(locationVC, animated: true)
        
    }
}

