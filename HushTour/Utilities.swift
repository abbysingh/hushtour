//
//  Utilities.swift
//  VideoScrubber
//
//  Created by Abheyraj Singh on 07/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import Foundation

class Utilities {
    class func getTimeStringForInterval(interval: NSTimeInterval) -> String{
        let minutes = floor(interval/60)
        let seconds = round(interval - minutes * 60)
        return "\(Int(minutes)):\(Int(seconds))"
    }
}
