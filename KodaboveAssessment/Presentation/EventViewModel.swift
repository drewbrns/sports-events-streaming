//
//  EventViewModel.swift
//  KodaboveAssessment
//
//  Created by Drew Barnes on 10/08/2022.
//

import Foundation

enum ItemType {
    case event
    case schedule
}

struct EventViewModel {
    private var item: Event
    private var itemType: ItemType

    var id: String {
        return item.id
    }
    var title: String {
        item.title
    }
    var subtitle: String {
        item.subtitle
    }
    var imageUrl: URL {
        item.imageUrl
    }
    var videoUrl: URL? {
        item.videoUrl
    }
    var date: Date {
        return item.date
    }

    init(item: Event, itemType: ItemType = .event) {
        self.item = item
        self.itemType = itemType
    }

    var dateForDisplay: String {
        switch itemType {
        case .event:
            return dateForDisplayForEvent
        case .schedule:
            return dateForDisplayForSchedule
        }
    }

    private var dateForDisplayForEvent: String {
        Formatter.dateFormatter.dateFormat = getDateFormat(for: self.date)
        let dateString = Formatter.dateFormatter.string(from: self.date)

        if self.date.isYesterday {
            return "Yesterday, \(dateString)"
        } else if self.date.isToday {
            return "Today, \(dateString)"
        }

        return dateString
    }

    private var dateForDisplayForSchedule: String {
        Formatter.dateFormatter.dateFormat = getDateFormat(for: self.date)
        let dateString = Formatter.dateFormatter.string(from: self.date)

        if self.date.isTomorrow {
            return "Tomorrow, \(dateString)"
        } else if self.date.isToday {
            return "Today, \(dateString)"
        } else if self.date.isInPast {
            return dateString
        } else {
            let today = Date()
            let days = self.date.daysFrom(date: today)
            if days > 3 {
                return dateString
            }

            Formatter.numberFormatter.numberStyle = .spellOut
            let spelltOut = Formatter.numberFormatter.string(from: NSNumber(value: days))!
            return "In \(spelltOut) days"
        }
    }

    private func getDateFormat(for date: Date) -> String {
        if date.isYesterday || date.isToday || date.isTomorrow {
            return "HH:mm"
        }
        return "dd.MM.yyyy"
    }

}

extension EventViewModel: Equatable {
    static func == (lhs: EventViewModel, rhs: EventViewModel) -> Bool {
        return lhs.item == rhs.item
    }
}
