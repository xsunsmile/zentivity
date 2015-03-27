//
//  FlatEeventTableViewCell.swift
//  zentivity
//
//  Created by Hao Sun on 3/25/15.
//  Copyright (c) 2015 Zendesk. All rights reserved.
//

import UIKit

class FlatEeventTableViewCell: BaseTableViewCell,
                               UICollectionViewDataSource,
                               UICollectionViewDelegate
{
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventImages: UICollectionView!

    var eventImagesStore = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initSubViews()
        refresh()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func onDataSet(data: AnyObject!) {
//        refresh()
    }
    
    override func refresh() {
        if data == nil {
            println("data is null skip refresh")
            return
        }
        
        let event = data as Event
        
        if event.getTitle().length > 0 {
            eventNameLabel.text = event.getTitle()
        } else {
            eventNameLabel.text = "No Title yet"
        }
        
        eventDateLabel.text = event.startTimeWithFormat("MMM d, HH:mm (EEE)")
        
        println("event has # of photos: \(event.photos?.count)")
        if event.photos?.count > 0 {
            var thumbnail = event.thumbnail
            thumbnail.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil {
//                    self.eventBackgroundImageView.image = UIImage(data: data)
                    self.eventImagesStore.addObject(UIImage(data: data)!)
                    self.eventImages.reloadData()
                } else {
//                    self.eventBackgroundImageView.image = UIImage(named: "noActivity")
                    println("Can not get image for event \(event.getTitle())")
                }
            })
        } else {
            println("there is no photos for event \(event.getTitle())")
            eventImages.removeFromSuperview()
        }
        
        if !event.descript.isEmpty {
            descriptionLabel.text = event.descript
        }
    }
    
    override func layoutSubviews() {
        correctLabelWidth()
    }
    
    func correctLabelWidth() {
        eventNameLabel.preferredMaxLayoutWidth = eventNameLabel.frame.width
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.frame.width
    }
    
    func initSubViews() {
        correctLabelWidth()
        eventImages.delegate = self
        eventImages.dataSource = self
        eventImages.registerNib(UINib(nibName: "EventImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EventImageCollectionViewCell")
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = eventImages.dequeueReusableCellWithReuseIdentifier("EventImageCollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        let data = eventImagesStore[indexPath.row] as? UIImage
        let imageView = UIImageView(frame: cell.bounds)
        imageView.image = data!
        
        println("adding image for event #\(indexPath.row)")
        cell.addSubview(imageView)
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventImagesStore.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = UIScreen.mainScreen().bounds.size
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)){
            return CGSizeMake(size.width, size.height)
        } else {
            return CGSizeMake(size.height, size.width)
        }
    }
}
