//
//  LiveGoodlineDownloader.swift
//  live goodline info
//
//  Created by Grigoriy on 07.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit
import CoreData

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
    
    var managedObjectContext:NSManagedObjectContext

    init(moc: NSManagedObjectContext)
    {
        self.managedObjectContext = moc
    }
    
	//TODO: передать дату самой поздней статьи, что бы не обновлять при пулл ту рефреше лишние статьи
	func getTopicList( pageIndex:	Int
		, startIndex:           Int
        , date:                 NSDate?
		, onResponseHandler:	([NewsElementContainer],Int, Bool)->Void
		, onUpdateImageHandler:	(Int, UIImage?)->Void
		, append:               Bool)
	{
		
		var imageIndex = startIndex
        var cachedNews: [NewsElementContainer] = []
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
        
        // если первая страница, то скачать данные,
        // спарсить, добавить в кэш новые данные( если есть),
        // скачать картинки по новым данным, отправить в tableView и обновить у кеши
        // вывести из кеши данные
        // выполнять в потоке
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue,
        {

            // поискать в кэше
            cachedNews = self.getData(date)

            //if pageIndex > 1
            //{
            //    // поискать в кэше
            //    cachedNews = self.getData(date)
            //}
            
            if cachedNews.count == 10 && pageIndex > 1
            {
                // если в кэше данных хватает и это не первая страница, то отображаем из кэша
                // UI  поток
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // есть нужные данные в кэше, можно их и вернуть
                    
                    //исключить кэшированные элементы с картинками
                    println("данные из кэша")

                    var arrayIndexesForUpdate: [ImageQueueStruct] = []
                    for currentNewsElement in cachedNews
                    {
                        if count(currentNewsElement.imageUrl) > 0 && currentNewsElement.previewImage == nil
                        {
                            // в очередь на скачивание картинок добавлять только элементы с пустой картинкой и непустой ссылкой
                            let itemForUpdateImage	= ImageQueueStruct(url: currentNewsElement.imageUrl, index: imageIndex)
                            arrayIndexesForUpdate.append(itemForUpdateImage)
                        }
                        else if count(currentNewsElement.imageUrl) == 0
                        {
                            // присвоить картинку по умолчанию
                            currentNewsElement.previewImage = UIImage(named:"goodline-logo-mini.png")
                        }
                        
                        imageIndex++;
                    }
                    
                    onResponseHandler(cachedNews, pageIndex, append)
                    if arrayIndexesForUpdate.count > 0
                    {
                        // запустить очередь обновления картинок
                        self.updateImages(arrayIndexesForUpdate, handler:onUpdateImageHandler)
                    }
                })
                
            }
            else
            {
                // если в кеше данных недостаточно, загрузить из сети
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

                        for var i = 0; i < cachedNews.count; i++
                        {
                            if i < topicList.count
                            {
                                topicList[i] = cachedNews[i]
                            }
                            else
                            {
                                topicList.append(cachedNews[i])
                            }
                        }
                        //self.addNessesaryNews(topicList, append:append)

                        // создаем список url с индексами для фоновой загрузки изображений
                        // индексы нужны для обновления нужного row tableView
                        //исключить кэшированные элементы с картинками
                        var arrayIndexesForUpdate: [ImageQueueStruct] = []
                        for currentNewsElement in topicList
                        {
                            if count(currentNewsElement.imageUrl) > 0 && currentNewsElement.previewImage == nil
                            {
                                // в очередь на скачивание картинок добавлять только элементы с пустой картинкой и непустой ссылкой
                                let itemForUpdateImage	= ImageQueueStruct(url: currentNewsElement.imageUrl, index: imageIndex)
                                arrayIndexesForUpdate.append(itemForUpdateImage)
                            }
                            else if count(currentNewsElement.imageUrl) == 0
                            {
                                // присвоить картинку по умолчанию
                                currentNewsElement.previewImage = UIImage(named:"goodline-logo-mini.png")
                            }
                            

                            imageIndex++;
                        }
                        // возвращаем результат в виде массива
                        onResponseHandler(topicList, pageIndex, append)
                        println("данные из сети")
                        
                        // запустить очередь обновления картинок
                        self.updateImages(arrayIndexesForUpdate, handler:onUpdateImageHandler)
                    },
                    failure:
                    { (operation: AFHTTPRequestOperation!,
                        error: NSError!) in
                        // если возникла ошибка во время подключения - загружать из кэша
                        println("данные из кэша")
                        onResponseHandler(cachedNews, pageIndex, append)

                        println("Error: " + error.localizedDescription)
                    }
                )
            }
        })

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
                        
                        // обновить в кеше
                        self.updateImagesCache(item.url, image: newImage)
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
	func getTopicPage(url:String, onResponseHandler:([ArticleElement])->Void)
	{
        // попытаться загрузить из кэша
        // выполнять в потоке
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue,
        {
                
            let cachedNewsBody:String  = self.getNewsByUrl(url)
            
            if count(cachedNewsBody) > 0
            {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let parser		= LiveGoodlineParser()
                    parser.parseNewsBlockFromString(cachedNewsBody, handler: onResponseHandler )
                    println("данные о странице из кэша")
                })
            }
            else
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
                        parser.parseNewsBlock(data, handler: onResponseHandler )
                        println("данные о странице из сети")
                        
                        // обновить в кэше данные о странице
                        self.updateNewsBodyInCash(url, body: parser.parseTopicNews(data).body)

                    },
                    failure:
                    { (operation: AFHTTPRequestOperation!,
                        error: NSError!) in
                        println("Error: " + error.localizedDescription)
                    }
                )
            }
            
        })
	}
    
    //---------------------- работа с CORE DATA -----------------------------------
    
    // добавить новые элементы в кэш
    private func addNessesaryNews(newsElements:[NewsElementContainer], append: Bool)
    {
        let maxCacheDate = getMaxDateInCache()
        let minCacheDate = getMinDateInCache()
        for newsItem in newsElements
        {
            if maxCacheDate != nil
            {
                // в кеше есть данные
                if append
                {
                    // данные добавляются в конец списка
                    // если дата новости больше сохраненной в кэше, добавить в кэш
                    if newsItem.compareDate(minCacheDate!) < 0 || newsItem.compareDate(maxCacheDate!) > 0
                    {
                        self.addNewsToCache(newsItem)
                    }
                }
                else
                {
                    // данные добавляются в начало списка
                    if newsItem.compareDate(maxCacheDate!) > 0
                    {
                        self.addNewsToCache(newsItem)
                    }
                }
            }
            else
            {
                // кеша пустой
                self.addNewsToCache(newsItem)
            }
        }
    }
    
    // максимальная дата в кэше
    private func getMaxDateInCache() -> NSDate?
    {
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        request.returnsObjectsAsFaults  = false
        request.predicate               = NSPredicate(format: "date == max(date)")
        request.fetchLimit              = 1
        if let results = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            if results.count > 0
            {
                return results[0].date
            }
        }
        return nil // кэш пуст
    }
    
    // минимальная дата в кэше
    private func getMinDateInCache() -> NSDate?
    {
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        request.returnsObjectsAsFaults  = false
        request.predicate               = NSPredicate(format: "date == min(date)")
        request.fetchLimit              = 1
        if let results = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            if results.count > 0
            {
                return results[0].date
            }
        }
        return nil // кэш пуст
    }
    
    // добавить новость в кэш
    private func addNewsToCache(news:NewsElementContainer)
    {
        NewsItemEntity.createInManagedObjectContext(managedObjectContext
            , news: news)
    }
    
    // обновить картинку в кеше
    private func updateImagesCache(imageUrl:String, image:UIImage)
    {
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        
        request.returnsObjectsAsFaults  = false
        request.fetchLimit              = 1
        request.predicate               = NSPredicate(format: "imageUrl = %@", imageUrl)
        //TODO: возможно нужно искать по времени или по url статьи
        if let results      = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            if results.count == 1
            {
                if results[0].preview.length == 0
                {
                    results[0].preview  = UIImageJPEGRepresentation(image, CGFloat(70))
                    managedObjectContext.save(nil)
                }
            }
        }
    }
    
    
    // извлечь данные о новостях из кэша
    private func getData(lastDate: NSDate?) -> [NewsElementContainer]
    {
        var result: [NewsElementContainer] = []
        
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        request.returnsObjectsAsFaults  = false
        request.fetchLimit              = 10
        if lastDate != nil
        {
            request.predicate   = NSPredicate(format: "date < %@", lastDate!)
        }
        let sortDescriptor  = NSSortDescriptor(key: "date", ascending: true)
        if let results      = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            for cachedItem in results
            {
                let newsItem = NewsElementContainer(title: cachedItem.title
                    , body: ""
                    , url: cachedItem.url
                    , imageUrl: cachedItem.imageUrl
                    , date:     cachedItem.date
                    , image:    cachedItem.preview)
                result.append(newsItem)
            }
        }
        return result
    }
    
    // обновить содержание статьи в кэше
    private func updateNewsBodyInCash(url: String, body:String)
    {
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        
        request.returnsObjectsAsFaults  = false
        
        request.fetchLimit              = 1
        request.predicate               = NSPredicate(format: "url = %@", url)
        //TODO: возможно нужно искать по времени
        if let results      = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            if results.count == 1
            {
                results[0].body  = body
                managedObjectContext.save(nil)
            }
        }
    }
    
    private func getNewsByUrl(url:String) -> String
    {
        var result = ""
        
        let request = NSFetchRequest(entityName: "NewsItemEntity")
        request.returnsObjectsAsFaults  = false
        request.fetchLimit              = 1
        request.predicate   = NSPredicate(format: "url = %@", url)
        if let results      = managedObjectContext.executeFetchRequest(request, error: nil) as? [NewsItemEntity]
        {
            if results.count == 1
            {
                return results[0].body
            }
        }
        return result
    }
}
