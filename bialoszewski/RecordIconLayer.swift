//
//  RecordIconLayer.swift
//  bialoszewski
//
//  Created by Kamil Nicieja on 03/08/14.
//  Copyright (c) 2014 Kamil Nicieja. All rights reserved.
//

import QuartzCore

class RecordIconLayer: CALayer {

    var startAngle: CGFloat!
    var endAngle: CGFloat!

    var fillColor: UIColor!
    var strokeWidth: CGFloat!
    var strokeColor: UIColor!

    init(layer: AnyObject) {
        super.init(layer: layer)
    }

    override func drawInContext(ctx: CGContextRef) {
        var center: CGPoint = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
        var radius: CGFloat = min(center.x, center.y)

        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, center.x, center.y)

        var floated: Float = Float(startAngle)
        var cosinus: CGFloat = CGFloat(cosf(floated))
        var sinus: CGFloat = CGFloat(sinf(floated))
        var p1: CGPoint = CGPointMake(center.x + radius * cosinus, center.y + radius * sinus)
        CGContextAddLineToPoint(ctx, p1.x, p1.y)

        var clockwise: Int = Int(startAngle > endAngle)
        CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, Int32(clockwise))
    
        CGContextClosePath(ctx)
        
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor)
        CGContextSetLineWidth(ctx, strokeWidth)
        CGContextSetLineCap(ctx, kCGLineCapButt)
        
        CGContextDrawPath(ctx, kCGPathFillStroke)
        
        CGContextBeginPath(ctx)
        CGContextMoveToPoint(ctx, center.x, center.y)
        CGContextAddLineToPoint(ctx, p1.x, p1.y)
        CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, Int32(clockwise))

        CGContextEOClip(ctx)
        
        var image: UIImage = UIImage(named: "Empty.png")
        var mask: CGImageRef = image.CGImage
        
        var imageRect: CGRect = CGRectMake(center.x, center.y, image.size.width, image.size.height)
        CGContextTranslateCTM(ctx, 0, image.size.height)
        CGContextScaleCTM(ctx, 1.0, -1.0)
        CGContextTranslateCTM(ctx, imageRect.origin.x, imageRect.origin.y)
        CGContextRotateCTM(ctx, rad(-90))
        CGContextTranslateCTM(ctx, imageRect.size.width * -0.534, imageRect.size.height * -0.474)

        CGContextDrawImage(ctx, self.bounds, mask)
    }
    
    func rad(degrees: Int) -> CGFloat {
        return (CGFloat(degrees) / (180.0 / CGFloat(M_PI)))
    }
    
}
