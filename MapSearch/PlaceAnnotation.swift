/*
 Copyright © 2018 Apple Inc.

 Abstract:
 Custom pin annotation for display found places.
 */

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    /*
     This property is declared with `@objc dynamic` to meet the API requirement that the coordinate property on all MKAnnotations
     must be KVO compliant.
     */
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var url: URL?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
