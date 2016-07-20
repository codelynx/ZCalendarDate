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
	let month: Int

	init(year: Int, month: Int) {
		self.month = month
		super.init(year: year)
	}

	init?(integerValue: Int) {
		var value = integerValue
		let month = value % 100; value /= 100
		let year = value
		let componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = 1
		if let _ = _gregorian.dateFromComponents(componets) {
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

	var firstCalendarDateOfMonth: ZCalendarDate {
		return ZCalendarDate(year: self.year, month: month, day: 1)
	}

	var lastCalendarDateOfMonth: ZCalendarDate {
		let firstDateOfMonth = self.firstCalendarDateOfMonth.date
		let range = _gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: firstDateOfMonth)
		return ZCalendarDate(year: self.year, month: self.month, day: range.length)
	}

	func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth {
		let offsetComponents = NSDateComponents()
		offsetComponents.month = months

		let date = _gregorian.dateByAddingComponents(offsetComponents, toDate: self.firstCalendarDateOfMonth.date, options: .WrapComponents)
		let options: NSCalendarUnit = [.Year, .Month]
		let components = _gregorian.components(options, fromDate: date!)
		return ZCalendarMonth(year: components.month, month: components.year)
	}

	var previousCalendarMonth: ZCalendarMonth {
		return calendarMonthOffsetByMonths(-1)
	}

	var nextCalendarMonth: ZCalendarMonth {
		return calendarMonthOffsetByMonths(1)
	}

	var daysInMonth: Int {
		let firstDayOfMonth = self.firstCalendarDateOfMonth.date
		
		let range = _gregorian.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: firstDayOfMonth)
		assert(range.location != NSNotFound)
		assert(range.length != NSNotFound)
		return range.length
	}

}

public func == (lhs:ZCalendarMonth, rhs:ZCalendarMonth) -> Bool {
	return lhs.year == rhs.year && lhs.month == rhs.month
}

public func < (lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
	return lhs.year < rhs.year && lhs.month < rhs.month
}


//
//	ZCalendarDate
//

public class ZCalendarDate: ZCalendarMonth {
	let day: Int

	public init(year: Int, month: Int, day: Int) {
		self.day = day
		super.init(year: year, month: month)
	}

	public init(date: NSDate) {
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let options: NSCalendarUnit = [.Year, .Month, .Day]
		let components = calendar.components(options, fromDate: date)
		self.day = components.day
		super.init(year: components.year, month: components.month)
	}

	override public init?(integerValue: Int) {
		var value = integerValue
		let day = value % 100; value /= 100
		let month = value % 100; value /= 100
		let year = value
		let componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = day
		if let _ = _gregorian.dateFromComponents(componets) {
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

	var date: NSDate {
		return _gregorian.dateFromComponents(self.dateComponents)!
	}

	var dateComponents: NSDateComponents {
		let componets = NSDateComponents()
		componets.year = self.year
		componets.month = self.month
		componets.day = day
		return componets
	}

	var calendarDayOfWeek: ZCalendarDayOfWeek {
		let components = _gregorian.components(NSCalendarUnit.Weekday, fromDate: self.date)
		return ZCalendarDayOfWeek(rawValue: components.weekday)!
	}

	var calendarMonth: ZCalendarMonth {
		return ZCalendarMonth(year: self.year, month: self.month)
	}

	var firstCalendarDayOfYear: ZCalendarDate {
		return ZCalendarDate(year: self.year, month: 1, day: 1)
	}

	var previousCalendarDate: ZCalendarDate {
		return self.calendarDateOffsetByDays(-1)
	}

	var nextCalendarDate: ZCalendarDate {
		return self.calendarDateOffsetByDays(1)
	}

	func calendarDateOffsetByDays(days: Int) -> ZCalendarDate {
		let offsetComponets = NSDateComponents()
		offsetComponets.day = days
		let date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
		return ZCalendarDate(date: date!)
	}

	func calendarDateOffsetByMonth(months: Int) -> ZCalendarDate {
		let offsetComponets = NSDateComponents()
		offsetComponets.month = months
		let date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
		return ZCalendarDate(date: date!)
	}

	func daysSinceCalendarDate(calendarDate: ZCalendarDate) -> Int {
		let t1 = self.date.timeIntervalSinceReferenceDate
		let t2 = calendarDate.date.timeIntervalSinceReferenceDate
		let secondsInDay: NSTimeInterval = 60 * 60 * 24
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
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(interval))
}

public func - (lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
	let interval = _secondsADay * Double(rhs)
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(-interval))
}
