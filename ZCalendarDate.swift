//
//	ZCalendarDate.swift
//	ZKit
//
//	The MIT License (MIT)
//
//	Copyright (c) 2015 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

import Foundation


//
//	ZCalendarDayOfWeek
//

public enum ZCalendarDayOfWeek: Int {
    case Sunday = 1
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thrusday = 5
    case Friday = 6
    case Saturday = 7
}

private let _gregorian = Calendar(identifier: .gregorian)
private let _secondsADay = 60.0 * 60.0 * 24.0

//
//	ZCalendarYear
//

public class ZCalendarYear: Equatable, Comparable, CustomStringConvertible {
    public let year: Int
    public init(year: Int) {
        self.year = year
    }
    public var description: String {
        return String(format: "%04d", self.year)
    }
    public var integerValue: Int {
        return year
    }
    public var firstCalendarMonthOfYear: ZCalendarMonth {
        return ZCalendarMonth(year: self.year, month: 1)
    }
    public var lastCalendarMonthOfYear: ZCalendarMonth {
        return ZCalendarMonth(year: self.year, month: 12)
    }
}

public func == (lhs:ZCalendarYear, rhs:ZCalendarYear) -> Bool {
    return lhs.year == rhs.year
}

public func < (lhs: ZCalendarYear, rhs: ZCalendarYear) -> Bool {
    return lhs.year < rhs.year
}

//
//	ZCalendarMonth
//

public class ZCalendarMonth: ZCalendarYear {
    public let month: Int
    
    public init(year: Int, month: Int) {
        self.month = month
        super.init(year: year)
    }
    
    public init?(integerValue: Int) {
        var value = integerValue
        let month = value % 100; value /= 100
        let year = value
        var componets = DateComponents()
        componets.year = year
        componets.month = month
        componets.day = 1
        if let _ = _gregorian.date(from: componets) {
            self.month = month
            super.init(year: year)
        }
        else {
            self.month = 0
            super.init(year: year)
            return nil
        }
    }
    
    override public var description: String {
        return String(format: "%04d/%02d", self.year, self.month)
    }
    
    override public var integerValue: Int {
        return 100 * self.year + self.month;
    }
    
    public var firstCalendarDateOfMonth: ZCalendarDate {
        return ZCalendarDate(year: self.year, month: month, day: 1)
    }
    
    public var lastCalendarDateOfMonth: ZCalendarDate {
        let firstDateOfMonth = self.firstCalendarDateOfMonth.date
        let range = _gregorian.range(of: .day, in: .month, for: firstDateOfMonth as Date)!
        return ZCalendarDate(year: self.year, month: self.month, day: range.count)
    }
    
    public func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth {
        var offsetComponents = DateComponents()
        offsetComponents.month = months % 12
        offsetComponents.year = months / 12
        let date = _gregorian.date(byAdding: offsetComponents, to: self.firstCalendarDateOfMonth.date)
        let components = _gregorian.dateComponents([.year, .month], from: date!)
        return ZCalendarMonth(year: components.year!, month: components.month!)
    }
    
    public func offsetMonths(calendarMonth: ZCalendarMonth) -> Int {
        let months = calendarMonth.month - self.month
        let years = calendarMonth.year - self.year
        return years * 12 - months
    }
    
    public var previousCalendarMonth: ZCalendarMonth {
        return calendarMonthOffsetByMonths(months: -1)
    }
    
    public var nextCalendarMonth: ZCalendarMonth {
        return calendarMonthOffsetByMonths(months: 1)
    }
    
    public var daysInMonth: Int {
        let firstDayOfMonth = self.firstCalendarDateOfMonth.date
        let range = _gregorian.range(of: .day, in: .month, for: firstDayOfMonth)
        return range!.count
    }
    
    public func day(day: Int) -> ZCalendarDate {
        return ZCalendarDate(year: self.year, month: self.month, day: day)
    }
    
}

public func == (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month
}

public func < (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
    return lhs.year < rhs.year && lhs.month < rhs.month
}

public func + (lhs: ZCalendarMonth, rhs: Int) -> ZCalendarMonth {
    return lhs.calendarMonthOffsetByMonths(months: rhs)
}

public func - (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Int {
    return lhs.offsetMonths(calendarMonth: rhs)
}


//
//	ZCalendarDate
//

public class ZCalendarDate: ZCalendarMonth {
    public let day: Int
    
    public init(year: Int, month: Int, day: Int) {
        self.day = day
        super.init(year: year, month: month)
    }
    
    public init(date: Date = Date()) {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        self.day = components.day!
        super.init(year: components.year!, month: components.month!)
    }
    
    override public init?(integerValue: Int) {
        var value = integerValue
        let day = value % 100; value /= 100
        let month = value % 100; value /= 100
        let year = value
        var componets = DateComponents()
        componets.year = year
        componets.month = month
        componets.day = day
        if let _ = _gregorian.date(from: componets) {
            self.day = month
            super.init(year: year, month: month)
        }
        else {
            self.day = 0
            super.init(year: year, month: month)
            return nil
        }
    }
    
    override public var description: String {
        return String(format: "%04d/%02d/%02d", self.year, self.month, self.day)
    }
    
    override public var integerValue: Int {
        return 10_000 * self.year + 100 * self.month + self.day;
    }
    
    public var date: Date {
        return _gregorian.date(from: self.dateComponents)!
    }
    
    public var dateComponents: DateComponents {
        var componets = DateComponents()
        componets.year = self.year
        componets.month = self.month
        componets.day = day
        return componets
    }
    
    public var calendarDayOfWeek: ZCalendarDayOfWeek {
        let components = _gregorian.dateComponents([.weekday], from: self.date)
        return ZCalendarDayOfWeek(rawValue: components.weekday!)!
    }
    
    public var calendarMonth: ZCalendarMonth {
        return ZCalendarMonth(year: self.year, month: self.month)
    }
    
    public var firstCalendarDayOfYear: ZCalendarDate {
        return ZCalendarDate(year: self.year, month: 1, day: 1)
    }
    
    public var previousCalendarDate: ZCalendarDate {
        return self.calendarDateOffsetByDays(days: -1)
    }
    
    public var nextCalendarDate: ZCalendarDate {
        return self.calendarDateOffsetByDays(days: 1)
    }
    
    public func calendarDateOffsetByDays(days: Int) -> ZCalendarDate {
        var offsetComponets = DateComponents()
        offsetComponets.day = days
        let date = _gregorian.date(byAdding: offsetComponets, to: self.date)
        return ZCalendarDate(date: date!)
    }
    
    public func calendarDateOffsetByMonth(months: Int) -> ZCalendarDate {
        var offsetComponets = DateComponents()
        offsetComponets.month = months
        let date = _gregorian.date(byAdding: offsetComponets, to: self.date)
        return ZCalendarDate(date: date!)
    }
    
    public func daysSinceCalendarDate(calendarDate: ZCalendarDate) -> Int {
        let t1 = self.date.timeIntervalSinceReferenceDate
        let t2 = calendarDate.date.timeIntervalSinceReferenceDate
        let secondsInDay: TimeInterval = 60 * 60 * 24
        return Int(floor((t2 - t1) / secondsInDay))
    }
}

public func == (lhs:ZCalendarDate, rhs:ZCalendarDate) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
}

public func < (lhs: ZCalendarDate, rhs: ZCalendarDate) -> Bool {
    return lhs.year < rhs.year && lhs.month < rhs.month && lhs.day < rhs.day
}

public func - (lhs: ZCalendarDate, rhs: ZCalendarDate) -> Int {
    let d1 = lhs.date
    let d2 = rhs.date
    let t = d1.timeIntervalSinceReferenceDate - d2.timeIntervalSinceReferenceDate
    let days = ceil(t / _secondsADay)
    return Int(days)
}

public func + (lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
    let interval = _secondsADay * Double(rhs)
    return ZCalendarDate(date: lhs.date.addingTimeInterval(interval))
}

public func - (lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
    let interval = _secondsADay * Double(rhs)
    return ZCalendarDate(date: lhs.date.addingTimeInterval(-interval))
}

