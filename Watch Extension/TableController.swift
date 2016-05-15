//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Rentberry on 5/14/16.
//  Copyright © 2016 rentberry. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON
import Foundation

struct RowData {
    let name: String
    let imageName: String
}

class TableController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    let objects: [RowData] = [
        RowData(name: "1", imageName: "house"),
        RowData(name: "2", imageName: "map"),
        RowData(name: "3", imageName: "medal"),
        RowData(name: "4", imageName: "notepad"),
        RowData(name: "5", imageName: "picture"),
        RowData(name: "6", imageName: "settings"),
        RowData(name: "7", imageName: "television"),
        RowData(name: "8", imageName: "trophy")
    ]
    
    struct defaultsKeys {
        static let lessons = "lessons"
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    func getWeek(onComplete: (JSON) -> ()) {
        let baseURL = "https://api.rozklad.org.ua/v2/weeks";
        
        Alamofire.request(.GET, baseURL)
            .responseJSON {response in
                if let data = response.result.value {
                    onComplete(JSON(data))
                }
        }
    }
    
    private func getLessons(onComplete: (JSON) -> ()) {
        let baseURL = "https://api.rozklad.org.ua/v2/groups/607/lessons";
        
        Alamofire.request(.GET, baseURL)
            .responseJSON { response in
                
                if let result = response.result.value {
                    let jsonResult = JSON(result)["data"]
                    onComplete(jsonResult)
                }
        }
    }
    
    func fillTable(lessons: JSON) {
        let rows = lessons.map() { _ in "Row" }
        
        let _self = self
        
        _self.table.setRowTypes(rows)
        print(lessons.count)
        for i in 0 ..< lessons.count {
            let object = lessons[i];
            if let row = _self.table.rowControllerAtIndex(i) as? TableRow {
                row.label.setText(object["lesson_full_name"].string)
                
                row.roomLabel.setText(object["lesson_room"].string)
                row.dayNameLabel.setText(object["day_name"].string)
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let lessons = defaults.stringForKey(defaultsKeys.lessons) {
            if let data = lessons.dataUsingEncoding(NSUTF8StringEncoding) {
                self.fillTable(JSON(data: data))
            }
        } else {
            getLessons { arr in
                let lessons = arr
                
                self.fillTable(lessons)
                
                defaults.setValue(lessons.rawString()!, forKey: defaultsKeys.lessons)
                defaults.synchronize()
                
            }
        }
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
