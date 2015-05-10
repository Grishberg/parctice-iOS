//
//  TopicNewsViewController.swift
//  live goodline info
//
//  Created by Grigoriy on 08.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

class TopicNewsViewController: UIViewController {

	let ROW_HEIGHT				= CGFloat(101)
	let CUSTOM_CELL_XIB_NAME	= "CustomViewCell"
	let ROWS_COUNT_BEFORE_START_UPDATE:Int	= 4
	@IBOutlet weak var tableView: UITableView!
	var refreshControl:UIRefreshControl!
	var newsElements:[NewsElementContainer] = []
	var loadMoreStatus	= false
	var currentPage		= 1
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// настройка пул ту рефреш
		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
		refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		tableView.addSubview(refreshControl)

		self.view.layoutSubviews()
		// загрузка первой страницы
		loadMore(currentPage, append: true)
	}
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// отслеживание состояния скролла
	func scrollViewDidScroll(scrollView: UIScrollView!)
	{
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
		let deltaOffset = maximumOffset - currentOffset -  self.ROW_HEIGHT * 4
		
		if deltaOffset <= 0
		{
			if loadMoreStatus == false
			{
				loadMore(currentPage + 1, append: true)
			}
		}
	}
	
	//--------------- подгрузить новую порцию данных
	func loadMore(page: Int, append:Bool)
	{
		loadMoreStatus = true
		var downloader:LiveGoodlineDownloader = LiveGoodlineDownloader()
		downloader.getTopicList(page
			, startIndex: self.newsElements.count
			, onResponseHandler: onReceivedTopicNews
			, onUpdateImageHandler: onReceivedUpdateImage
			, append: append)
	}
	
	// обработка скаченного списка новостей
	func onReceivedTopicNews(topicList:[NewsElementContainer], page:Int, append:Bool) -> Void
	{
		loadMoreStatus	= false
		if topicList.count > 0
		{
			if append || self.newsElements.count == 0 //если происходило обновление во время прокрутки вниз
			{
				self.currentPage = page
				for element in topicList
				{
					self.newsElements.append(element)
				}
			}
			else // если происходило обновление во время пул ту рефреша
			{
				let maxIndex	= topicList.count - 1
				for var i = maxIndex; i >= 0; --i
				{
					let element = topicList[i]
					
					if element.compare(self.newsElements[0]) > 0
					{
						self.newsElements.insert(element, atIndex: 0)
					}
				}
				self.refreshControl.endRefreshing()
				
			}
			//TODO: обновить только нужные элементы
			self.tableView.reloadData()
		}
		
	}
	
	//обработка закаченной картинки
	func onReceivedUpdateImage(index:Int, image:UIImage?) -> Void
	{
		self.newsElements[index].previewImage = image
		// оновить нужный элемент
		let row: NSIndexSet = NSIndexSet(index: index)
		let col: NSIndexSet = NSIndexSet(index: 0)
		//TODO: обновить только нужные элементы
		self.tableView.reloadData()
	}

}

extension TopicNewsViewController: UITableViewDataSource
{
	// количество элементов
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return newsElements.count
	}
	// высота ячейки
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		return self.ROW_HEIGHT
	}
	
	// отрисовка ячейки
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? CustomViewCell
		if cell == nil
		{
			let topLevelObjects = NSBundle.mainBundle().loadNibNamed(CUSTOM_CELL_XIB_NAME, owner: self, options: nil)
			for currentObject in topLevelObjects
			{
				if currentObject is UITableViewCell
				{
					cell = currentObject as? CustomViewCell
				}
			}
		}
		if cell != nil
		{
			
			// изменяем задний фон на каждой четной ячейке
			if indexPath.row % 2 == 0
			{
				cell!.backgroundColor	= UIColor.orangeColor()
			}
			else
			{
				cell!.backgroundColor	= UIColor.grayColor()
			}
			
			let newsElement = newsElements[indexPath.row]
			// если картинки нет - запустить индикатор хода процесса, если есть - остановить индикатор
			if newsElement.previewImage == nil
			{
				cell?.startProgress()
			}
			else
			{
				cell?.stopProgress()
			}
			cell!.setDataContainer(newsElement.title, date:newsElement.dateString, image:newsElement.previewImage)

		}
		return cell!
	}
	
	// событие при нажатии на элементе tableView
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let currentNews = newsElements[indexPath.row]
		tableView.deselectRowAtIndexPath(indexPath, animated:true)
		var viewController: DetailNewsViewController = DetailNewsViewController(nibName: "DetailNewsViewController",bundle: nil)
		
		viewController.setNewsData(currentNews.title, url:currentNews.url)
		self.navigationController?.pushViewController(viewController, animated: true)
		//self.presentViewController(viewController, animated: true, completion: nil)
	}
	// вызывается во время пул ту рефреш
	func refresh(sender:AnyObject)
	{
		loadMore(1 , append: false)
	}
}

extension TopicNewsViewController: UITableViewDelegate
{
	
}
