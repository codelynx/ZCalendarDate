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


