//
//  LiveGoodlineDownloader.swift
//  live goodline info
//
//  Created by Grigoriy on 07.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

struct ImageQueueStruct
{
	var url:	String	= ""
	var index:	Int		= 0
	init(url:String, index: Int)
	{
		self.index	= index
		self.url	= url
	}
}

class LiveGoodlineDownloader: NSObject
{
	let MAIN_URL		= "http://live.goodline.info/guest/"
	
	//TODO: передать дату самой поздней статьи, что бы не обновлять при пулл ту рефреше лишние статьи
	func getTopicList( pageIndex:	Int
		, startIndex:	Int
		, onResponseHandler:		([NewsElementContainer],Int, Bool)->Void
		, onUpdateImageHandler:	(Int, UIImage?)->Void
		, append:Bool)
	{
		
		var imageIndex = startIndex
		if append == false
		{
			imageIndex = 0
		}
		// преобразовать URL
		var urlString:String = MAIN_URL
		if pageIndex > 1
		{
			urlString += "page\(pageIndex)/"
		}
		
		let manager = AFHTTPRequestOperationManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		manager.GET( urlString, parameters: nil,
			success:
			{ (operation: AFHTTPRequestOperation!,
				responseObject: AnyObject!) in
				
				// получили ответ, responseObject - это NSData
				let data:NSData	= responseObject as! NSData

				// парсим данные
				let parser		= LiveGoodlineParser()
				var topicList:[NewsElementContainer]	= parser.parseTopicListNews(data)

				//////////////////////////////////////
				// для отладки пул ту рефреша
				//////////////////////////////////////
				if pageIndex == 1 && append
				{
					topicList.removeAtIndex(0)
				}
				//////////////////////////////////////

				// создаем список url с индексами для фоновой загрузки изображений
				// индексы нужны для обновления нужного row tableView
				var arrayIndexesForUpdate: [ImageQueueStruct] = []
				for currentNewsElement in topicList
				{
					if count(currentNewsElement.imageUrl) > 0
					{
						let itemForUpdateImage	= ImageQueueStruct(url: currentNewsElement.imageUrl, index: imageIndex)
						arrayIndexesForUpdate.append(itemForUpdateImage)
					}

					imageIndex++;
				}
				// возвращаем результат в виде массива
				onResponseHandler(topicList, pageIndex, append)
				
				// запустить очередь обновления картинок
				self.updateImages(arrayIndexesForUpdate, handler:onUpdateImageHandler)
			},
			failure:
			{ (operation: AFHTTPRequestOperation!,
				error: NSError!) in
				println("Error: " + error.localizedDescription)
			}
		)
	}
	// фоновое обновление картинок
	private func updateImages(itemsForUpdate: [ImageQueueStruct], handler: (Int, UIImage?)->Void )
	{
		
		let manager	= AFHTTPRequestOperationManager()
		manager.responseSerializer	= AFHTTPResponseSerializer()
		for item in itemsForUpdate
		{
			manager.GET( item.url, parameters: nil,
				success:
				{ (operation: AFHTTPRequestOperation!,
					responseObject: AnyObject!) in
					
					// получили ответ, responseObject - это NSData
					let data:NSData	= responseObject as! NSData
					if let newImage = UIImage(data: data)
					{
						// обновить картинку
						handler(item.index, newImage)
					}
				},
				failure:
				{ (operation: AFHTTPRequestOperation!,
					error: NSError!) in
					println("Error: " + error.localizedDescription)
				}
			)
		}
	}
	
	// загрузка статьи
	func getTopicPage(url:String, onResponseHandler:(NewsElementContainer)->Void)
	{
		let manager	= AFHTTPRequestOperationManager()
		manager.responseSerializer	= AFHTTPResponseSerializer()
		manager.GET( url, parameters: nil,
			success:
			{ (operation: AFHTTPRequestOperation!,
				responseObject: AnyObject!) in
				
				// получили ответ, responseObject - это NSData
				let data:NSData	= responseObject as! NSData
				
				// парсим данные
				let parser		= LiveGoodlineParser()
				onResponseHandler( parser.parseTopicNews(data))

			},
			failure:
			{ (operation: AFHTTPRequestOperation!,
				error: NSError!) in
				println("Error: " + error.localizedDescription)
			}
		)
	}
}
