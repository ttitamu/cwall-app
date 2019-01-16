//
//  ProfileModel.swift
//  CWall
//
//  Created by Moughon, James on 1/10/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit

class ProfileModel {
    var userId : Int = 0
    var userEmail : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var wheelchair : Bool = false
    var visualImpairment : Bool = false
    var hapticFeedback : Bool = true
    var hapticFeedbackHelp : Bool = true
    var betweenStopLimit : Int = 2
    let betweenStopLimitPickerData = [["Short: 1 to 2 blocks", "Medium: 2 to 5 blocks", "Far: 5 to 10 blocks", "Extra Far: 1 mile or more"]]

    //This method sets the initial values.
    init(dict: [String: Any]) {
        self.userId = dict["userId"] as? Int ?? 0
        self.userEmail = dict["userEmail"] as? String ?? ""
        self.firstName = dict["firstName"] as? String ?? ""
        self.lastName = dict["lastName"] as? String ?? ""
        self.wheelchair = dict["wheelchair"] as? Bool ?? false
        self.visualImpairment = dict["visualImpairment"] as? Bool ?? false
        self.hapticFeedback = dict["hapticFeedback"] as? Bool ?? true
        self.hapticFeedbackHelp = dict["hapticFeedbackHelp"] as? Bool ?? true
        self.betweenStopLimit = dict["betweenStopLimit"] as? Int ?? 2
    }

    func returnDict() {

    }
}
