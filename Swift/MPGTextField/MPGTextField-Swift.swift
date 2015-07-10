//
//  MPGTextField-Swift.swift
//  MPGTextField-Swift
//
//  Created by Gaurav Wadhwani on 08/06/14.
//  Copyright (c) 2014 Mappgic. All rights reserved.
//

import UIKit

@objc protocol MPGTextFieldDelegate {
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>]
    
    optional func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>)
    optional func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool
}

class MPGTextField_Swift: UITextField, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var mpgTextFieldDelegate : MPGTextFieldDelegate?
    var tableViewController : UITableViewController?
    var data = [Dictionary<String, AnyObject>]()
    
    //Set this to override the default color of suggestions popover. The default color is [UIColor colorWithWhite:0.8 alpha:0.9]
    @IBInspectable var popoverBackgroundColor : UIColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    
    //Set this to override the default frame of the suggestions popover that will contain the suggestions pertaining to the search query. The default frame will be of the same width as textfield, of height 200px and be just below the textfield.
    @IBInspectable var popoverSize : CGRect?
    
    //Set this to override the default seperator color for tableView in search results. The default color is light gray.
    @IBInspectable var seperatorColor : UIColor = UIColor(white: 0.95, alpha: 1.0)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let str : String = self.text
        
        if count(str) > 0 && self.isFirstResponder() {
            if mpgTextFieldDelegate != nil {
                data = mpgTextFieldDelegate!.dataForPopoverInTextField(self)
                self.provideSuggestions()
            }
            else {
                println("mpgTextFieldDelegate is nil")
            }
        }
    }
    
    func createTableView() {
        tableViewController = UITableViewController.alloc()
        tableViewController!.tableView.delegate = self
        tableViewController!.tableView.dataSource = self
        tableViewController!.tableView.backgroundColor = popoverBackgroundColor
        tableViewController!.tableView.separatorColor = seperatorColor
        if let frameSize = popoverSize {
            self.tableViewController!.tableView.frame = frameSize
        }
        else {
            //PopoverSize frame has not been set. Use default parameters instead.
            var frameForPresentation = frame
            frameForPresentation.origin.y += frame.size.height
            frameForPresentation.size.height = 200
            tableViewController!.tableView.frame = frameForPresentation
        }
        
        var frameForPresentation = frame
        frameForPresentation.origin.y += frame.size.height;
        frameForPresentation.size.height = 200;
        tableViewController!.tableView.frame = frameForPresentation
        superview!.addSubview(tableViewController!.tableView)
    }
    
    func createGestureRecognizer() {
        //Add a tap gesture recogniser to dismiss the suggestions view when the user taps outside the suggestions view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "didTouchSuperview:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        self.superview!.addGestureRecognizer(tapRecognizer)
    }
    
    func showSuggestions() {
        if tableViewController == nil {
            createTableView()
            createGestureRecognizer()
        }
        tableViewController!.tableView.reloadData()
        UIView.animateWithDuration(0.3,
            animations: ({
                self.tableViewController!.tableView.alpha = 1.0
            }),
            completion :{
                (finished : Bool) in
        })
    }
    
    func hideSuggestions() {
        if tableViewController != nil {
            UIView.animateWithDuration(0.3,
                animations: ({
                    self.tableViewController!.tableView.alpha = 0.0
                }),
                completion:{
                    (finished : Bool) in
            })
        }
    }
    
    override func resignFirstResponder() -> Bool {
        hideSuggestions()
        return super.resignFirstResponder()
    }
    
    func provideSuggestions() {
        if self.applyFilterWithSearchQuery(self.text).count > 0 {
            showSuggestions()
        }
        else {
            hideSuggestions()
        }
    }
    
    func didTouchSuperview(sender : UIGestureRecognizer!) {
        if let table = self.tableViewController {
            if !CGRectContainsPoint(table.tableView.frame, sender.locationInView(self.superview)) && self.isFirstResponder() {
                self.resignFirstResponder()
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = self.applyFilterWithSearchQuery(self.text).count
        if count == 0 {
            UIView.animateWithDuration(0.3,
                animations: ({
                    self.tableViewController!.tableView.alpha = 0.0
                }),
                completion:{
                    (finished : Bool) in
                    if let table = self.tableViewController {
                        table.tableView.removeFromSuperview()
                        self.tableViewController = nil
                    }
            })
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MPGResultsCell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MPGResultsCell")
        }
        
        cell!.backgroundColor = UIColor.clearColor()
        let dataForRowAtIndexPath = self.applyFilterWithSearchQuery(self.text)[indexPath.row]
        let displayText : AnyObject? = dataForRowAtIndexPath["DisplayText"]
        let displaySubText : AnyObject? = dataForRowAtIndexPath["DisplaySubText"]
        cell!.textLabel!.text = displayText as? String
        cell!.detailTextLabel!.text = displaySubText as? String
        
        return cell!
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedData = self.applyFilterWithSearchQuery(self.text)[indexPath.row]
        self.text = selectedData["DisplayText"] as! String
        mpgTextFieldDelegate?.textFieldDidEndEditing?(self, withSelection: selectedData)
        self.resignFirstResponder()
    }
    
    // MARK: Filter Method
    func applyFilterWithSearchQuery(filter : String) -> [Dictionary<String, AnyObject>] {
        var lower = (filter as NSString).lowercaseString
        var filteredData = data.filter({
            if let match : AnyObject  = $0["DisplayText"] {
                return (match as! NSString).lowercaseString.hasPrefix((filter as NSString).lowercaseString)
            }
            else {
                return false
            }
        })
        return filteredData
    }
}
