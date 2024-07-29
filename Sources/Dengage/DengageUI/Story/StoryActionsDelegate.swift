import Foundation

protocol StoryActionsDelegate: AnyObject {
    
    func storyEvent(eventType: StoryEventType, message:InAppMessage, storyProfileId: String, storyProfileName: String, storyId: String, storyName: String, buttonUrl: String)

    func setStoryCoverShown(storyCoverId: String, storySetId: String)
    func sortStoryCovers(storyCovers: [StoryCover], storySetId: String) -> [StoryCover]
    
}

