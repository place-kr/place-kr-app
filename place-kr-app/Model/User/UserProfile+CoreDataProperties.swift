//
//  UserProfile+CoreDataProperties.swift
//  place-kr-app
//
//  Created by 이영빈 on 2022/01/20.
//
//

import Foundation
import CoreData
import SwiftUI


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var userId: String
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var nickName: String?
    @NSManaged public var gender: String?
    @NSManaged public var age: Int16
    @NSManaged public var dateCreated: Date
    @NSManaged public var dateModified: Date?
    
    static func create(userId: String,
                       name: String,
                       email: String,
                       nickName: String? = nil,
                       gender: String? = nil,
                       age: Int16 = 0,
                       using context: NSManagedObjectContext) {
        
        let userProfile = UserProfile(context: context)
        userProfile.userId = userId
        userProfile.name = name
        userProfile.email = email
        userProfile.nickName = nickName
        userProfile.dateCreated = Date()
        userProfile.gender = gender
        userProfile.age = age
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    static func fetchUserById(_ userID: String) -> FetchRequest<UserProfile> {
        let userIDPredicate = NSPredicate(format: "%K == %@", "userId", userID)
        return FetchRequest(entity: UserProfile.entity(), sortDescriptors: [], predicate: userIDPredicate)
    }
    
    static func clearAllForDebug(in context: NSManagedObjectContext) {
        context.reset()
    }
}

