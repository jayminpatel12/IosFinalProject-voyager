//
//  Media+CoreDataProperties.swift
//  MAD4114Project
//
//  Created by Edgar on 19/9/22.
//
//

import Foundation
import CoreData


extension Media {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Media> {
        return NSFetchRequest<Media>(entityName: "Media")
    }

    @NSManaged public var type: Int16
    @NSManaged public var url: String?
    @NSManaged public var ofSite: Site?

}

extension Media : Identifiable {

}
