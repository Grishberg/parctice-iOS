//
//  ArticleBody.swift
//  live goodline info
//
//  Created by Grigoriy on 12.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

class ArticleBody: NSObject
{
    var articleElements:[ArticleElement]    = []
    var handler: ([ArticleElement]) ->Void
    
    init( handler: ([ArticleElement])-> Void )
    {
        self.handler = handler
    }
    
    // добавить текст
    func appendText(text: String)
    {
        if articleElements.count > 0
        {
            let lastIndex: Int  = articleElements.count - 1
            if articleElements[ lastIndex ].elementType == ArticleBodyElementType.Text
            {
                articleElements[ lastIndex ].appendText(text)
            }
            else
            {
                articleElements.append( ArticleElement(text: text))
            }
        }
        else
        {
            // первая строка, нужно обрезать пробелы слева
            
            let newArticleElement = ArticleElement(text: trimLeft(text))
            articleElements.append( newArticleElement)
        }
    }
    // проверка на пробелы и переносы строк
    private func isWhiteSpaceOrLF(chr: unichar) ->Bool
    {
        let whiteSpaces = " \t\r\n"
        var charArray = [unichar]()
        for codeUnit in whiteSpaces.utf16
        {
            charArray.append(codeUnit)
        }
        for w in charArray
        {
            if w == chr
            {
                return true
            }
        }
        return false
    }
    
    private func trimLeft(src: String) ->String
    {
        var charArray = [unichar]()
        for codeUnit in src.utf16
        {
            charArray.append(codeUnit)
        }
        var i = 0;
        let whiteSpaceChar = NSCharacterSet.whitespaceCharacterSet()
        for i = 0; i < charArray.count;  i++
        {
            if isWhiteSpaceOrLF( charArray[i]) == false
            {
                break;
            }
        }
        return  src.substringWithRange(Range<String.Index>(start: advance(src.startIndex, i), end: src.endIndex))
    }
    
    // добавить перевод строки
    func appendLF()
    {
        if articleElements.count > 0
        {
            let lastIndex: Int  = articleElements.count - 1
            if  articleElements[ lastIndex ].elementType == ArticleBodyElementType.Text ||
                articleElements[ lastIndex ].elementType == ArticleBodyElementType.Image
            {
                articleElements.append( ArticleElement(text: "\n") )
            }
        }
    }
    
    // добавить картинку  в тело новости
    func appendImage(url: String)
    {
        let newArticleElement = ArticleElement(imageUrl: url, handler: onUpdateImage)
        articleElements.append( newArticleElement  )
        
    }
    
    func onUpdateImage()
    {
        handler(articleElements)
    }
    
    // вернуть форматированную строку для отображения
    func getAttributedString() -> NSMutableAttributedString
    {
        var bodyString:NSMutableAttributedString = NSMutableAttributedString()

        for bodyElement in self.articleElements
        {
            switch( bodyElement.elementType)
            {
            case ArticleBodyElementType.Image:
                    var attachment = NSTextAttachment()
                    attachment.image    = bodyElement.image
                    attachment.bounds   = CGRectMake( 0 , 0 , 320 , 320)
                    var attachmentString = NSAttributedString(attachment: attachment)
                    bodyString.appendAttributedString(attachmentString)
            default:
                bodyString.appendAttributedString(bodyElement.attachmentString!)
            }
        }
        return bodyString
    }
}
