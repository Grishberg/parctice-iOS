//
//  NewsItemEntity.swift
//  live goodline info
//
//  Created by Grigoriy on 11.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
// модель данных core data

import Foundation
import CoreData

class NewsItemEntity: NSManagedObject
{

    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var date: NSDate
    @NSManaged var preview: NSData
    @NSManaged var imageUrl: String
    @NSManaged var body: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext
        ,news: NewsElementContainer) -> NewsItemEntity
    {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("NewsItemEntity", inManagedObjectContext: moc) as! NewsItemEntity
        newItem.title       = news.title
        newItem.url         = news.url
        newItem.date        = news.getDate()
        newItem.imageUrl    = news.imageUrl
        newItem.body        = news.body
        if news.previewImage != nil
        {
            newItem.preview = UIImageJPEGRepresentation(news.previewImage, CGFloat(70))
        }
        moc.save(nil)
        return newItem
    }

}
