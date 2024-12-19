//
//  History+CoreDataProperties.swift
//  Mann_Ambani_FE_8860123
//
//  Created by user230729 on 12/9/23.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var dateTime: Date?
    @NSManaged public var desc: String?
    @NSManaged public var historyId: UUID?
    @NSManaged public var interaction: String?
    @NSManaged public var result: String?
    @NSManaged public var source: String?
    @NSManaged public var title: String?
    @NSManaged public var transportType: String?
    @NSManaged public var cityName: String?

}

extension History : Identifiable {

}
