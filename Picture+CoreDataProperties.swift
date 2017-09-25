//
//  Picture+CoreDataProperties.swift
//  project25
//
//  Created by Amber Spadafora on 9/25/17.
//  Copyright © 2017 Amber Spadafora. All rights reserved.
//

import Foundation
import CoreData


extension Picture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Picture> {
        return NSFetchRequest<Picture>(entityName: "Picture")
    }

    @NSManaged public var imageData: NSData?

}
