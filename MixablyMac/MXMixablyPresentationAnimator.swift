//
//  MXMixablyPresentationAnimator.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 9/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import pop

protocol MXMixablyPresentationController {
    var viewToShrink:NSView { get }
}

final class MXMixablyPresentationAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    let translationAnimationKey = "translate"
    let scaleAnimationKey = "scale"
    
    func animatePresentationOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let fromVC = fromViewController
        let toVC = viewController
        
        // Add view
        fromVC.view.addSubview(toVC.view)
        
        // Set frame
        toVC.view.frame = fromVC.view.frame.offsetBy(dx: 0, dy: -fromVC.view.frame.height)
        
        // Setup view to shrink
        let viewToShrink = (fromVC as? MXMixablyPresentationController)?.viewToShrink
        viewToShrink?.layer?.moveAnchorPoint(CGPointMake(0.5, 0.5))
        
        // Animate shrinking
        let scale:CGFloat = 0.5
        let toSizeValue = NSValue(size: CGSizeMake(scale, scale))
        if let anim = viewToShrink?.layer?.pop_animationForKey(scaleAnimationKey) as? POPSpringAnimation {
            anim.toValue = toSizeValue
        } else {
            let shrinkAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            shrinkAnim.toValue = toSizeValue
            viewToShrink?.layer?.pop_addAnimation(shrinkAnim, forKey: scaleAnimationKey)
        }
        
        // Animate slide in
        let toRectValue = NSValue(rect: fromVC.view.frame)
        if let anim = toVC.pop_animationForKey(translationAnimationKey) as? POPSpringAnimation {
            anim.toValue = toRectValue
            anim.completionBlock = nil
        } else {
            let translateAnim = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            translateAnim.toValue = toRectValue
            toVC.view.pop_addAnimation(translateAnim, forKey: translationAnimationKey)
        }
        
    }
    
    func animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let toVC = fromViewController
        let fromVC = viewController
        
        let viewToShrink = (toVC as? MXMixablyPresentationController)?.viewToShrink
        
        // Animate growing
        let toSizeValue = NSValue(size: CGSizeMake(1, 1))
        if let anim = viewToShrink?.layer?.pop_animationForKey(scaleAnimationKey) as? POPSpringAnimation {
            anim.toValue = toSizeValue
        } else {
            let growAnim = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
            growAnim.toValue = toSizeValue
            viewToShrink?.layer?.pop_addAnimation(growAnim, forKey: scaleAnimationKey)
        }
        
        // Animate slide out
        let toRectValue = NSValue(rect: fromVC.view.frame.offsetBy(dx: 0, dy: -fromVC.view.frame.height))
        if let anim = fromVC.view.pop_animationForKey(translationAnimationKey) as? POPSpringAnimation {
            anim.toValue = toRectValue
        } else {
            let translateAnim = POPSpringAnimation(propertyNamed: kPOPViewFrame)
            translateAnim.toValue = toRectValue
            translateAnim.completionBlock = { anim, finished in
                fromVC.view.removeFromSuperview()
            }
            fromVC.view.pop_addAnimation(translateAnim, forKey: translationAnimationKey)
        }
    }
}
