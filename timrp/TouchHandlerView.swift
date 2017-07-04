//
//  TouchHandlerView.swift
//  timrp
//
//  Created by 広野雅織 on 2017/06/05.
//  Copyright © 2017年 Masaori Hirono. All rights reserved.
//

import Cocoa

class TouchHandlerView: NSView {
    var onCharacterUpdated: ((Int) -> Void)? = nil

    var activeTouches = Set<NSTouch>()
    var referencePoint: CGPoint?
    var bisectors: [CGPoint] = []
    var currentCharacter: Int = 0;

    var debug_pointsA: [CGPoint] = []
    var debug_pointsB: [CGPoint] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Swift.print("init frame", frameRect)
        self.acceptsTouchEvents = true
        self.wantsRestingTouches = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Swift.print("init coder", coder)
        self.acceptsTouchEvents = true
        self.wantsRestingTouches = true
    }

    override func touchesBegan(with event: NSEvent) {
        self.extractTouchFrom(event: event)
    }

    override func touchesMoved(with event: NSEvent) {
        self.extractTouchFrom(event: event)
    }

    override func touchesEnded(with event: NSEvent) {
        self.extractTouchFrom(event: event)
    }

    override func touchesCancelled(with event: NSEvent) {
        self.activeTouches = Set<NSTouch>()
        self.needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.darkGray.setFill()
        NSRectFill(dirtyRect)

        var text = ""
        if self.currentCharacter > 0 {
            text.append(Character(UnicodeScalar(self.currentCharacter)!))
        }
        self.drawText(text: text, rect: dirtyRect)

        NSColor.lightGray.set()
        let diameter = CGFloat(10.0);
        for touch in self.activeTouches {
            self.drawMark(
                pos: touch.pos(self),
                diameter: diameter,
                color: NSColor.lightGray,
                stroke: touch.isResting
            )
        }
        if let referencePoint = self.referencePoint {
            self.drawMark(
                pos: referencePoint,
                diameter: diameter * 2,
                color: NSColor.red,
                stroke: false
            )
            for bisector in bisectors {
                self.drawLine(
                    posA: referencePoint,
                    posB: bisector,
                    color: NSColor.blue
                )
            }

//            for p in self.debug_pointsA {
//                self.drawLine(
//                    posA: referencePoint,
//                    posB: p,
//                    color: NSColor.yellow
//                )
//            }
//            for p in debug_pointsB {
//                self.drawLine(
//                    posA: referencePoint,
//                    posB: p,
//                    color: NSColor.green
//                )
//            }
        }
    }

    private func drawMark(pos: CGPoint, diameter: CGFloat, color: NSColor, stroke: Bool) {
        color.set()
        let path = NSBezierPath(ovalIn: NSMakeRect(pos.x - diameter / 2, pos.y - diameter / 2, diameter, diameter))
        path.lineWidth = 2.0
        stroke ? path.stroke() : path.fill()
    }

    private func drawLine(posA: CGPoint, posB: CGPoint, color: NSColor) {
        color.set()
        let path = NSBezierPath()
        path.move(to: posA)
        path.line(to: posB)
        path.lineWidth = 1.0
        path.stroke()
    }

    private func drawText(text: String, rect: NSRect) {
        let font = NSFont(name: "Helvetica Bold", size: 200.0)
        if let actualFont = font {
            let textFontAttributes = [
                NSFontAttributeName: actualFont,
                NSForegroundColorAttributeName: NSColor.black,
                NSParagraphStyleAttributeName: NSMutableParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
            ]

            text.draw(in: NSOffsetRect(rect, 0, 1), withAttributes: textFontAttributes)
        }
    }

    private func extractTouchFrom(event: NSEvent) {
        self.activeTouches = event.touches(matching: .touching, in: nil)
        if self.activeTouches.count == 5 {
            calculateRegions()
        }
        if self.referencePoint != nil {
            self.currentCharacter = self.activeTouches.map({ (touch: NSTouch) -> Int in
                return self.convertPositionToFingerId(touchPos: touch.pos(self))
            }).reduce(0, { ret, finger in
                return Int(CGFloat(ret) + pow(2.0, CGFloat(finger)))
            })
            if let onCharacterUpdated = self.onCharacterUpdated {
                onCharacterUpdated(self.currentCharacter)
            }
        }
        self.needsDisplay = true
    }

    private func calculateRegions() -> Void {
        let poses = self.activeTouches.map({ (touch: NSTouch) -> CGPoint in
            return touch.pos(self)
        })
        let sum = poses.reduce(CGPoint(x: 0, y: 0), { ret, pos in
            let next = CGPoint(x: ret.x + pos.x, y: ret.y + pos.y)
            return next
        })
        self.referencePoint = CGPoint(x: sum.x / 5, y: sum.y / 5 - 200.0)

        let referencePoint = self.referencePoint!
        let thetas = poses.map(self.calculateAngle(from: referencePoint)).sorted()
        self.bisectors = []
        self.debug_pointsA = []
        self.debug_pointsB = []
        for index in 0..<thetas.count {
            let nextIndex = (index + 1) % thetas.count
            let thetaA = thetas[index]
            let thetaB = thetas[nextIndex]
            var thetaAB: CGFloat
            if thetaA <= thetaB {
                thetaAB = (thetaA + thetaB) / 2.0
            } else {
                thetaAB = (thetaA - 2.0 * CGFloat.pi + thetaB) / 2.0
            }

            let pAB = CGPoint(x: cos(thetaAB), y: sin(thetaAB))
            self.bisectors.append(CGPoint(x: pAB.x * CGFloat(1000.0) + referencePoint.x, y: pAB.y * CGFloat(1000.0) + referencePoint.y))

            //                let pA = CGPoint(x: cos(thetaA), y: sin(thetaA))
            //                let pB = CGPoint(x: cos(thetaB), y: sin(thetaB))
            //                self.debug_pointsA.append(CGPoint(x: pA.x * CGFloat(1000.0) + referencePoint.x, y: pA.y * CGFloat(1000.0) + referencePoint.y))
            //                self.debug_pointsB.append(CGPoint(x: pB.x * CGFloat(1000.0) + referencePoint.x, y: pB.y * CGFloat(1000.0) + referencePoint.y))
        }
    }

    private func calculateAngle(from referencePoint: CGPoint) -> (_ pos: CGPoint) -> CGFloat {
        return { pos -> CGFloat in
            let base = pos.x - referencePoint.x // signed length of a base
            let opposite = pos.y - referencePoint.y // signed length of a opposite side
            let hypotenuse = sqrt(pow(pos.x - referencePoint.x, 2) + pow(pos.y - referencePoint.y, 2)) // length of a hypotenuse
            var theta = acos(base / hypotenuse)
            if opposite < 0 {
                theta = 2.0 * CGFloat.pi - theta
            }
            return theta
        }
    }

    private func convertPositionToFingerId(touchPos: CGPoint) -> Int {
        let referencePoint = self.referencePoint!
        let calculateAngle = self.calculateAngle(from: referencePoint)
        let theta = calculateAngle(touchPos);
        for index in 0..<self.bisectors.count {
            var fromTheta = calculateAngle(self.bisectors[index == 0 ? self.bisectors.count - 1 : index - 1])
            let toTheta = calculateAngle(self.bisectors[index])
            if fromTheta > toTheta {
                fromTheta -= 2.0 * CGFloat.pi
            }
            if fromTheta <= theta && theta < toTheta {
                return self.bisectors.count - (index + 1)
            }
        }
        return -1;
    }

}
