//
//  CGPoint+Hashable.swift
//  timrp
//
//  Created by 広野雅織 on 2017/06/05.
//  Copyright © 2017年 Masaori Hirono. All rights reserved.
//

import Foundation

extension CGPoint : Hashable {
    func distance(point: CGPoint) -> Float {
        let dx = Float(x - point.x)
        let dy = Float(y - point.y)
        return sqrt((dx * dx) + (dy * dy))
    }
    public var hashValue: Int {
        return x.hashValue << 32 ^ y.hashValue
    }
}

func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
    return lhs.distance(point: rhs) < 0.000001 //CGPointEqualToPoint(lhs, rhs)
}
