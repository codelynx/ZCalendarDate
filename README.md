### ZCalendarDate
NSDate represents a day, but in some cases, you are not interested in hours, seconds nor timezone.  You may use ZCalendarYear, ZCalendarMonth and ZCalendarDate to compute date related issues.

## Classes
* ZCalendarYear
* ZCalendarMonth
* ZCalendarDate

## ZCalendarYear
ZCalendarYear represents a year in Gregorian calendar

|Method |Description|
|:------|:----------|
|year|Year in gregorian calendar. |
|previousCalendarYear |The previous year. |
|nextCalendarYear |The next year. |
|firstCalendarMonthOfYear| The first month of year. |
|lastCalendarMonthOfYear| The last month of year. |


## ZCalendarMonth
ZCalendarMonth represents a month, and not interested in day nor seconds.

|Method |Description|
|:------|:----------|
|year|Year in gregorian calendar. |
|month|The month of the year. |
|firstCalendarDateOfMonth |The first day of the month. |
|lastCalendarDateOfMonth |The last day of the month. |
|previousCalendarMonth |The previous month. |
|nextCalendarMonth |The next month. |
|calendarMonthOffsetByMonths:| Calculate the retative month offset by positive or negative integer.|
|daysInMonth |The number of days in the month. |


## ZCalendarDate
ZCalendarDate 

|Method |Description|
|:------|:----------|
|year|Year in gregorian calendar. |
|month|The month of the year. |
|day|The day of the month. |
|calendarDayOfWeek |The day of the week, (Sunday-Saturday)|
|calendarMonth |The month. |
|firstCalendarDayOfYear |The first day of the year.|
|firstCalendarDayOfMonth |The first day of the month.|
|previousCalendarDate |The previous day. |
|nextCalendarDate |The next day. |
|calendarDateOffsetByDays: | Calculate the relative offset date by positive or negative integer. |
|calendarDateOffsetByMonth: | Calculate the relative offset month by positive or negative integer. |


## Usage

```swift
let y1 = ZCalendarYear(year: 2001)
let m1 = ZCalendarMonth(year: 2001, month: 1)
let d1 = ZCalendarDate(year: 2001, month: 1, day: 1)
let d2 = ZCalendarDate(year: 2015, month: 4, day: 26)

// number of days
let days = d2 - d1 // 5228 days
let d3 = d2 + 100 // "2015/08/04"

// the last day of the month
d2.lastCalendarDateOfMonth

// check if the day is Sunday
if d1.calendarDayOfWeek == ZCalendarDayOfWeek.Sunday {
	// sunday
}
```

```sample.swift
let y16 = ZCalendarYear(year: 2016)  // 2016
let y16m01 = y16.firstCalendarMonthOfYear  // 2016.01
let y16m12 = y16.lastCalendarMonthOfYear  // 2016.12

let y16m01d01 = y16m01.firstCalendarDateOfMonth  // 2016.01.01
let y16m01d31 = y16m01.lastCalendarDateOfMonth  // 2016.01.31

y16.integerValue  // 2016
y16m12.integerValue  // 201612
y16m01d31.integerValue  // 20160131


let y16m04 = y16m01.calendarMonth(offsetByMonths: 3)  // 2016.04
let y17m01 = y16m01.calendarMonth(offsetByMonths: 12)  // 2017.01
let y15m01 = y16m01.calendarMonth(offsetByMonths: -12)  // 2015.01

y16m04.nextCalendarMonth  // 2016.05
y16m04.previousCalendarMonth  // 2016.03

let y16m02 = ZCalendarMonth(year: 2016, month: 02) // 2016.02
y16m02.daysInMonth // 29

let y16m02d29 = y16m02.day(29)  // 2016.02.29
let y16m03d01 = y16m02d29.nextCalendarDate  // 2016.03.01
y16m02d29 == y16m03d01.previousCalendarDate  // true

y16m02d29.calendarDayOfWeek // monday


```
