//
//  CGSize+AspectFunctions.swift
//  OCTGNPlayer
//
//  Created by Greg Langmead on 3/2/19.
//  Copyright © 2019 Greg Langmead. All rights reserved.
//

import UIKit
import Foundation

extension CGSize {
    static func aspectFit(originalSize : CGSize, boundingSize: CGSize) -> CGSize {
        let horizRatio = boundingSize.width / originalSize.width
        let vertRatio = boundingSize.height / originalSize.height
        return CGSize(width: originalSize.width * min(horizRatio, vertRatio), height: originalSize.height * min(horizRatio, vertRatio))
    }
    
    func maxDim() -> CGFloat {
        return max(self.width, self.height)
    }

}

