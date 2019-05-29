//
//  Feature.swift
//  CWall
//
//  Created by Moughon, James on 5/31/19.
//  Copyright © 2019 Texas A&M Transportation Institute. All rights reserved.
//

import UIKit

struct Feature: Codable {
    var id: String!
    var type: String?
    var matching_place_name: String?
    var place_name: String?
    var geometry: Geometry
    var center: [Double]
    var properties: Properties
}

struct Geometry: Codable {
    var type: String?
    var coordinates: [Double]
}

struct Properties: Codable {
    var address: String?
}
