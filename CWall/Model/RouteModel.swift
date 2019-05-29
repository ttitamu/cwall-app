//
//  RouteModel.swift
//  CWall
//
//  Created by Moughon, James on 5/24/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import Foundation

class Route {
    var status: String = ""
    var arrivalDateTime: String = ""
    var departureDateTime: String = ""
    var requestedDateTime: String = ""
    var type: String = ""
    var duration: Int = 0
    var sections: Array<Any>
    
    init(dict: [String: Any]) {
        
    }
}
