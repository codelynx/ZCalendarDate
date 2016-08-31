//
//  ZCalendarDate.swift
//  ZKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Electricwoods LLC, Kaz Yoshikawa.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy 
//  of this software and associated documentation files (the "Software"), to deal 
//  in the Software without restriction, including without limitation the rights 
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//  copies of the Software, and to permit persons to whom the Software is 
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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

private let _gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
private let _secondsADay = 60.0 * 60.0 * 24.0


//
//	ZCalendarType
//

protocol ZCalendarType: Comparable, CustomStringConvertible {
	var integerValue: Int { get }
}

protocol ZCalendarYearType: ZCalendarType {
	var year: Int { get }
	var firstCalendarMonthOfYear: ZCalendarMonth { get }
	var lastCalendarMonthOfYear: ZCalendarMonth { get }
}

protocol ZCalendarMonthType: ZCalendarYearType {
	var month: Int { get }
	var firstCalendarDateOfMonth: ZCalendarDate { get }
	var lastCalendarDateOfMonth: ZCalendarDate { get }
	func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth
	func offsetMonths(calendarMonth: ZCalendarMonth) -> Int
	var previousCalendarMonth: ZCalendarMonth { get }
	var nextCalendarMonth: ZCalendarMonth { get }
}

protocol ZCalendarDateType: ZCalendarMonthType {
	var day: Int { get }
	var calendarDayOfWeek: ZCalendarDayOfWeek { get }
	var firstCalendarDayOfYear: ZCalendarDate { get }
	var previousCalendarDate: ZCalendarDate { get }
	var nextCalendarDate: ZCalendarDate { get }
	func calendarDateOffsetByDays(days: Int) -> ZCalendarDate
	func calendarDateOffsetByMonth(months: Int) -> ZCalendarDate
	func daysSinceCalendarDate(calendarDate: ZCalendarDate) -> Int
}

//
//	ZCalendarYear
//

public struct ZCalendarYear: ZCalendarYearType {
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

public struct ZCalendarMonth: ZCalendarMonthType {

	private let calendarYear: ZCalendarYear
	public let month: Int
	public var year: Int { return calendarYear.year }

	public init(year: Int, month: Int) {
		self.calendarYear = ZCalendarYear(year: year)
		self.month = month
	}

	public init?(integerValue: Int) {
		var value = integerValue
		let month = value % 100; value /= 100
		let year = value
		let componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = 1
		if let _ = _gregorian.dateFromComponents(componets) {
			self.calendarYear = ZCalendarYear(year: year)
			self.month = month
		}
		else {
			return nil
		}
	}

	public var description: String {
		return String(format: "%04d/%02d", self.calendarYear.year, self.month)
	}

	public var integerValue: Int {
		return 100 * self.calendarYear.year + self.month;
	}

	public var firstCalendarDateOfMonth: ZCalendarDate {
		return ZCalendarDate(year: self.calendarYear.year, month: month, day: 1)
	}

	public var lastCalendarDateOfMonth: ZCalendarDate {
		let firstDateOfMonth = self.firstCalendarDateOfMonth.date
		let range = _gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: firstDateOfMonth)
		return ZCalendarDate(year: self.calendarYear.year, month: self.month, day: range.length)
	}

	public func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth {
		let offsetComponents = NSDateComponents()
		offsetComponents.month = months % 12
		offsetComponents.year = months / 12
		let date = _gregorian.dateByAddingComponents(offsetComponents, toDate: self.firstCalendarDateOfMonth.date, options: .WrapComponents)
		let options: NSCalendarUnit = [.Year, .Month]
		let components = _gregorian.components(options, fromDate: date!)
		return ZCalendarMonth(year: components.year, month: components.month)
	}

	public func offsetMonths(calendarMonth: ZCalendarMonth) -> Int {
		return (self.calendarYear.year * 12 + self.month) - (calendarMonth.year * 12 + calendarMonth.month)
	}

	public var previousCalendarMonth: ZCalendarMonth {
		return calendarMonthOffsetByMonths(-1)
	}

	public var nextCalendarMonth: ZCalendarMonth {
		return calendarMonthOffsetByMonths(1)
	}

	public var daysInMonth: Int {
		let firstDayOfMonth = self.firstCalendarDateOfMonth.date
		
		let range = _gregorian.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: firstDayOfMonth)
		assert(range.location != NSNotFound)
		assert(range.length != NSNotFound)
		return range.length
	}

	public func day(day: Int) -> ZCalendarDate {
		return ZCalendarDate(year: self.calendarYear.year, month: self.month, day: day)
	}

	var firstCalendarMonthOfYear: ZCalendarMonth { return self.calendarYear.firstCalendarMonthOfYear }
	var lastCalendarMonthOfYear: ZCalendarMonth { return self.calendarYear.lastCalendarMonthOfYear }

}

public func == (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
	return lhs.year == rhs.year && lhs.month == rhs.month
}

public func < (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
	return lhs.year < rhs.year && lhs.month < rhs.month
}

public func + (lhs: ZCalendarMonth, rhs: Int) -> ZCalendarMonth {
	return lhs.calendarMonthOffsetByMonths(rhs)
}

public func - (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Int {
	return lhs.offsetMonths(rhs)
}

//
//	ZCalendarDate
//

public struct ZCalendarDate: ZCalendarDateType {
	public let calendarMonth: ZCalendarMonth

	public let day: Int
	public var month: Int { return calendarMonth.month }
	public var year: Int { return calendarMonth.year }

	public init(year: Int, month: Int, day: Int) {
		self.calendarMonth = ZCalendarMonth(year: year, month: month)
		self.day = day
	}

	public init(date: NSDate = NSDate()) {
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let options: NSCalendarUnit = [.Year, .Month, .Day]
		let components = calendar.components(options, fromDate: date)
		self.calendarMonth = ZCalendarMonth(year: components.year, month: components.month)
		self.day = components.day
	}

	public init?(integerValue: Int) {
		var value = integerValue
		let day = value % 100; value /= 100
		let month = value % 100; value /= 100
		let year = value
		let componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = day
		if let _ = _gregorian.dateFromComponents(componets) {
			self.calendarMonth = ZCalendarMonth(year: year, month: month)
			self.day = month
		}
		else {
			return nil
		}
	}

	public var description: String {
		return String(format: "%04d/%02d/%02d", year, self.month, self.day)
	}

	public var integerValue: Int {
		return 10_000 * year + 100 * self.month + self.day;
	}

	public var date: NSDate {
		return _gregorian.dateFromComponents(self.dateComponents)!
	}

	public var dateComponents: NSDateComponents {
		let componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = day
		return componets
	}

	public var calendarDayOfWeek: ZCalendarDayOfWeek {
		let components = _gregorian.components(NSCalendarUnit.Weekday, fromDate: self.date)
		return ZCalendarDayOfWeek(rawValue: components.weekday)!
	}

	public var firstCalendarDayOfYear: ZCalendarDate {
		return ZCalendarDate(year: year, month: 1, day: 1)
	}

	public var previousCalendarDate: ZCalendarDate {
		return self.calendarDateOffsetByDays(-1)
	}

	public var nextCalendarDate: ZCalendarDate {
		return self.calendarDateOffsetByDays(1)
	}

	public func calendarDateOffsetByDays(days: Int) -> ZCalendarDate {
		let offsetComponets = NSDateComponents()
		offsetComponets.day = days
		let date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
		return ZCalendarDate(date: date!)
	}

	public func calendarDateOffsetByMonth(months: Int) -> ZCalendarDate {
		let offsetComponets = NSDateComponents()
		offsetComponets.month = months
		let date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
		return ZCalendarDate(date: date!)
	}

	public func daysSinceCalendarDate(calendarDate: ZCalendarDate) -> Int {
		let t1 = self.date.timeIntervalSinceReferenceDate
		let t2 = calendarDate.date.timeIntervalSinceReferenceDate
		let secondsInDay: NSTimeInterval = 60 * 60 * 24
		return Int(floor((t2 - t1) / secondsInDay))
	}

	var firstCalendarMonthOfYear: ZCalendarMonth { return self.calendarMonth.firstCalendarMonthOfYear }
	var lastCalendarMonthOfYear: ZCalendarMonth { return self.calendarMonth.lastCalendarMonthOfYear }

	var firstCalendarDateOfMonth: ZCalendarDate { return self.calendarMonth.firstCalendarDateOfMonth }
	var lastCalendarDateOfMonth: ZCalendarDate { return self.calendarMonth.lastCalendarDateOfMonth }
	func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth { return self.calendarMonth.calendarMonthOffsetByMonths(months) }
	func offsetMonths(calendarMonth: ZCalendarMonth) -> Int { return self.calendarMonth.offsetMonths(calendarMonth) }
	var previousCalendarMonth: ZCalendarMonth { return self.calendarMonth.previousCalendarMonth }
	var nextCalendarMonth: ZCalendarMonth { return self.calendarMonth.nextCalendarMonth }

}

public func == (lhs: ZCalendarDate, rhs: ZCalendarDate) -> Bool {
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
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(interval))
}

public func - (lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
	let interval = _secondsADay * Double(rhs)
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(-interval))
}
