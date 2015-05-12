//
//  LiveGoodlineParser.swift
//  live goodline info
//
//  Created by Grigoriy on 08.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//	Парсер live.goodline.info

import UIKit

class LiveGoodlineParser: NSObject
{
	// парсинг списка новостей
	func parseTopicListNews(content:NSData) -> [NewsElementContainer]
	{
		var result:[NewsElementContainer] = []
		
		let parser = TFHpple(HTMLData:content)
		
		let patternStr			= "//article"

		if let articles = parser.searchWithXPathQuery(patternStr) as? [TFHppleElement]
		{
			for article in articles
			{
				var imageUrl	= ""
				var title	= ""
				var body	= ""
				var url		= ""
				var dateString	= ""
				//------------- блок с картинкой
				
				//TODO: проверить с на nil или количество элементов
				if let imageUrlOpt	= getElementByXPath(article, path: "//div[@class='preview']/a/img",attr: "src")
				{
					imageUrl = imageUrlOpt
				}
				
				//------------- блок с описанием
				//  время
				if let dateStringOpt	= getElementByXPath(article, path: "//div[@class='wraps out-topic']/header/time",attr: "datetime")
				{
					dateString = dateStringOpt
				}
				
				// url  на статью
				if let urlOpt	= getElementByXPath(article, path: "//div[@class='wraps out-topic']/header/h2/a",attr: "href")
				{
					url = urlOpt
				}

				// title
				if let titleOpt	= getElementByXPath(article, path: "//div[@class='wraps out-topic']/header/h2/a")
				{
					title = titleOpt
				}

				var newsElement = NewsElementContainer(title: title, body: body, url: url, imageUrl: imageUrl, dateString:dateString)
				result.append(newsElement)
				
			}
		}
		
		return result
	}
	
	// парсинг страницы с новостью
	func parseTopicNews(content:NSData) -> NewsElementContainer
	{
        var pageArray:[ArticleElement]  = []
		var result:NewsElementContainer = NewsElementContainer()
		var body:String = ""
		let parser		= TFHpple(HTMLData:content)
		let patternStr	= "//article/div/div[@class='topic-content text']"
		
		if let articles = parser.searchWithXPathQuery(patternStr) as? [TFHppleElement]
		{
			if articles.count == 1
			{
				body = articles[0].raw
                
                pageArray = self.parseBlock( articles[0] )
			}
		}

        
        // необходимая операция для отображения картинок в удобном для просмотра масштабе
		body = body.stringByReplacingOccurrencesOfString( "<img ", withString: "<img width=\"40%\" height=auto align=\"center\" "
				, options: nil
				, range:nil)
        
        
		result	= NewsElementContainer(title: "", body: body, url: "", imageUrl: "", dateString: "")
		return result
	}
    
    private func parseBlock(block:TFHppleElement) ->[ArticleElement]
    {
        var articleElements:[ArticleElement]    = []
        var currentText:String                  = ""
        /*
        // цикл по детям
        for currentElement in block[0].children as! [TFHppleElement]
        {
            // распознать очередной элемент
            let tagName     = currentElement.tagName
            let tagContent  = currentElement.content
            switch (tagName)
            {
                case    "br":
                case    "a":
                case    "strong":
                case    "img":
                    let imageUrlAttr        = currentElement.objectForKey("src")
                    let newArticleElement   = ArticleElement(imageUrl: imageUrlAttr)
                    articleElements.append(newArticleElement)
                case    "text":
                    currentText += tagContent
                default:
                
            }
            
            println("str")
        }

        */
        return articleElements
    }
	// --------- вспомогательные функции -----------
	
	// поиск элемента
	private func getElementByXPath(parent:TFHppleElement, path:String, attr:String) ->String?
	{
		var result:String?
		// TODO: метод возвращает Nodes was nil. если не находит путь, нужно разобраться
		if let blockArray	= parent.searchWithXPathQuery(path) as? [TFHppleElement]
		{
			if blockArray.count > 0
			{
				return blockArray[0].objectForKey(attr);
			}
		}
		return result
	}
	
	// поиск содержимого
	private func getElementByXPath(parent:TFHppleElement, path:String) ->String?
	{
		var result:String?
		
		if let blockArray	= parent.searchWithXPathQuery(path) as? [TFHppleElement]
		{
			if blockArray.count > 0
			{
				return blockArray[0].content;
			}
		}
		return result
	}
	
	
	
	
	
}
