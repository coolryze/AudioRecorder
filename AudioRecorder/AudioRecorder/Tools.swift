//
//  Tools.swift
//  AudioRecorder
//
//  Created by heyuze on 2017/11/6.
//  Copyright © 2017年 heyuze. All rights reserved.
//

import UIKit

extension UIImage {
    
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let canvas = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(canvas.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(canvas)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!, scale: image!.scale, orientation: image!.imageOrientation)
    }
}

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat) {
        self.init(red: CGFloat((hex & 0xff0000) >> 16) / 255,
                  green: CGFloat((hex & 0xff00) >> 8) / 255,
                  blue: CGFloat(hex & 0xff) / 255,
                  alpha: alpha)
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
}
