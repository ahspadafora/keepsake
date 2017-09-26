//
//  Picture+CoreDataClass.swift
//  project25
//
//  Created by Amber Spadafora on 9/25/17.
//  Copyright © 2017 Amber Spadafora. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Picture)
public class Picture: NSManagedObject {
    func uiImage() -> UIImage {
        guard let image = UIImage(data: self.imageData! as Data) else {
            return UIImage()
        }
        return image
    }
}
