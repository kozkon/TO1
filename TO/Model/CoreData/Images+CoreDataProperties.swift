//
//  Images+CoreDataProperties.swift
//  TO
//
//  Created by Константин Козлов on 28.03.2022.
//
//

import Foundation
import CoreData


extension Images {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Images> {
        return NSFetchRequest<Images>(entityName: "Images")
    }

    @NSManaged public var image: Data?
    @NSManaged public var photo: Photo?

}

extension Images : Identifiable {

}
