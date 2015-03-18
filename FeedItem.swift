//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Anthony Armstrong on 3/17/15.
//  Copyright (c) 2015 openinformant. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
