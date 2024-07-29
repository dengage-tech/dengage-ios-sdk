import Foundation
import UIKit


class StoryDisplayViewModel: NSObject {
    
    let storyCovers: [StoryCover]
    
    init(_ stories: [StoryCover]) {
        self.storyCovers = stories
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return storyCovers.count
    }
    
    func cellForItemAtIndexPath(_ indexPath: IndexPath) -> StoryCover? {
        if indexPath.item < storyCovers.count {
            return storyCovers[indexPath.item]
        }else {
            fatalError("Stories Index mis-matched :(")
        }
    }
}
