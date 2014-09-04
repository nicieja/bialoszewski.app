//
//  RecordIcon.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import QuartzCore

class RecordIcon: UIButton {

    var circleLayer: RecordIconLayer!
    var angle: CGFloat = 0.00
    
    func setup() {
        layer.masksToBounds = false
        clipsToBounds = true
        
        circleLayer = RecordIconLayer(layer: layer)
        circleLayer.endAngle = 0.0
        circleLayer.startAngle = 0.0
        circleLayer.strokeColor = UIColor.clearColor()
        circleLayer.strokeWidth = 0.0
        circleLayer.fillColor = UIColor.whiteColor()

        circleLayer.frame = bounds
        let circleRadius: CGFloat = CGFloat(-90.0 / 180.0 * M_PI)
        circleLayer.transform = CATransform3DMakeRotation(circleRadius, 0.0, 0.0, 1.0)
        
        layer.addSublayer(circleLayer)
    }

    func animateCircleLayer(progress: CGFloat) {
        // Please don’t ask why
        var newAngle: CGFloat = progress / 18000 * 373.3563995361324
        
        UIView.animateWithDuration(1/60,
            animations: {
                self.circleLayer.setNeedsDisplay()
                
                var revealAnimation: CABasicAnimation = CABasicAnimation(keyPath: "endAngle")
                self.circleLayer.endAngle = newAngle
                self.circleLayer.addAnimation(revealAnimation, forKey: "endAngle")
            },
            completion: nil)
        angle = newAngle
    }
    
    func reset() {
        circleLayer.removeFromSuperlayer()
    }
}
