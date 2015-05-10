//
//  NewsElementContainer.swift
//  live goodline info
//
//  Created by Grigoriy on 07.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

class NewsElementContainer: NSObject
{

	var title:			String
	var body:			String
	var url:			String
	var dateString:		String	= ""
	var imageUrl:		String
	var previewImage:	UIImage?
	var newsTime:NSDateComponents?
	
	override init()
	{
		self.title		= ""
		self.body		= ""
		self.url		= ""
		self.imageUrl	= ""
		self.dateString	= ""
	}
	
	init (title:String, body: String, url:String, imageUrl:String, dateString:String)
	{
		self.title		= title
		self.body		= body
		self.url		= url
		self.imageUrl	= imageUrl
		self.dateString	= dateString
		
		//сконвертировать строку в формат времени, а далее в красивое представление времени
		if count(self.dateString) > 0
		{
			var dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			if let datetime = dateFormatter.dateFromString(self.dateString)
			{
				let components = NSCalendarUnit.CalendarUnitDay |
					NSCalendarUnit.CalendarUnitHour |
					NSCalendarUnit.CalendarUnitMinute |
					NSCalendarUnit.CalendarUnitSecond |
					NSCalendarUnit.CalendarUnitMonth |
					NSCalendarUnit.CalendarUnitYear
				let calendar		= NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
				let componentDate	= calendar.components(components, fromDate: datetime)
				let currentDate		= calendar.components(components, fromDate: NSDate() )
				
				var timePrefix	= ""
				// проверить, была ли статься опубликована сегодня
				if currentDate.year		== componentDate.day &&
					currentDate.month	== componentDate.month &&
					currentDate.day		== componentDate.year
				{
					timePrefix	= "Сегодня"
				} //  была ли статься опубликована вчера
				else if currentDate.year	== componentDate.day &&
						currentDate.month	== componentDate.month &&
						currentDate.day-1	== componentDate.year
				{
					timePrefix	= "Вчера"
				} else
				{
					timePrefix = String(format:"%02d", componentDate.day)+"."+String(format:"%02d", componentDate.month)+"."+String(format:"%04d", componentDate.year)
				}
				self.dateString = timePrefix + " " + String(format:"%02d", componentDate.hour)+":"+String(format:"%02d", componentDate.minute)
				self.newsTime	= componentDate
			}
		}
	}
	func compare(value:NewsElementContainer) -> Int
	{
		if self.newsTime == nil || value.newsTime == nil
		{
			return -1
		}
		let calendar	= NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		
		let date1 = calendar.dateFromComponents(self.newsTime!)
		let date2 = calendar.dateFromComponents(value.newsTime!)
		let res = date1!.compare(date2!)
		if date1!.compare(date2!) == NSComparisonResult.OrderedAscending
		{
			return -1
		}
		
		if date1!.compare(date2!) == NSComparisonResult.OrderedDescending
		{
			return 1
		}
		
		if date1!.compare(date2!) == NSComparisonResult.OrderedSame
		{
			return 0
		}
		return -1
		
	}
}