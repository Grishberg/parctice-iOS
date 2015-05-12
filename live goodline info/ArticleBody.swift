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

    // добавить текст
    func appendText(text: String)
    {
        if articleElements.count > 0
        {
            let lastIndex: Int  = articleElements.count - 1
            if articleElements[ lastIndex ].isImage == false
            {
                articleElements[ lastIndex ].appendText(text)
            }
            
        }
        else
        {
            let newArticleElement = ArticleElement(text: text)
            articleElements.append( newArticleElement)
        }
    }
}
