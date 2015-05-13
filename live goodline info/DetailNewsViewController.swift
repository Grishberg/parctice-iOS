//
//  DetailNewsViewController.swift
//  live goodline info
//
//  Created by Grigoriy on 08.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

class DetailNewsViewController: UIViewController
{

	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var bodyLabel: UILabel!
	//var bodyLabel: UILabel!
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	@IBOutlet weak var progressControl: UIActivityIndicatorView!
	
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
	// переменные для передачи информации, пока экземпляры контролов еще не создались.
	var titleText: String	= ""
	var newsUrl: String		= ""
    
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		// настройка контролов
		self.progressControl.hidesWhenStopped	= true
		self.titleLabel.numberOfLines	= 0
		self.titleLabel.text			= titleText
		self.bodyLabel.text				= ""
		self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		self.bodyLabel.numberOfLines	= 0
		self.scrollView.addSubview(bodyLabel)
		self.progressControl.startAnimating()
		
		// начать загрузку страницы
        var downloader:LiveGoodlineDownloader = LiveGoodlineDownloader(moc: managedObjectContext!)
		downloader.getTopicPage(self.newsUrl, onResponseHandler:  onReceivedNews)
    }
	
    private func calculateImageBounds(parentBounds: CGRect, imageBounds: CGSize) ->CGRect
    {
        var result:CGRect
        let imageRatio: CGFloat   = imageBounds.width / imageBounds.height
        let imageNewWidth:CGFloat = parentBounds.width
        let imageNewHeight: CGFloat = parentBounds.width / imageRatio
        result  = CGRectMake(0, 0, imageNewWidth, imageNewHeight)
        
        return result
    }
	// функция вызывается при загрузке страницы
	func onReceivedNews(body:[ArticleElement])
	{
		// отобразить страницу
        
        var bodyString:NSMutableAttributedString = NSMutableAttributedString()
        var labelBounds:CGRect = bodyLabel.bounds
        
        for bodyElement in body
        {
            switch( bodyElement.elementType)
            {
            case ArticleBodyElementType.Image:
                if bodyElement.image != nil
                {
                    var attachment = NSTextAttachment()
                    attachment.image    = bodyElement.image
                    attachment.bounds   = calculateImageBounds(bodyLabel.bounds, imageBounds: attachment.image!.size)
                    var attachmentString = NSAttributedString(attachment: attachment)
                    bodyString.appendAttributedString(attachmentString)
                }
            default:
                bodyString.appendAttributedString(bodyElement.attachmentString!)
            }
        }


        bodyLabel.attributedText = bodyString

        //attachment.image = UIImage(named:"goodline-logo-mini.png")

        //var attachmentString = NSAttributedString(attachment: attachment)
        
        /*
		var attrStr = NSAttributedString(
			data: body.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
			options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
			documentAttributes: nil,
			error: nil)
*/
//		bodyLabel.attributedText = bodyText
        //bodyLabel.text = bodyText
        // остановить индикатор хода процесса
        self.progressControl.stopAnimating()
	
	}

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setNewsData(title:String, url:String)
	{
		self.titleText	= title
		self.newsUrl	= url
		
	}

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
