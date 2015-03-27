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
    let kIntensity = 0.7


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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - CollectionView dataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as FilterCell
        
        cell.imageView.image = UIImage(named: "Placeholder.png")

        return cell
    }


    //MARK: - Helper Function
    //UICollectionViewDataSource
    func photoFilters() ->[CIFilter]{
        var ciFilters:[CIFilter] = []

        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        let colorControls = CIFilter(name: "CIColorControls")
        let sepia = CIFilter(name:"CISepiaTone")
        let colorClamp = CIFilter(name: "CIColorClamp")

        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2), forKey: "inputMinComponents")

        let composite = CIFilter(name:"CIHardBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)

        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity*2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity*30, forKey: kCIInputRadiusKey)

        ciFilters = [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]

        return ciFilters
    }
}
