//
//  ZCalendarDate.swift
//  ZKit
//
//  Created by Kaz Yoshikawa on 2015/04/26.
//
//

import Foundation


//
//	ZCalendarDayOfWeek
//

enum ZCalendarDayOfWeek: Int {
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

class ZCalendarYear: Equatable, Comparable, Printable {
	let year: Int
	init(year: Int) {
		self.year = year
	}
	var description: String {
		return String(format: "%04d", self.year)
	}
	var intValue: Int {
		return year
	}
	var firstCalendarMonthOfYear: ZCalendarMonth {
		return ZCalendarMonth(year: self.year, month: 1)
	}
	var lastCalendarMonthOfYear: ZCalendarMonth {
		return ZCalendarMonth(year: self.year, month: 12)
	}
}

func ==(lhs:ZCalendarYear, rhs:ZCalendarYear) -> Bool {
	return lhs.year == rhs.year
}

func <(lhs: ZCalendarYear, rhs: ZCalendarYear) -> Bool {
	return lhs.year < rhs.year
}

//
//	ZCalendarMonth
//

class ZCalendarMonth: ZCalendarYear, Equatable, Comparable, Printable {
	let month: Int

	init(year: Int, month: Int) {
		self.month = month
		super.init(year: year)
	}

	init?(intValue: Int) {
		var value = intValue
		let month = value % 100; value /= 100
		let year = value
		var componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = 1
		if let date = _gregorian.dateFromComponents(componets) {
			self.month = month
			super.init(year: year)
		}
		else {
			self.month = 0
			super.init(year: year)
			return nil
		}
	}

	override var description: String {
		return String(format: "%04d/%02d", self.year, self.month)
	}

	override var intValue: Int {
		return 100 * self.year + self.month;
	}

	var firstCalendarDateOfMonth: ZCalendarDate {
		return ZCalendarDate(year: self.year, month: month, day: 1)
	}

	var lastCalendarDateOfMonth: ZCalendarDate {
		let firstDateOfMonth = self.firstCalendarDateOfMonth.date
		let range = _gregorian.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: firstDateOfMonth)
		return ZCalendarDate(year: self.year, month: self.month, day: range.length)
	}

	func calendarMonthOffsetByMonths(months: Int) -> ZCalendarMonth {
		var offsetComponents = NSDateComponents()
		offsetComponents.month = months

		var date = _gregorian.dateByAddingComponents(offsetComponents, toDate: self.firstCalendarDateOfMonth.date, options: .WrapComponents)
		let options: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth
		var components = _gregorian.components(options, fromDate: date!)
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
		
		let range = _gregorian.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: firstDayOfMonth)
		assert(range.location != NSNotFound)
		assert(range.length != NSNotFound)
		return range.length
	}

}
func ==(lhs:ZCalendarMonth, rhs:ZCalendarMonth) -> Bool {
	return lhs.year == rhs.year && lhs.month == rhs.month
}

func <(lhs: ZCalendarMonth, rhs: ZCalendarMonth) -> Bool {
	return lhs.year < rhs.year && lhs.month < rhs.month
}


//
//	ZCalendarDate
//

class ZCalendarDate: ZCalendarMonth, Equatable, Comparable, Printable {
	let day: Int

	init(year: Int, month: Int, day: Int) {
		self.day = day
		super.init(year: year, month: month)
	}

	init(date: NSDate) {
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let options: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay
		var components = calendar.components(options, fromDate: date)
		self.day = components.day
		super.init(year: components.year, month: components.month)
	}

	override init?(intValue: Int) {
		var value = intValue
		let day = value % 100; value /= 100
		let month = value % 100; value /= 100
		let year = value
		var componets = NSDateComponents()
		componets.year = year
		componets.month = month
		componets.day = day
		if let date = _gregorian.dateFromComponents(componets) {
			self.day = month
			super.init(year: year, month: month)
		}
		else {
			self.day = 0
			super.init(year: year, month: month)
			return nil
		}
	}

	override var description: String {
		return String(format: "%04d/%02d/%02d", self.year, self.month, self.day)
	}

	override var intValue: Int {
		return 10_000 * self.year + 100 * self.month + self.day;
	}

	var date: NSDate {
		return _gregorian.dateFromComponents(self.dateComponents)!
	}

	var dateComponents: NSDateComponents {
		var componets = NSDateComponents()
		componets.year = self.year
		componets.month = self.month
		componets.day = day
		return componets
	}

	var calendarDayOfWeek: ZCalendarDayOfWeek {
		var components = _gregorian.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self.date)
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
		var offsetComponets = NSDateComponents()
		offsetComponets.day = days
		var date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
		return ZCalendarDate(date: date!)
	}

	func calendarDateOffsetByMonth(months: Int) {
		var offsetComponets = NSDateComponents()
		offsetComponets.month = months
		var date = _gregorian.dateByAddingComponents(offsetComponets, toDate: self.date, options: .WrapComponents)
	}
}

func ==(lhs:ZCalendarDate, rhs:ZCalendarDate) -> Bool {
	return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
}

func <(lhs: ZCalendarDate, rhs: ZCalendarDate) -> Bool {
	return lhs.year < rhs.year && lhs.month < rhs.month && lhs.day < rhs.day
}

func -(lhs: ZCalendarDate, rhs: ZCalendarDate) -> Int {
	let d1 = lhs.date
	let d2 = rhs.date
	let t = d1.timeIntervalSinceReferenceDate - d2.timeIntervalSinceReferenceDate
	let days = ceil(t / _secondsADay)
	return Int(days)
}

func +(lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
	let interval = _secondsADay * Double(rhs)
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(interval))
}

func -(lhs: ZCalendarDate, rhs: Int) -> ZCalendarDate {
	let interval = _secondsADay * Double(rhs)
	return ZCalendarDate(date: lhs.date.dateByAddingTimeInterval(-interval))
}
