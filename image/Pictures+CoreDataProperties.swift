//
//  Pictures+CoreDataProperties.swift
//  image
//
//  Created by YinHao on 16/6/28.
//  Copyright © 2016年 Suzhou Qier Network Technology Co., Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pictures {

    @NSManaged var image: NSData?
    @NSManaged var vhash: String?
    @NSManaged var own: NSSet?

}
