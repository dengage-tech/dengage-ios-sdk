

import Foundation
import UIKit

protocol RetryBtnDelegate: AnyObject {
    func retryButtonTapped()
}

public class StoryRetryLoaderButton: UIButton {
    var contentURL: String?
    weak var delegate: RetryBtnDelegate?
    convenience init(withURL url: String) {
        self.init()
        self.backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        //TODO
        //self.setImage(#imageLiteral(resourceName: "ic_retry"), for: .normal)
        self.addTarget(self, action: #selector(didTapRetryBtn), for: .touchUpInside)
        self.contentURL = url
        self.tag = 100
    }
    @objc func didTapRetryBtn() {
        delegate?.retryButtonTapped()
    }
}

extension UIView {
    func removeRetryButton() {
        self.subviews.forEach({v in
            if(v.tag == 100){v.removeFromSuperview()}
        })
    }
    
}
