#pragma once
#define CALENDAR_WIDTH 7
#define CALENDAR_HEIGHT 6

struct DayTraffic
{
	int day;
	__int64 up_traffic;
	__int64 down_traffic;
	bool mixed;
	CRect rect;

	__int64 traffic() const
	{
		return up_traffic + down_traffic;
	}
};

class CCalendarHelper
{
public:
	CCalendarHelper();
	~CCalendarHelper();

	// Whether it is a leap year
	static bool IsLeapYear(int year);
	// Calculate the day of the week (0~6 represent Sunday~Saturday)
	static int CaculateWeekDay(int y, int m, int d);
	// Number of days in a given month
	static int DaysInMonth(int year, int month);

	// Get the traffic data for the specified month and fill it into the calendar array
	// If sunday_first is true, Sunday is the first day of the week; otherwise, Monday is the first day of the week
	static void GetCalendar(int year, int month, DayTraffic calendar[CALENDAR_HEIGHT][CALENDAR_WIDTH], bool sunday_first = true);

};

