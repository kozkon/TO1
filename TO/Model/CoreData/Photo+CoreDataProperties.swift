//
//  Photo+CoreDataProperties.swift
//  TO
//
//  Created by Константин Козлов on 28.03.2022.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var descriptions: String?
    @NSManaged public var kit: String?
    @NSManaged public var nameForReport: String?
    @NSManaged public var object: String?
    @NSManaged public var images: NSSet?
    @NSManaged public var shop: Shop?

}

// MARK: Generated accessors for images
extension Photo {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Images)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Images)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension Photo : Identifiable {

}
