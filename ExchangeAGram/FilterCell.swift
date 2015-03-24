//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Anthony Armstrong on 3/21/15.
//  Copyright (c) 2015 openinformant. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    var imageView:UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)   // The main view to which I'm adding this cell’s custom content.
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
