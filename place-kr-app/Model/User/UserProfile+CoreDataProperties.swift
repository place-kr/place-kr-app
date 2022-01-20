//
//  UserProfile+CoreDataProperties.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/20.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var userId: String
    @NSManaged public var nickName: String?
    @NSManaged public var gender: String?
    @NSManaged public var age: Int16
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date?
    @NSManaged public var name: String
    @NSManaged public var email: String?

}

extension UserProfile : Identifiable {

}
