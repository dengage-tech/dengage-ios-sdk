import Foundation

final class DengageVisitCountManager {
    
    class func findVisitCount(pastDayCount: Int) -> Int {
        let visitCounts = DengageLocalStorage.shared.getVisitCounts()
        guard let startDate = Calendar.current.date(byAdding: .day, value:-pastDayCount, to: Date())?.timeMiliseconds else { return 0 }
        let count = visitCounts.filter{$0.date >= startDate}.reduce(0) { $0 + $1.count}
        return count
    }

    class func updateVisitCount(){
        var visitCounts = DengageLocalStorage.shared.getVisitCounts()
        let today = Date.defaultFormatter.string(from: Date())
        guard let todayDate = Date.defaultFormatter.date(from: today)?.timeMiliseconds else { return }
        if let lastDate = visitCounts.last, lastDate.date == todayDate {
            var count = lastDate.count
            count += 1
            visitCounts[visitCounts.count - 1] = VisitCountItem(date: todayDate, count: count)
        }else {
            visitCounts.append(VisitCountItem.init(date: todayDate, count: 1))
            if visitCounts.count == 61 {
                visitCounts = Array(visitCounts.dropFirst())
            }
        }

        DengageLocalStorage.shared.save(visitCounts)
    }
}
