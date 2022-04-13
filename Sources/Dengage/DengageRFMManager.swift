import Foundation

final class DengageRFMManager {
    
    private let scoreSource: [RFMScore]
    
    init() {
        scoreSource = DengageLocalStorage.shared.getrfmScores()
    }
    
    func sortRFMItems(gender: RFMGender, items: [RFMItemProtocol]) -> [RFMItemProtocol] {
        let rawNotPersonalized = items.filter{$0.personalized == false}
        let sortedNotPersonalized = sortByRfms(scoreArray: scoreSource, rawArray: rawNotPersonalized)
        var personalized = items.filter{$0.personalized}
        var genderSelecteds = [RFMItemProtocol]()
        for element in personalized{
            if element.gender == gender || element.gender == .neutral {
                genderSelecteds.append(element)
                personalized.removeAll(where: {$0.id == element.id})
            }
        }
        let sortedGenderSelecteds = sortByRfms(scoreArray: scoreSource, rawArray: genderSelecteds)
        let sortedPersonalized = sortByRfms(scoreArray: scoreSource, rawArray: personalized)

        var result = [RFMItemProtocol]()
        result.reserveCapacity(items.count)
        result.append(contentsOf: sortedNotPersonalized)
        result.append(contentsOf: sortedGenderSelecteds)
        result.append(contentsOf: sortedPersonalized)
        return result
    }
    
    private func sortByRfms(scoreArray: [RFMScore], rawArray: [RFMItemProtocol]) -> [RFMItemProtocol] {
        var array = rawArray
        var result = [RFMItemProtocol]()
        for scoreElement in scoreArray {
            for element in array {
                if scoreElement.categoryId == element.categoryId{
                    result.append(element)
                    array.removeAll(where: {$0.id == element.id})
                }
            }
        }
        let sortedbybannerSequence = array.sorted(by: {$0.sequence < $1.sequence})
        result.append(contentsOf: sortedbybannerSequence)
        return result
    }
    
    func saveRFM(scores: [RFMScore]) {
        DengageLocalStorage.shared.save(scores)
    }
    
    func categoryView(id: String) {
        var newSource = [RFMScore]()
        if let category = scoreSource.first(where: {$0.categoryId == id}) {
            newSource = scoreSource.filter{$0.categoryId != id}
            let updatedCategory = RFMScore(categoryId: category.categoryId, score: (sqrt(category.score) * category.score) / 4)
            newSource.append(updatedCategory)
        }else {
            newSource = scoreSource
            let newCategory = RFMScore(categoryId: id, score: 0.5)
            newSource.append(newCategory)
        }
        saveRFM(scores: newSource)
    }
}
