//
//  ViewController.swift
//  MPGTextField-Swift
//
//  Created by Gaurav Wadhwani on 08/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MPGTextFieldDelegate {
    
    var sampleData = [Dictionary<String, AnyObject>]()
    @IBOutlet var name : MPGTextField_Swift!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.generateData()
        name.mpgTextFieldDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateData() {
        var err : NSErrorPointer = NSErrorPointer()
        var dataPath = NSBundle.mainBundle().pathForResource("sample_data", ofType: "json")
        var data = NSData(contentsOfFile: dataPath!, options: NSDataReadingOptions.DataReadingUncached, error: err)
        var contents :[AnyObject]! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: err) as! [AnyObject]
        for datum in contents {
            var name = datum["first_name"] as! String
            var lName = datum["last_name"] as! String
            name += " " + lName
            var email = datum["email"] as! String
            var dictionary = ["DisplayText":name,"DisplaySubText":email,"CustomObject":datum]
            sampleData.append(dictionary)
        }
    }

    // MARK: MPGTextFieldDelegate
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return sampleData
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }

    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>) {
        println("Dictionary received = \(data)")
    }
}

