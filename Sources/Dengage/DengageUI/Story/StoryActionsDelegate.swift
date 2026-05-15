import Foundation

protocol StoryActionsDelegate: AnyObject {

    func storyEvent(eventType: StoryEventType, message:InAppMessage, storyProfileId: String, storyProfileName: String, storyId: String, storyName: String, buttonUrl: String)

    func setStoryCoverShown(storyCoverId: String, storySetId: String)
    func sortStoryCovers(storyCovers: [StoryCover], storySetId: String) -> [StoryCover]

    /// Records an individual story view. Cover-level "shown" escalates when every
    /// story id under the cover has been recorded.
    func setStoryViewed(storyId: String, storyCoverId: String, storySetId: String, allStoryIdsInCover: [String])

    /// Persisted set of story ids viewed under [storyCoverId] (used to resume + decide shown).
    func getViewedStoryIds(storyCoverId: String) -> [String]

    /// Persists the index of the last story the user was on (used to resume at +1 next open).
    func setLastViewedStoryIndex(storyCoverId: String, index: Int)

    /// Returns the last-viewed story index for [storyCoverId], or -1 if never opened.
    func getLastViewedStoryIndex(storyCoverId: String) -> Int

}

