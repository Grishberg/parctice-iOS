//
//  CustomViewCell.swift
//  live goodline info
//
//  Created by Grigoriy on 08.05.15.
//  Copyright (c) 2015 Grigoriy. All rights reserved.
//

import UIKit

class CustomViewCell: UITableViewCell {


	@IBOutlet weak var previewImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	@IBOutlet weak var progressControl: UIActivityIndicatorView!
	var isAnimationStarted = false
    override func awakeFromNib()
	{
        super.awakeFromNib()
		progressControl.hidesWhenStopped = true
		titleLabel.numberOfLines	= 3
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func setDataContainer(title:String, date:String, image:UIImage?)
	{
		self.titleLabel.text	= title
		self.dateLabel.text		= date
		self.previewImage.image	= image
		
	}
	
	func startProgress()
	{
		if self.isAnimationStarted == false
		{
			progressControl.hidden	= false
			progressControl.startAnimating()
			self.isAnimationStarted	= true
		}
	}
	func stopProgress()
	{
		if self.isAnimationStarted == true
		{
			progressControl.stopAnimating()
			self.isAnimationStarted = false
		}
	}


}
