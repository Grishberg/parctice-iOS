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
	
	// парсинг страницы с новостью, необхдимо для сохранения в кэше тела новости
    func parseTopicNews(content:NSData) -> NewsElementContainer
	{
		var result:NewsElementContainer = NewsElementContainer()
		var body:String = ""
		let parser		= TFHpple(HTMLData:content)
		let patternStr	= "//article/div/div[@class='topic-content text']"
		
		if let articles = parser.searchWithXPathQuery(patternStr) as? [TFHppleElement]
		{
			if articles.count == 1
			{
				body = articles[0].raw
            }
		}
        
		result	= NewsElementContainer(title: "", body: body, url: "", imageUrl: "", dateString: "")
		return result
	}

    // новый парсинг статьи
    func parseNewsBlock(content:NSData, handler: ([ArticleElement])->Void ) -> ArticleBody
    {
        let articleBody    = ArticleBody(handler: handler)
        
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
                
                self.parseArticleBlock( articles[0], body:articleBody )
            }
        }
        handler(articleBody.articleElements)
        return articleBody
    }
    // парсинг из строки
    func parseNewsBlockFromString(contentString:String, handler: ([ArticleElement])->Void ) -> ArticleBody
    {
        let articleBody    = ArticleBody(handler: handler)
        
        var pageArray:[ArticleElement]  = []
        var result:NewsElementContainer = NewsElementContainer()
        let contentData: NSData = (contentString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        let parser		= TFHpple(HTMLData:contentData)
        let patternStr	= "//div[@class='topic-content text']"
        
        if let articles = parser.searchWithXPathQuery(patternStr) as? [TFHppleElement]
        {
            if articles.count == 1
            {
                self.parseArticleBlock( articles[0], body:articleBody )
            }
        }
        handler(articleBody.articleElements)
        return articleBody
    }

    
    // рекурсивный поиск нужных элементов
    private func parseArticleBlock(block:TFHppleElement, body: ArticleBody)
    {
        // цикл по детям
        for currentElement in block.children as! [TFHppleElement]
        {
            // распознать очередной элемент
            let tagName     = currentElement.tagName
            let tagContent  = currentElement.content
            switch (tagName)
            {
            case    "br":
                body.appendLF()
            case    "strong","h1","h2","h3","h4","h5","h6","blockquote", "em","s","ol","a":
                self.parseArticleBlock(currentElement, body: body)
            case    "li":
                body.appendLF()
                self.parseArticleBlock(currentElement, body: body)
            case    "img":
                let imageUrlAttr        = currentElement.objectForKey("src")
                body.appendImage(imageUrlAttr)
            case    "text":
                body.appendText( tagContent )
            default:
                println("new tag \(tagName)")
                
            }
        }
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
