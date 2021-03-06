//
//  EventDetailViewController.swift
//  zentivity
//
//  Created by Andrew Wen on 3/10/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegate,
                                 UIScrollViewDelegate,
                                 UIGestureRecognizerDelegate,
                                 MKMapViewDelegate
{
    
    var event: ZenEvent!

    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var eventHeaderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var usersGridView: UICollectionView!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var joinButtonView: UIView!
    
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleTopConstraint: NSLayoutConstraint!
    
    var contentViewOriginFrame: CGRect!
    var detailHeaderViewOriginFrame: CGRect!
    var dragStartingPoint: CGPoint!
    var detailsIsOpen = false
    var currentImageView: UIImageView?
    var eventImages: [UIImage]?
    var addressPlaceHolder = "1019 Market Street, San Francisco, CA"
    var didInitialAnimation = false
    var initialDragOffset = CGFloat(0)
    var initialImageDragOffset = CGFloat(0)
    var gestureWasHandled = false
    var pointCount = 0
    var startPoint: CGPoint!
    var modalPanGuesture: UIPanGestureRecognizer?
    var modalPanGuesture2: UIPanGestureRecognizer?
    var headerUpToPosition = CGFloat(200)
    var eventPlaceMark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSubviews()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        animateHeaderViewDown(0.5)
        
        if contentView.frame.height < view.frame.height {
            contentView.frame.size.height = view.frame.height
        }
        
        view.setNeedsDisplay()
    }
    
    func initSubviews() {
        eventImages = []
        imageScrollView.contentSize = CGSizeMake(view.frame.size.width*3, view.frame.size.height)
        imageScrollView.scrollsToTop = false
        
        usersGridView.delegate = self
        usersGridView.dataSource = self
       
        let gradient = CAGradientLayer()
        let arrayColors = [
            UIColor(rgba: "#211F20").CGColor,
            UIColor.clearColor().CGColor
        ]
        
        imageShadowView.backgroundColor = UIColor.clearColor()
        gradient.frame = imageShadowView.bounds
        gradient.frame.size.width = view.frame.width
        gradient.colors = arrayColors
        imageShadowView.layer.insertSublayer(gradient, atIndex: 0)
        
        imageScrollView.delegate = self
        if modalPanGuesture != nil {
            imageScrollView.addGestureRecognizer(modalPanGuesture!)
            imageShadowView.addGestureRecognizer(modalPanGuesture2!)
        }
        
        imagePageControl.hidden = true
        imagePageControl.currentPage = 0
        
        mapView.delegate = self
        
        initMapView()
    }
    
    func refresh() {
        if event == nil {
            return
        }
        
        setupBackgroundImageView()
        titleLabel.text = event.getTitle() as String
        
        if !event.locationString.isEmpty {
            addressLabel.text = event.locationString
        } else {
            addressLabel.text = addressPlaceHolder
        }

        var name = "Hao Sun"
        var number = "(408) 673-4419"

        phoneLabel.text = "\(name): \(number)"

        var dateString = NSMutableAttributedString(
            string: event.startTimeWithFormat("EEEE") as String,
            attributes: NSDictionary(
                object: UIFont.boldSystemFontOfSize(17.0),
                forKey: NSFontAttributeName) as [NSObject : AnyObject])
        
       dateString.appendAttributedString(NSAttributedString(
            string: "\n" + (event.startTimeWithFormat("MMM d, yyyy") as String),
            attributes: NSDictionary(
                object: UIFont(name: "Arial", size: 17.0)!,
                forKey: NSFontAttributeName) as [NSObject : AnyObject]))
        
        eventDateLabel.attributedText = dateString
        
        if GoogleClient.sharedInstance.alreadyLogin() {
            let currentUser = User.currentUser()
            if currentUser != nil {
                joinButton.backgroundColor = joinButtonColor()
                joinButton.setTitle(joinButtonText() as String, forState: .Normal)
            }
        } else {
            joinButton.setTitle("SignIn", forState: .Normal)
        }
        
        if !event.descript.isEmpty {
            eventDescription.text = event.descript
            eventDescription.preferredMaxLayoutWidth = view.frame.width - 40
//            eventDescription.frame = 
            println("label frame \(eventDescription.frame)")
        }
    }
    
    func setupBackgroundImageView() {
        if eventImages?.count == event.photos.count {
            return
        }
       
        eventImages?.removeAll(keepCapacity: true)
        if event.photos.count > 0 {
            for subview in imageScrollView.subviews {
                subview.removeFromSuperview()
            }
 
            for photo in event.photos {
                let photo = photo as! Photo
                photo.fetchIfNeededInBackgroundWithBlock { (photo, error) -> Void in
                    let p = photo as! Photo
                    p.file.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                        if imageData != nil {
                            println("Got a new photo")
                            let image = UIImage(data:imageData!)
                            self.eventImages?.append(image!)
                            self.addBackgroundImage(image!)
                        } else {
                            println("Failed to download image data")
                        }
                    })
                }
            }
        }
    }
    
    func initMapView() {
//        let location = CLLocation(latitude: 37.782193, longitude: -122.410254)
        // LocationUtils.sharedInstance.getPlacemarkFromLocationWithCompletion(location, completion: { (places, error) -> () in
        //     if error == nil {
        //         let pm = places as [CLPlacemark]
        //         if pm.count > 0 {
        //             println("got list of places: \(pm)")
        //         }
        //     } else {
        //         println("Failed to get places: \(error)")
        //     }
        // })
        var address = addressPlaceHolder
        if !event.locationString.isEmpty {
            address = event.locationString
        }
        
        println("event location is \(address)")
        LocationUtils.sharedInstance.getGeocodeFromAddress(address, completion: { (places, error) -> () in
            if error == nil {
                let places = places as! [CLPlacemark]
                self.eventPlaceMark = places.last
                
                let miles = 0.09;
                let center = CLLocationCoordinate2D(latitude: self.eventPlaceMark!.location.coordinate.latitude, longitude: self.eventPlaceMark!.location.coordinate.longitude)
                var region = MKCoordinateRegionMakeWithDistance(center, 1609.344 * miles, 1609.344 * miles)
                self.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
//                annotation.setCoordinate(center)
                let title = self.event.getTitle() as String
                annotation.title = title.truncate(25, trailing: "...")
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
            } else {
                println("Failed to get places for address \(error)")
            }
        })
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        println("get annotaion: \(annotation)")
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        
        pinAnnotationView.pinColor = .Purple
        pinAnnotationView.draggable = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        
        let driveButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        driveButton.frame.size.width = 45
        driveButton.frame.size.height = 45
        driveButton.backgroundColor = UIColor.whiteColor()
        let buttonImage = UIImage(named: "zentivity-logo-icon")
        driveButton.setImage(buttonImage, forState: .Normal)
        driveButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        
        pinAnnotationView.leftCalloutAccessoryView = driveButton
        
        return pinAnnotationView
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let currentLocation = MKMapItem.mapItemForCurrentLocation()
            let place = MKPlacemark(placemark: self.eventPlaceMark)
            let destination = MKMapItem(placemark: place)
            destination.name = self.event.getTitle() as String
            let items = NSArray(objects: currentLocation, destination)
            let options = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey)
            MKMapItem.openMapsWithItems(items as [AnyObject], launchOptions: options as [NSObject : AnyObject])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func presentAuthModal() {
        let appVC = storyboard?.instantiateViewControllerWithIdentifier("AppViewController") as! AppViewController
        self.presentViewController(appVC, animated: true, completion: nil)
    }
    
    @IBAction func onJoin(sender: AnyObject) {
        if !GoogleClient.sharedInstance.alreadyLogin() || User.currentUser() == nil {
            presentAuthModal()
            return
        }
        
        if joinButton.titleLabel!.text == "Cancel" {
            joinButton.setTitle("Join", forState: .Normal)
        } else {
            joinButton.setTitle("Cancel", forState: .Normal)
        }
        
//        User.currentUser()!.toggleJoinEventWithCompletion(event, completion: { (success, error, state) -> () in
//            self.joinButton.backgroundColor = self.joinButtonColor()
//            self.joinButton.setTitle(self.joinButtonText() as String, forState: .Normal)
//            self.joinButton.setTitleColor(self.joinButtonTextColor(), forState: .Normal)
//            if self.detailsIsOpen {
//                self.setHeaderNewColor(self.joinButtonTextColor())
//            }
//            
//            if state == kUserJoinEvent {
//                if success != nil {
////                    UIAlertView(
////                        title: "Great!",
////                        message: "See you at the event :)",
////                        delegate: self,
////                        cancelButtonTitle: "OK"
////                        ).show()
//                } else {
////                    UIAlertView(
////                        title: "Error",
////                        message: "Unable to join event.",
////                        delegate: self,
////                        cancelButtonTitle: "Well damn..."
////                        ).show()
//                }
//            } else {
//            }
//            self.reloadData()
//        })
    }
    
    func joinButtonText() -> NSString {
        if event.userJoined(User.currentUser()) {
            return "Cancel"
        } else {
            return "Join"
        }
    }
    
    func joinButtonColor() -> UIColor {
        if detailsIsOpen {
            return UIColor.whiteColor()
        } else {
            if event.userJoined(User.currentUser()) {
                return UIColor(rgba: "#3366cc")
            } else {
                return UIColor(rgba: "#dd4b39")
            }
        }
    }
    
    func joinButtonTextColor() -> UIColor {
        if !detailsIsOpen {
            return UIColor.whiteColor()
        } else {
            if event.userJoined(User.currentUser()) {
                return UIColor(rgba: "#3366cc")
            } else {
                return UIColor(rgba: "#dd4b39")
            }
        }
    }
    
    func reloadData() {
        usersGridView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if event == nil {
            return 0
        }
        return event.confirmedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserGridViewCell", forIndexPath: indexPath) as! UserIconCollectionViewCell
        cell.user = event.confirmedUsers[indexPath.row] as? User
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if(kind == UICollectionElementKindSectionHeader) {
            let cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "eventUserTypes", forIndexPath: indexPath) as! LabelCollectionReusableView
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
    
    @IBAction func onQuit(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDetailViewDrag(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocityInView(view)
        let point = sender.translationInView(view)
        let loc = sender.locationInView(view)
        
        var direction = "up"
        detailsIsOpen = true
        if velocity.y > 0 {
            direction = "down"
            detailsIsOpen = false
        }
        
        if sender.state == .Began {
            println("staring dragging detail view")
            animateHeaderColorChanges(direction)
            dragStartingPoint = CGPoint(x: loc.x, y: loc.y)
            initialDragOffset = contentView.frame.origin.y
            if currentImageView != nil {
                initialImageDragOffset = currentImageView!.frame.origin.y
                println("set image y: \(initialImageDragOffset)")
            }
        } else if sender.state == .Changed {
            let dy = loc.y - dragStartingPoint.y
            let newYPos = initialDragOffset + dy
            if newYPos >= 200 {
                headerUpToPosition = CGFloat(200)
                contentView.frame.origin.y = newYPos
                let newImageYPos = initialImageDragOffset + dy/2
                if currentImageView != nil {
                    if newImageYPos > 0 {
                        println("Can not drag image down when y is 0")
                    } else {
                        currentImageView?.frame.origin.y = newImageYPos
                    }
                } else {
//                    println("current image view is empty during dragging")
                }
            } else {
                headerUpToPosition = CGFloat(0)
                if contentView.frame.height <= view.frame.height {
                    contentView.frame.size.height = view.frame.height
                    
                    if newYPos > 0 {
                        contentView.frame.origin.y = newYPos
                        joinButtonView.transform = CGAffineTransformMakeScale(newYPos/200, newYPos/200)
                    }
                } else {
                    contentView.frame.origin.y = newYPos
                    if newYPos > 0 {
                        joinButtonView.transform = CGAffineTransformMakeScale(newYPos/200, newYPos/200)
                    }
                }
            }
        } else if sender.state == .Ended {
            if direction == "up" {
                animateHeaderViewUp()
            } else {
                animateHeaderViewDown(0)
            }
        }
    }
    
    func animateHeaderViewDown(delay: Double!) {
        view.layoutIfNeeded()
        let dy = self.view.frame.height - self.eventHeaderView.frame.height
        contentTopConstraint.constant = dy
        headerTitleTopConstraint.constant = 8
        eventHeaderView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: nil, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            if self.currentImageView != nil {
                self.currentImageView?.frame.origin.y = 0
            }
            
            self.joinButtonView.transform = CGAffineTransformIdentity
            }) { (completed) -> Void in
                if completed {
                    self.detailsIsOpen = false
                }
        }
    }
    
    func animateHeaderViewUp() {
        view.layoutIfNeeded()
        let dy = self.view.frame.height - self.contentView.frame.height
        contentTopConstraint.constant = headerUpToPosition
        if headerUpToPosition == 0 {
            headerTitleTopConstraint.constant = 16
        }
        eventHeaderView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: nil, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            if self.headerUpToPosition == 0 {
                self.contentView.frame.size.height = self.view.frame.height
                self.joinButtonView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
            }
            
            if self.currentImageView != nil {
                self.currentImageView?.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height/3)
            } else {
                println("current image view is empty")
            }
            }) { (completed) -> Void in
                if completed {
                    self.detailsIsOpen = true
                }
                self.headerUpToPosition = CGFloat(200)
        }
    }
    
    func animateHeaderColorChanges(direction: NSString) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            if direction == "up" {
                self.joinButton.backgroundColor = UIColor.whiteColor()
                self.joinButton.setTitleColor(self.joinButtonTextColor(), forState: .Normal)
                
                self.setHeaderNewColor(self.joinButtonTextColor())
            } else {
                self.joinButton.backgroundColor = self.joinButtonColor()
                self.joinButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                
                self.setHeaderOriginColor()
            }
        })
    }
    
    func setHeaderOriginColor() {
        self.eventHeaderView.backgroundColor = UIColor.whiteColor()
        
        self.titleLabel.textColor = UIColor.blackColor()
        self.addressLabel.textColor = UIColor(rgba: "#7f7f7f")
        self.phoneLabel.textColor = UIColor(rgba: "#7f7f7f")
    }
    
    func setHeaderNewColor(color: UIColor!) {
        self.eventHeaderView.backgroundColor = color
        
        self.titleLabel.textColor = UIColor.whiteColor()
        self.addressLabel.textColor = UIColor.whiteColor()
        self.phoneLabel.textColor = UIColor.whiteColor()
    }
    
    func addBackgroundImage(image: UIImage!) {
        let numImages = eventImages!.count
        imagePageControl.hidden = false
        imagePageControl.numberOfPages = numImages
        
        let imageWidth = view.frame.size.width
        let imageHeight = view.frame.size.height
        
        let xPosition = imageWidth * CGFloat(numImages - 1)
        let mainFrame = CGRectMake(xPosition, 0, imageWidth, imageHeight)
        
        let imageView = UIImageView(frame: mainFrame)
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
//        imageView.userInteractionEnabled = true
        
        imageScrollView.addSubview(imageView)
        imageScrollView.contentSize = CGSizeMake(imageWidth * CGFloat(numImages), imageHeight)
        
        if currentImageView == nil {
            currentImageView = imageView
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        println("image view did end dragging")
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        println("image roll will begin dragging")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageSize: Float = Float(view.bounds.size.width)
        var page: Float = floorf((Float(scrollView.contentOffset.x) - pageSize / 2.0) / pageSize) + 1
        let numPages = eventImages?.count
        
        if (page >= Float(numPages!)) {
            page = Float(numPages!) - 1
        } else if (page < 0) {
            page = 0
        }
        
        imagePageControl.currentPage = Int(page)
        println("current page is: \(Int(page))")
        if Int(page) >= 0 && imageScrollView.subviews.count > Int(page) {
            currentImageView = imageScrollView.subviews[Int(page)] as? UIImageView
            println("current image view: \(currentImageView)")
        }
    }
    
    @IBAction func onHeaderTap(sender: UITapGestureRecognizer) {
        println("did tap detail view")
        let direction = detailsIsOpen ? "down" : "up"
        if detailsIsOpen {
            println("Hide detail view")
            detailsIsOpen = false
            animateHeaderColorChanges(direction)
            animateHeaderViewDown(0)
        } else {
            println("Show detail view")
            detailsIsOpen = true
            animateHeaderColorChanges(direction)
            animateHeaderViewUp()
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func onCall(sender: UIButton) {
        println("There is no number to call")
        return
        
//        let contactNumber = event.contactNumber
//        if contactNumber == nil {
//            println("There is no number to call")
//            return
//        }
//        
//        let regex = NSRegularExpression(pattern: "\\(|\\)|-", options: nil, error: nil)
//        let number = regex?.stringByReplacingMatchesInString(contactNumber!, options: nil, range: NSMakeRange(0, count(contactNumber!)), withTemplate: "$1")
//        println("calling number \(number)")
//        let phoneNumber = "tel://".stringByAppendingString(number!)
//        UIApplication.sharedApplication().openURL(NSURL(string: phoneNumber)!)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
