// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

let appCalendar = Calendar.current

class HomeManager: ObservableObject {

    @Published var canDrag: Bool = true
    @Published var pagesState = PagesState(startingPage: 2,
                                           pageCount: 4,
                                           deltaCutoff: 0.8)

    let calendarManager: ElegantCalendarManager
    let sideBarTracker: VisitsSideBarTracker

    let visitsProvider: VisitsProvider
    private var anyCancellable = Set<AnyCancellable>()

    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        sideBarTracker = VisitsSideBarTracker(
            descendingDayComponents: visitsProvider.descendingDayComponents)
        calendarManager = ElegantCalendarManager(
            configuration: CalendarConfiguration(
                ascending: false,
                startDate: visitsProvider.descendingDayComponents.last!.date,
                endDate: visitsProvider.descendingDayComponents.first!.date,
                themeColor: .blackPearl))

        sideBarTracker.delegate = self
        calendarManager.delegate = self

        pagesState.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &anyCancellable)
    }

}

// TODO: add conformance to the calendar manager datasource

extension HomeManager: ElegantCalendarDelegate {

    func calendar(didSelectDate date: Date) {
        sideBarTracker.scroll(to: date)
    }

    func calendar(willDisplayMonth date: Date) {
        if !appCalendar.isDate(date, equalTo: sideBarTracker.currentDayComponent.date, toGranularities: [.month, .year]) {
            sideBarTracker.scroll(to: appCalendar.endOfMonth(for: date))
        }
    }

}

extension HomeManager: VisitsListDelegate {

    func listDidBeginScrolling() {
        canDrag = false
    }

    func listDidEndScrolling(dayComponent: DateComponents) {
        calendarManager.scrollToMonth(dayComponent.date, animated: false)
        canDrag = true
    }

}
