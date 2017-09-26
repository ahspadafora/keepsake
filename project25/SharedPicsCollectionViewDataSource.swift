//
//  SharedPicsCollectionViewDataSource.swift
//  project25
//
//  Created by Amber Spadafora on 9/25/17.
//  Copyright © 2017 Amber Spadafora. All rights reserved.
//

import Foundation
import UIKit

class SharedPicsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    var images: [UIImage] = []
    var cellIdentifier = "ImageView"
    
    init(images: [UIImage], cellIdentifier: String) {
        self.images = images
        self.cellIdentifier = cellIdentifier
        
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            
            imageView.image = images[indexPath.row]
        }
        return cell
    }
}
