//
//  ArticleElement.swift
//  live goodline info
//
//  Created by Grigoriy on 12.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit
class ArticleElement: NSObject
{
    var isImage:Bool    = false
    var text:String     = ""
    var image:UIImage?  = nil
    var imageUrl:String = ""
    
    init(text: String)
    {
        isImage     = false
        self.text   = text
    }
    
    init(image:UIImage)
    {
        isImage     = true
        self.image  = image
    }
    
    init(imageUrl:String)
    {
        isImage     = true
        self.imageUrl  = imageUrl
        //TODO: можно начать загрузку фото в фоне
    }
    
    func appendText(text:String)
    {
        self.text += text
    }
}
