//
//  NSTouch+pos.swift
//  timrp
//
//  Created by 広野雅織 on 2017/06/05.
//  Copyright © 2017年 Masaori Hirono. All rights reserved.
//

import Foundation
import Cocoa

extension NSTouch {
    /**
     * Returns the relative position of the touch to the view
     * NOTE: the normalizedTouch is the relative location on the trackpad. values range from 0-1. And are y-flipped
     * TODO: debug if the touch area is working with a rect with a green stroke
     */
    func pos(_ view:NSView) -> CGPoint{
        let w = view.frame.size.width
        let h = view.frame.size.height
        let touchPos:CGPoint = CGPoint(x: self.normalizedPosition.x, y: self.normalizedPosition.y)/*flip the touch coordinates*/
        let deviceSize:CGSize = self.deviceSize
        let deviceRatio:CGFloat = deviceSize.width/deviceSize.height/*find the ratio of the device*/
        let viewRatio:CGFloat = w/h
        var touchArea:CGSize = CGSize(width: w, height: h)
        /*Uniform-shrink the device to the view frame*/
        if(deviceRatio > viewRatio){/*device is wider than view*/
            touchArea.height = h/viewRatio
            touchArea.width = w
        }else if(deviceRatio < viewRatio){/*view is wider than device*/
            touchArea.height = h
            touchArea.width = w/deviceRatio
        }/*else ratios are the same*/
        let touchAreaPos:CGPoint = CGPoint(x: (w - touchArea.width)/2, y: (h - touchArea.height)/2)/*we center the touchArea to the View*/
        return CGPoint(x: touchPos.x * touchArea.width + touchAreaPos.x, y: touchPos.y * touchArea.height + touchAreaPos.y)
    }
}
