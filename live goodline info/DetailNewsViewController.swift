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
	
	var titleText: String = ""
	var newsUrl: String = ""
    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.progressControl.hidesWhenStopped	= true
        // Do any additional setup after loading the view.
		self.titleLabel.numberOfLines	= 0
		self.titleLabel.text			= titleText
		self.scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		//bodyLabel = UILabel()
		self.bodyLabel.numberOfLines	= 0
		self.scrollView.addSubview(bodyLabel)
		self.progressControl.startAnimating()
				// начать загрузку страницы
		var downloader:LiveGoodlineDownloader = LiveGoodlineDownloader()
		downloader.getTopicPage(self.newsUrl, onResponseHandler:  onReceivedNews)
    }
	
	// функция вызывается при загрузке страницы
	func onReceivedNews(newsElement:NewsElementContainer)
	{
		// остановить индикатор хода процесса
		self.progressControl.stopAnimating()
		// отобразить страницу
		var attrStr = NSAttributedString(
			data: newsElement.body.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
			options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
			documentAttributes: nil,
			error: nil)
		bodyLabel.attributedText = attrStr
	
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

	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
