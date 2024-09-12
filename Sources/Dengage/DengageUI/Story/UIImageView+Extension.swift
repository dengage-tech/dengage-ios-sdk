

import Foundation
import UIKit

extension UIImageView {
    
    struct ActivityIndicator {
        static var isEnabled = false
        static var style = _style
        static var view = _view
        
        static var _style: UIActivityIndicatorView.Style {
            if #available(iOS 13.0, *) {
                return .large
            } else {
                return .whiteLarge
            }
        }
        
        static var _view: UIActivityIndicatorView {
            if #available(iOS 13.0, *) {
                return UIActivityIndicatorView(style: .large)
            } else {
                return UIActivityIndicatorView(style: .whiteLarge)
            }
        }
    }
    
    public var isActivityEnabled: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
                return false
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self, &ActivityIndicator.isEnabled, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityStyle: UIActivityIndicatorView.Style {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ActivityIndicator.style)
                    as? UIActivityIndicatorView.Style
            else {
                if #available(iOS 13.0, *) {
                    return .large
                } else {
                    return .whiteLarge
                }
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self, &ActivityIndicator.style, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityIndicator: UIActivityIndicatorView {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ActivityIndicator.view)
                    as? UIActivityIndicatorView
            else {
                if #available(iOS 13.0, *) {
                    return UIActivityIndicatorView(style: .large)
                } else {
                    return UIActivityIndicatorView(style: .whiteLarge)
                }
            }
            return value
        }
        set(newValue) {
            let activityView = newValue
            activityView.hidesWhenStopped = true
            objc_setAssociatedObject(
                self, &ActivityIndicator.view, activityView,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showActivityIndicator(bgColors: [UIColor] = []) {
        if isActivityEnabled {
            var isActivityIndicatorFound = false
            DispatchQueue.main.async {
                let colors = bgColors.count == 0 ? [UIColor.black]: bgColors
                //print("colors", colors)
                
                
                if colors.count == 1 {
                    self.backgroundColor = colors.first

                } else {
                    self.backgroundColor = UIColor.fromGradientWithDirection(.topToBottom, frame: self.frame, colors: colors)
                }
                
                

                
                //self.backgroundColor = .orange
                self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                if self.subviews.isEmpty {
                    isActivityIndicatorFound = false
                    self.addSubview(self.activityIndicator)
                    
                } else {
                    for view in self.subviews {
                        if !view.isKind(of: UIActivityIndicatorView.self) {
                            isActivityIndicatorFound = false
                            self.addSubview(self.activityIndicator)
                            break
                        } else {
                            isActivityIndicatorFound = true
                        }
                    }
                }
                if !isActivityIndicatorFound {
                    NSLayoutConstraint.activate([
                        self.activityIndicator.sCenterXAnchor.constraint(equalTo: self.sCenterXAnchor),
                        self.activityIndicator.sCenterYAnchor.constraint(equalTo: self.sCenterYAnchor),
                    ])
                }
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    func hideActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.subviews.forEach({ (view) in
                    if let av = view as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }
    }
}

public enum StoryResult<V, E> {
    case success(V)
    case failure(E)
}


extension UIImage {
    static func drawCrossImage(size: CGSize, lineColor: UIColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.beginPath()
        context.move(to: .zero)
        context.addLine(to: CGPoint(x: size.width, y: size.height))
        context.move(to: CGPoint(x: size.width, y: 0))
        context.addLine(to: CGPoint(x: 0, y: size.height))
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func drawCircularCrossImage(size: CGSize, lineColor: UIColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let radius = min(size.width, size.height) / 2 - lineWidth / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        context.beginPath()
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.addArc(
            center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        context.strokePath()
        let crossInset: CGFloat = size.width / 4
        context.beginPath()
        context.move(to: CGPoint(x: center.x - crossInset, y: center.y - crossInset))
        context.addLine(to: CGPoint(x: center.x + crossInset, y: center.y + crossInset))
        context.move(to: CGPoint(x: center.x + crossInset, y: center.y - crossInset))
        context.addLine(to: CGPoint(x: center.x - crossInset, y: center.y + crossInset))
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
