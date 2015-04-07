//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Anthony Armstrong on 3/19/15.
//  Copyright (c) 2015 openinformant. All rights reserved.
//

import UIKit
import CoreImage

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    var collectionView:UICollectionView!
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []

    let kIntensity = 0.7
    let placeholderImage = UIImage(named: "Placeholder.png")
    let tmp = NSTemporaryDirectory()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Create a Collection View in code
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "myCell")

        self.filters = photoFilters()
        //println("Filter count: \(filters.count)")
        //println(tmp)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - CollectionView dataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as FilterCell


        cell.imageView.image = placeholderImage

        // Grand Central Dispatch
        let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        
        return cell
    }


    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        createUIAlertController()


//        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, withFilterName: self.filters[indexPath.row])
//        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
//        self.thisFeedItem.image = imageData
//
//        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.5)
//        self.thisFeedItem.thumbNail = thumbnailData
//
//        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        appDelegate.saveContext()
//
//        self.navigationController?.popViewControllerAnimated(true)
    }


    //MARK: - Helper Function
    func photoFilters () -> [CIFilter] {

        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)

        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)

        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")

        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)

        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)

        //return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]

        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    func filteredImageFromImage(imageData:NSData, withFilterName filter:CIFilter) -> UIImage {
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)

        let filteredImage:CIImage = filter.outputImage
        let extent = filteredImage.extent()

        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        let finalImage = UIImage(CGImage: cgImage)

        //let finalImage = UIImage(CIImage: filteredImage)

        return finalImage!

    }

    // Create a UIAlertControllers
    func createUIAlertController() -> (){
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add caption"
            textField.secureTextEntry = false
        }

        self.presentViewController(alert, animated: true, completion: nil)
    }

    func createSimpleUIAlertController() -> (){
        let newAlert = UIAlertController(title: "Test", message: "New Alert", preferredStyle: .Alert)
        let go = UIAlertAction(title: "Tap Me", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        newAlert.addAction(go)
        newAlert.addAction(cancel)

        self.presentViewController(newAlert, animated: true, completion: nil)

    }

    //MARK: - Caching functions
    func cacheImage(imageNumner:Int) -> (){
        let fileName = "\(imageNumner)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)

        if !NSFileManager.defaultManager().fileExistsAtPath(fileName){
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumner]
            let image = filteredImageFromImage(data, withFilterName: filter)

            UIImageJPEGRepresentation(image, 0.5).writeToFile(uniquePath, atomically: true)
        }
    }

    func getCachedImage(imageNumber:Int) -> UIImage{
        let filename = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(filename)
        var image:UIImage
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath){
            image = UIImage(contentsOfFile: uniquePath)!
        }  else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }

        return image
    }
}
