//
//  CarouselView.swift
//  VideoScrubber
//
//  Created by Abheyraj Singh on 15/07/15.
//  Copyright © 2015 Housing Labs. All rights reserved.
//

import UIKit

class CarouselView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.view = NSBundle.mainBundle().loadNibNamed("CarouselView", owner: self, options: nil)[0] as! UIView
        self.frame = frame
        self.view.frame = self.frame
        self.view.setNeedsLayout()
        self.addSubview(view)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
