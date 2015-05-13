//
//  ArticleElement.swift
//  live goodline info
//
//  Created by Grigoriy on 12.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit
enum ArticleBodyElementType
{
    case Image
    case Text
    case LF
}

class ArticleElement: NSObject
{
    var elementType:ArticleBodyElementType    = ArticleBodyElementType.LF
    var text:String     = ""
    var imageUrl:String = ""
    var image:UIImage?
    
    var attachmentString:NSAttributedString?

    
    override init ()
    {
        attachmentString    = NSAttributedString(string: "\n")
        elementType = ArticleBodyElementType.LF
    }
    
    init(text: String)
    {
        elementType = ArticleBodyElementType.Text
        self.text   = text
        attachmentString    = NSAttributedString(string: text)
    }
    
    init(image:UIImage)
    {
        elementType = ArticleBodyElementType.Image
        self.image  = image

    }
    
    init(imageUrl:String, handler:(Void)->Void)
    {
        super.init()
        elementType     = ArticleBodyElementType.Image
        self.imageUrl   = imageUrl

        // в фоне загрузить изображение
        //TODO: делать это в классе загрузчика, учитывая кэш
        
        let manager     = AFHTTPRequestOperationManager()
        manager.responseSerializer	= AFHTTPResponseSerializer()
        
        manager.GET( imageUrl, parameters: nil,
            success:
            { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                
                // получили ответ, responseObject - это NSData
                let data:NSData	= responseObject as! NSData
                if let newImage = UIImage(data: data)
                {
                    self.image  = newImage
                    handler()
                }
            },
            failure:
            { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
            }
        )

    }
    
    func appendText(text:String)
    {
        self.text += text
        
        let newString = attachmentString!.string + text
        attachmentString = NSAttributedString(string: newString)
    }
}
