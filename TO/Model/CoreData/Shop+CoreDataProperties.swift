//
//  Shop+CoreDataProperties.swift
//  TO
//
//  Created by Константин Козлов on 28.03.2022.
//
//

import Foundation
import CoreData


extension Shop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Shop> {
        return NSFetchRequest<Shop>(entityName: "Shop")
    }

    @NSManaged public var name: String?
    @NSManaged public var photo: NSSet?

}

// MARK: Generated accessors for photo
extension Shop {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Photo)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Photo)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}

extension Shop : Identifiable {

}
