import Foundation
import UIKit


public protocol LayoutAttributesAnimator {
    func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes)
}

open class AnimatedCollectionViewLayout: UICollectionViewFlowLayout {
    open var animator: LayoutAttributesAnimator?
    open override class var layoutAttributesClass: AnyClass {
        return AnimatedCollectionViewLayoutAttributes.self
    }
    open override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]?
    {
        return super.layoutAttributesForElements(in: rect)?.compactMap {
            $0.copy() as? AnimatedCollectionViewLayoutAttributes
        }.map { self.transformLayoutAttributes($0) }
    }
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    private var focusedIndexPath: IndexPath?
    override open func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        focusedIndexPath = collectionView?.indexPathsForVisibleItems.first
    }
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint)
    -> CGPoint
    {
        guard let indexPath = focusedIndexPath, let attributes = layoutAttributesForItem(at: indexPath),
              let collectionView = collectionView
        else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        return CGPoint(
            x: attributes.frame.origin.x - collectionView.contentInset.left,
            y: attributes.frame.origin.y - collectionView.contentInset.top)
    }
    override open func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        focusedIndexPath = nil
    }
    private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
    {
        guard let collectionView = self.collectionView else { return attributes }
        let a = attributes
        let distance: CGFloat
        let itemOffset: CGFloat
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = a.center.x - collectionView.contentOffset.x
            a.startOffset = (a.frame.origin.x - collectionView.contentOffset.x) / a.frame.width
            a.endOffset =
            (a.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width)
            / a.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = a.center.y - collectionView.contentOffset.y
            a.startOffset = (a.frame.origin.y - collectionView.contentOffset.y) / a.frame.height
            a.endOffset =
            (a.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height)
            / a.frame.height
        }
        a.scrollDirection = scrollDirection
        a.middleOffset = itemOffset / distance - 0.5
        if a.contentView == nil,
           let c = collectionView.cellForItem(at: attributes.indexPath)?.contentView
        {
            a.contentView = c
        }
        animator?.animate(collectionView: collectionView, attributes: a)
        return a
    }
}

open class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    public var startOffset: CGFloat = 0
    public var middleOffset: CGFloat = 0
    public var endOffset: CGFloat = 0
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedCollectionViewLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
    open override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedCollectionViewLayoutAttributes else { return false }
        return super.isEqual(o) && o.contentView == contentView && o.scrollDirection == scrollDirection
        && o.startOffset == startOffset && o.middleOffset == middleOffset && o.endOffset == endOffset
    }
}

public struct CubeAttributesAnimator : LayoutAttributesAnimator {
    public var perspective: CGFloat
    public var totalAngle: CGFloat
    public init(perspective: CGFloat = -1 / 500, totalAngle: CGFloat = .pi / 2) {
        self.perspective = perspective
        self.totalAngle = totalAngle
    }
    public func animate(
        collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes
    ) {
        let position = attributes.middleOffset
        if abs(position) >= 1 {
            attributes.contentView?.layer.transform = CATransform3DIdentity
        } else if attributes.scrollDirection == .horizontal {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, 0, 1, 0)
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                    attributes.contentView?.layer.transform = transform
                }
            ) { attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0 }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(
                CGPoint(x: position > 0 ? 0 : 1, y: 0.5))
        } else {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, -1, 0, 0)
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                    attributes.contentView?.layer.transform = transform
                }
            ) { attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0 }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(
                CGPoint(x: 0.5, y: position > 0 ? 0 : 1))
        }
    }
}

