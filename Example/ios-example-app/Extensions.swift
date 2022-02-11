
import UIKit
public extension UIView {
    
    func fillSuperview(with equalPadding: CGFloat) {
        let insets = UIEdgeInsets(top: equalPadding,
                                  left: equalPadding,
                                  bottom: equalPadding,
                                  right: equalPadding)
        fillSuperview(with: insets)
    }

    func fillSuperview(horizontalPadding: CGFloat,
                       verticalPadding: CGFloat) {
        fillSuperview(with: UIEdgeInsets(top: verticalPadding,
                                         left: horizontalPadding,
                                         bottom: verticalPadding,
                                         right: horizontalPadding))
    }

    func fillSuperview(with padding: UIEdgeInsets = .zero) {
        anchor(top: superview?.topAnchor,
               leading: superview?.leadingAnchor,
               bottom: superview?.bottomAnchor,
               trailing: superview?.trailingAnchor,
               topPadding: padding.top,
               leadingPadding: padding.left,
               bottomPadding: padding.bottom,
               trailingPadding: padding.right)
    }

    func fillSafeArea(with padding: UIEdgeInsets = .zero) {
        anchor(top: superview?.safeAreaTopAnchor,
               leading: superview?.safeAreaLeadingAnchor,
               bottom: superview?.safeAreaBottomAnchor,
               trailing: superview?.safeAreaTrailingAnchor,
               topPadding: padding.top,
               leadingPadding: padding.left,
               bottomPadding: padding.bottom,
               trailingPadding: padding.right)
    }

    func anchor(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, topPadding: CGFloat = 0, leadingPadding: CGFloat = 0, bottomPadding: CGFloat = 0, trailingPadding: CGFloat = 0, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: leadingPadding).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -trailingPadding).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    func sizeAnchor(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func aspect(ratio: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).isActive = true
    }
    
    func centerAnchor(centerY: NSLayoutYAxisAnchor? = nil, centerX: NSLayoutXAxisAnchor? = nil, x: CGFloat = 0, y: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY, constant: y).isActive = true
        }

        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX, constant: x).isActive = true
        }
    }

    func centerYAnchor(to item: UIView, multiplier: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: item, attribute: .centerY, multiplier: multiplier, constant: constant).isActive = true
    }
    
    func centerXAnchor(to item: UIView, multiplier: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: item, attribute: .centerX, multiplier: multiplier, constant: constant).isActive = true
    }

    func alignCenterToSuperView() {
        alignCenterXToSuperView()
        alignCenterYToSuperView()
    }

    func alignCenterYToSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superView = superview else { return }
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
    }

    func alignCenterXToSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superView = superview else { return }
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
    }

    func equalWidth(with multiplier: CGFloat = 1.0, to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier).isActive = true
    }
}

// MARK: - Safe Area Layout
public extension UIView {
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }

    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }

    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }

    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String?, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let link = link else {return}
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
