import UIKit

enum ProgressorState {
    case notStarted
    case paused
    case running
    case finished
}
protocol ViewAnimator {
    func start(with duration: TimeInterval, holderView: UIView, completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool) -> Void)
    func resume()
    func pause()
    func stop()
    func reset()
}
extension ViewAnimator where Self: StoryProgressView {
    
    //TODO: EGEMEN: SORUN BURADA SANIRIM: 2 KEZ GİRİYOR BURAYA
    func start(with duration: TimeInterval, holderView: UIView, completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool) -> Void) {
        // Modifying the existing widthConstraint and setting the width equalTo holderView's widthAchor
        self.state = .running
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
        self.widthConstraint?.constant = holderView.width
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: {[weak self] in
            if let strongSelf = self {
                strongSelf.superview?.layoutIfNeeded()
            }
        }) { [weak self] (finished) in
            self?.storyCover.isCancelledAbruptly = !finished
            self?.state = .finished
            
            //TODO: EGEMEN: SORUN BURADA SANIRIM: finished oluyor nedense?
            if finished == true {
                if let strongSelf = self {
                    return completion(strongSelf.storyCoverIdentifier!, strongSelf.snapIndex!, strongSelf.storyCover.isCancelledAbruptly)
                }
            } else {
                return completion(self?.storyCoverIdentifier ?? "Unknown", self?.snapIndex ?? 0, self?.storyCover.isCancelledAbruptly ?? true)
            }
        }
    }
    func resume() {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        state = .running
    }
    func pause() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        state = .paused
    }
    func stop() {
        resume()
        layer.removeAllAnimations()
        state = .finished
    }
    func reset() {
        state = .notStarted
        self.storyCover.isCancelledAbruptly = true
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
    }
}

final class StoryProgressView: UIView, ViewAnimator {
    public var storyCoverIdentifier: String?
    public var snapIndex: Int?
    public var storyCover: StoryCover!
    public var widthConstraint: NSLayoutConstraint?
    public var state: ProgressorState = .notStarted
}

final class StoryProgressIndicatorView: UIView {
    public var widthConstraint: NSLayoutConstraint?
    public var leftConstraiant: NSLayoutConstraint?
    public var rightConstraiant: NSLayoutConstraint?
}
