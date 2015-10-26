//
//  ViewController.swift
//  VideoScrubber
//
//  Created by Abheyraj Singh on 06/07/15.
//  Copyright (c) 2015 Housing Labs. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import SnapKit

class ViewController: UIViewController,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, iCarouselDataSource, iCarouselDelegate {
    
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet var carousel: iCarousel!
    @IBOutlet var blurOverlayView: UIVisualEffectView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    var player : MPMoviePlayerController!
    var bezierPath : UIBezierPath!
    var positionMarker: UIView!
    var rooms: NSMutableArray!
    var overlayLabel: UILabel!
    var carouselPreviousSelectedIndex = 0
    let roomTitles = ["Intro","Entry","Balcony","Living Room", "Master Bathroom", "Rec Room", "Outside", "Pool", "Poolside", "Laundry Room"]
    let imagesArray:NSMutableArray = {
            let array = NSMutableArray()
            for i in 0...9{
                array.addObject(UIImage(named: "\(i).png")!)
            }
            return array
    }()
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        blurOverlayView.effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        addMaskView()
        var dismissButton1:UIButton,dismissButton2:UIButton
        dismissButton1 = UIButton(frame: CGRectMake(30, 30, 30, 30))
        dismissButton1.setImage(UIImage(named: "Cross"), forState: UIControlState.Normal)
        self.overlayView.addSubview(dismissButton1)
        dismissButton2 = UIButton(frame: CGRectMake(30, 30, 30, 30))
        dismissButton2.setImage(UIImage(named: "Cross"), forState: UIControlState.Normal)
        self.blurOverlayView.contentView.addSubview(dismissButton2)
        dismissButton1.addTarget(self, action: "hideCardsOverlay", forControlEvents: UIControlEvents.TouchUpInside)
        dismissButton2.addTarget(self, action: "hideBlurOverlay", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.overlayView.alpha = 0
        self.overlayView.hidden = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        collectionView.contentInset = UIEdgeInsetsMake(0, collectionView.frame.width/3, 0, 0)
        rooms = NSMutableArray()
        for i in 0...10{
            rooms.addObject("Room \(i)")
        }
        rooms = getThumbnails()
        collectionView.reloadData()
        self.carousel.type = iCarouselType.Custom
        self.carousel.bounces = false
        self.carousel.dataSource = self
        self.carousel.delegate = self
        self.carousel.vertical = true
        self.carousel.pagingEnabled = false
        self.carousel.decelerationRate = 0.8
        carousel.reloadData()
        mapImageView.image = imagesArray[0] as! UIImage
//        positionMarker = UIView(frame: CGRectMake(0, 0, 30, 30))
//        positionMarker.backgroundColor = UIColor.redColor();
//        setUpBezierPath()
//        setupAnimationForPositionMarker()
//        self.overlayView.addSubview(positionMarker)
        if let
            path = NSBundle.mainBundle().pathForResource("Tour", ofType: "mp4"),
            url:NSURL = NSURL.fileURLWithPath(path){
                self.player = MPMoviePlayerController(contentURL: url)
                self.player.fullscreen = true
                self.player.view.frame = self.view.frame
                self.player.controlStyle = MPMovieControlStyle.None
                self.view.insertSubview(self.player.view, belowSubview: self.overlayView)
                self.player.view.snp_makeConstraints{ (make) -> Void in
                    make.edges.equalTo(self.player.view.superview!)
                }
                self.player.prepareToPlay()
                let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
//                panGesture.delegate = self
//                panGesture.addTarget(self, action: "handlePan:")
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
                tapGesture.delegate = self;
                tapGesture.addTarget(self, action: "handleTap:")
                blurOverlayView.addGestureRecognizer(tapGesture)
                let horizontalSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
                horizontalSwipe.direction = UISwipeGestureRecognizerDirection.Left
                horizontalSwipe.addTarget(self, action: "swipeLeft:")
                horizontalSwipe.delegate = self
                self.player.view.addGestureRecognizer(horizontalSwipe)
                self.player.view.addGestureRecognizer(panGesture)
                self.player.view.addGestureRecognizer(tapGesture)
        }
//        self.blurOverlayView.underlyingView = self.player.view
        self.blurOverlayView.tintColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        if(size.width > size.height){
//            
//        }else{
//            self.mapImageView.snp_remakeConstraints{ (make) -> Void in
//                make.leading.equalTo(0)
//                make.top.equalTo(0)
//                make.height.equalTo(size.height/2)
//                make.width.equalTo(self.mapImageView.superview!)
//            }
//            self.carousel.snp_remakeConstraints{ (make) -> Void in
//                make.bottom.equalTo(0)
//                make.leading.equalTo(0)
//                make.height.equalTo(size.height/2)
//                make.width.equalTo(self.mapImageView.superview!)
//            }
//        }
//    }
    
//    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        if(toInterfaceOrientation == UIInterfaceOrientation.Portrait){
//                    self.mapImageView.snp_remakeConstraints{ (make) -> Void in
//                        make.leading.equalTo(0)
//                        make.top.equalTo(0)
//                        make.height.equalTo(400)
//                        make.width.equalTo(self.mapImageView.superview!)
//                    }
//                    self.carousel.snp_remakeConstraints{ (make) -> Void in
//                        make.bottom.equalTo(0)
//                        make.trailing.equalTo(0)
//                        make.height.equalTo(400)
//                        make.width.equalTo(self.carousel.superview!)
//                    }
//        }
//    }
    
    func setUpBezierPath(){
        self.bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(28.5, 52.5))
        bezierPath.addCurveToPoint(CGPointMake(89.5, 52.5), controlPoint1: CGPointMake(65.5, 34.5), controlPoint2: CGPointMake(89.5, 52.5))
        bezierPath.addLineToPoint(CGPointMake(56.5, 80.5))
        bezierPath.addLineToPoint(CGPointMake(146.5, 93.5))
        bezierPath.addLineToPoint(CGPointMake(165.5, 46.5))
        bezierPath.addLineToPoint(CGPointMake(132.5, 22.5))
        bezierPath.addLineToPoint(CGPointMake(209.5, 15.5))
        bezierPath.addLineToPoint(CGPointMake(219.5, 46.5))
    }
    
    func setupAnimationForPositionMarker(){
        let moveMarker = CAKeyframeAnimation(keyPath: "position")
        moveMarker.duration = 1.0
        moveMarker.path = self.bezierPath.CGPath
        moveMarker.removedOnCompletion = false
        moveMarker.speed = 0
        positionMarker.layer.addAnimation(moveMarker, forKey: "bezierMoving")
        
    }
    
    func animateWithOffset(offset: CFTimeInterval){
        let moveMarker = CAKeyframeAnimation(keyPath: "position")
        moveMarker.duration = 1.0
        moveMarker.path = self.bezierPath.CGPath
        moveMarker.removedOnCompletion = true
        moveMarker.speed = 0
        moveMarker.timeOffset = offset
        positionMarker.layer.addAnimation(moveMarker, forKey: "bezierMoving")
    }
    
    //MARK: Player Methods

    //MARK: Gesture Recognizer
    
    func handlePan(gestureRecognizer: UIPanGestureRecognizer){
        struct Static{
            static var referenceTime:Double = 0
            static var modifiedTime:Double = 0
        }
        var modifiedTime = Static.modifiedTime
        let referenceTime = Static.referenceTime
        let velocity = gestureRecognizer.translationInView(self.player.view);
        let currentTime = self.player.currentPlaybackTime
        let totalTime = self.player.duration
        NSLog("%f",velocity.y);
        switch gestureRecognizer.state{
        case UIGestureRecognizerState.Began:
            Static.referenceTime = currentTime
            self.overlayView.hidden = false
        case UIGestureRecognizerState.Ended:
            self.overlayView.hidden = true
            self.player.currentPlaybackTime = modifiedTime
        case UIGestureRecognizerState.Changed:
            Static.modifiedTime = referenceTime + Double(velocity.y)
            if Static.modifiedTime <= 0{
                Static.modifiedTime = 0
            }else if Static.modifiedTime >= totalTime{
                Static.modifiedTime = totalTime
            }
//            let currentOffset = self.collectionView.contentOffset
            let updatedOffset = CGPointMake(CGFloat(modifiedTime/totalTime)*self.collectionView.contentSize.width, 0)
            self.collectionView.contentOffset = updatedOffset
            modifiedTime = Static.modifiedTime
//            animateWithOffset(modifiedTime/totalTime)
//            NSLog("Time offset is \(modifiedTime/totalTime)")
//            self.timeLabel.text = "\(Utilities.getTimeStringForInterval(Static.modifiedTime)) / \(Utilities.getTimeStringForInterval(totalTime))"
        default: break
            
        }
        
    }
    
    func handleTap(gestureRecognizer: UITapGestureRecognizer){
        switch self.player.playbackState{
        case MPMoviePlaybackState.Playing:
            if self.overlayLabel != nil{
                self.overlayLabel.removeFromSuperview()
            }
//            showCardsOverlay()
            showBlurOverlay()
            self.player.pause()
        case MPMoviePlaybackState.Paused:
            self.blurOverlayView.hidden = true
            self.player.play()
        default: break
        }
    }
    
    func swipeLeft(gestureRecognizer: UISwipeGestureRecognizer){
        switch gestureRecognizer.direction{
        case UISwipeGestureRecognizerDirection.Left:
            showCardsOverlay()
        default:break
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:TourCollectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! TourCollectionCell
        let image = rooms[indexPath.row]["image"] as? UIImage
        cell.previewImage.image = image
        cell.previewImage.layer.masksToBounds = true
        cell.previewImage.layer.cornerRadius = 5
        cell.roomTitle.text = roomTitles[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width/3 - 10, collectionView.bounds.height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let timeToSeek:Double = self.rooms[indexPath.row]["time"] as! Double
        hideCardsOverlay()
        self.player.currentPlaybackTime = timeToSeek
        self.player.play()
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! TourCollectionCell
        animateLabelForCell(selectedCell)
    }
    
    //MARK: Carousel Methods
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let image = rooms[index]["imageFull"] as? UIImage
        if(view == nil){
           let newView = CarouselView(frame: CGRectMake(0, 0, carousel.frame.width, 120))
            newView.layer.masksToBounds = true
            newView.titleLabel.text = roomTitles[index]
            newView.imageView.image = image
            newView.layer.cornerRadius = 5
            return newView
        }else{
            let customView = view as! CarouselView
            customView.titleLabel.text = roomTitles[index]
            customView.imageView.image = image
            customView.layer.cornerRadius = 5
            return view
        }
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option{
        case iCarouselOption.Spacing:
            return 3
        default: return value
        }
    }
    
    func carouselItemWidth(carousel: iCarousel!) -> CGFloat {
        return 50
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
        return rooms.count
    }
    
    func carousel(carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        let timeToSeek:Double = self.rooms[index]["time"] as! Double
        hideBlurOverlay()
        self.player.currentPlaybackTime = timeToSeek
        self.player.play()
    }
    
    func carousel(carousel: iCarousel!, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let centerItemZoom:CGFloat = 1.5;
        let centerItemSpacing:CGFloat = 1.23;
        
        let spacing:CGFloat = self.carousel(carousel, valueForOption: iCarouselOption.Spacing, withDefault: 1)
        let absClampedOffset:CGFloat = min(1.0, fabs(offset));
        let clampedOffset:CGFloat = min(1.0, max(-1.0, offset));
        let scaleFactor = 1.0 + absClampedOffset * (1.0/centerItemZoom - 1.0);
        let modifiedOffset = (scaleFactor * offset + scaleFactor * (centerItemSpacing - 1.0) * clampedOffset) * carousel.itemWidth * spacing;
        var modifiedTransform:CATransform3D
        if (carousel.vertical)
        {
            modifiedTransform = CATransform3DTranslate(transform, 0.0, modifiedOffset, -absClampedOffset);
        }
        else
        {
            modifiedTransform = CATransform3DTranslate(transform, modifiedOffset, 0.0, -absClampedOffset);
        }
        
        modifiedTransform = CATransform3DScale(modifiedTransform, scaleFactor, scaleFactor, 1.0);
        return modifiedTransform;
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
        carousel.itemViewAtIndex(carouselPreviousSelectedIndex).layer.borderWidth = 0
        mapImageView.image = imagesArray[carousel.currentItemIndex] as! UIImage
        carousel.currentItemView.layer.borderColor = UIColor(red: 248/255, green: 231/255, blue: 28/255, alpha: 1).CGColor
        carousel.currentItemView.layer.borderWidth = 2
        carouselPreviousSelectedIndex = carousel.currentItemIndex
    }
    
    //MARK: View Specific Methods
    
    func getThumbnails() -> NSMutableArray{
        let path = NSBundle.mainBundle().pathForResource("Tour", ofType: "mp4"),
        url = NSURL.fileURLWithPath(path!);
        let asset:AVURLAsset = AVURLAsset(URL: url, options: nil)
        let imageGenerator:AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        let times:NSMutableArray = NSMutableArray()
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        for i in 0...9{
            let timeObject:NSMutableDictionary = NSMutableDictionary()
            let timeForImage = duration * Float64(i) * 0.1
            let cmTimeForImage = CMTimeMakeWithSeconds(timeForImage, 1)
            timeObject.setObject(timeForImage, forKey: "time")
            NSLog("Split times are \(CMTimeGetSeconds(cmTimeForImage))")
            let imageRef: CGImage!
//            do {
            imageRef = imageGenerator.copyCGImageAtTime(cmTimeForImage, actualTime: nil,error: nil)
//            } catch _ {
//                imageRef = nil
//            }
            let scale = UIScreen.mainScreen().scale
            let image = UIImage(CGImage: imageRef)
            timeObject.setObject(image!, forKey: "imageFull")
            let newSize = CGSizeMake(self.view.frame.width, self.view.frame.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image!.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            let resizeRect = CGRectMake(resizedImage.size.width/3 * scale , 0, resizedImage.size.width/3 * scale, resizedImage.size.height * scale)
            let croppedCGImage = CGImageCreateWithImageInRect(resizedImage.CGImage, resizeRect)
            let croppedImage = UIImage(CGImage: croppedCGImage)
            timeObject.setObject(croppedImage!, forKey: "image")
            times.addObject(timeObject)
        }
        return times
    }
    
    func addMaskView(){
        let firstView = UIView(frame: CGRectMake(0, 0, view.frame.width/3, overlayView.frame.height))
        firstView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        let secondView = UIView(frame: CGRectMake(view.frame.width/3, 0, view.frame.width/3, overlayView.frame.height))
        secondView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        let thirdView = UIView(frame: CGRectMake(view.frame.width*2/3, 0, view.frame.width/3, overlayView.frame.height))
        thirdView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        overlayView.addSubview(firstView)
        overlayView.addSubview(secondView)
        overlayView.addSubview(thirdView)
    }
    
    func showCardsOverlay(){
        if self.overlayLabel != nil{
            self.overlayLabel.removeFromSuperview()
        }
        self.overlayView.hidden = false
        let initialFrame = self.collectionView.frame
        let movedFrame = CGRectMake(initialFrame.width, initialFrame.origin.y, initialFrame.width, initialFrame.height)
        self.collectionView.frame = movedFrame
//        self.collectionView.transform = CGAffineTransformMakeScale(1.5, 1.5)
//        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.overlayView.alpha = 1
////            self.collectionView.transform = CGAffineTransformMakeScale(1.0, 1.0)
//            self.collectionView.frame = initialFrame
//            }) { (completed: Bool) -> Void in
//                if completed{
////                    self.overlayView.hidden = false
//                }
//        }
        
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.overlayView.alpha = 1
            self.collectionView.frame = initialFrame
            }) { (completed: Bool) -> Void in
                
        }
        
    }
    
    func hideOverlayWithCompletion(completion: (() -> Void)?){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.overlayView.alpha = 0
            }) { (completed: Bool) -> Void in
                if (completion != nil){
                    completion!()
                }
        }
    }
    
    func hideCardsOverlay(){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.overlayView.alpha = 0
            }) { (completed: Bool) -> Void in
                
        }
    }
    
    func showBlurOverlay(){
        self.blurOverlayView.alpha = 0
        self.blurOverlayView.hidden = false
        self.blurOverlayView.transform = CGAffineTransformMakeScale(1.5, 1.5)
        
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.blurOverlayView.alpha = 1
            self.blurOverlayView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }) { (completed: Bool) -> Void in
                
        }
    }
    
    func hideBlurOverlay(){
        self.player.play()
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
            self.blurOverlayView.alpha = 0
            self.blurOverlayView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            }) { (completed: Bool) -> Void in
                self.blurOverlayView.hidden = true
                self.blurOverlayView.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
    
    func animateLabelForCell(cell:TourCollectionCell){
        let initialFrame = cell.convertRect(cell.roomTitle.frame, toView: self.view)
        self.overlayLabel = UILabel(frame: initialFrame)
        self.overlayLabel.text = cell.roomTitle.text
        self.overlayLabel.font = cell.roomTitle.font
        self.overlayLabel.textColor = cell.roomTitle.textColor
        self.overlayLabel.textAlignment = cell.roomTitle.textAlignment
        self.view.addSubview(overlayLabel)
        cell.roomTitle.hidden = true
        let centerPoint = CGPointMake(self.view.bounds.width/2, 30)
//        UIView.animateWithDuration(0.5) { () -> Void in
//            self.overlayLabel.center = centerPoint
//        }
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                self.overlayLabel.center = centerPoint
            }) { (completed: Bool) -> Void in
                    cell.roomTitle.hidden = false
        }
    }
    
}

