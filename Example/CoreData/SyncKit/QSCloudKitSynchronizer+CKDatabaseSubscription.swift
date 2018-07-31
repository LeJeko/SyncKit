//
//  QSCloudKitSynchronizer+Subscriptions.swift
//  Pods
//
//  Created by Manuel Entrena on 21/05/2018.
//

import Foundation
import CloudKit
import SyncKit

@objc public extension QSCloudKitSynchronizer {
    
    #if os(iOS) || os(OSX)
    
    /**
     *  Creates a new subscription with CloudKit so the application can receive notifications when new changes happen. The application is responsible for registering for remote notifications and initiating synchronization when a notification is received. @see `CKSubscription`
     *
     *  -Paremeter zoneID   `CKRecordZoneID` to track for changes
     *  -Parameter completion Block that will be called after subscription is created, with an optional error.
     */
    
    @objc public func subscribeForDatabaseChanges(completion: ((Error?)->())?) {
        
        var subscriptionID = ""
        
        if database.databaseScope == CKDatabaseScope.private {
            subscriptionID = "private-changes"
        }
        if database.databaseScope == CKDatabaseScope.shared {
            subscriptionID = "shared-changes"
        }
        
        database.fetchAllSubscriptions { (subscriptions, error) in
            guard error == nil else {
                completion?(error)
                return
            }
            let existingSubscription = subscriptions?.first {
                let subscription = $0 as? CKDatabaseSubscription
                return subscription?.subscriptionID == subscriptionID
            }

            if (existingSubscription != nil) {
                // Found existing subscription
                print("Already subscribed to \(subscriptionID)")
                completion?(nil)
            } else {
                
                // Create new one
                let subscription = CKDatabaseSubscription(subscriptionID: subscriptionID)
                let notificationInfo = CKNotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                
                let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
                operation.qualityOfService = .utility
                
                operation.modifySubscriptionsCompletionBlock = { (subscriptions, deletedIds, error) in
                    if error == nil { print("subscription registered for \(subscriptionID)") }
                    // else custom error handling
                }
                self.database.add(operation)
               
            }
        }
    }
    
    /**
     *  Delete existing subscription to stop receiving notifications.
     *
     *  -Parameter zoneID `CKRecordZoneID` to stop tracking for changes.
     *  -Parameter completion Block that will be called after subscription is deleted, with an optional error.
     */
    
//    @objc public func cancelSubscriptionForChanges(in zoneID: CKRecordZoneID, completion: ((Error?)->())?) {
//
//        if let subscriptionID = subscriptionID(forRecordZoneID: zoneID) {
//
//            self.cancelSubscription(identifier: subscriptionID, completion: completion)
//        } else {
//            // There might be an existing subscription in the server
//            database.fetchAllSubscriptions { (subscriptions, error) in
//                guard error == nil else {
//                    completion?(error)
//                    return
//                }
//
//                let existingSubscriptionIdentifier = subscriptions?.first {
//                    let subscription = $0 as? CKRecordZoneSubscription
//                    return subscription?.zoneID == zoneID
//                }
//
//                if let subscriptionID = existingSubscriptionIdentifier?.subscriptionID {
//
//                    self.cancelSubscription(identifier: subscriptionID, completion: completion)
//                } else {
//                    // No subscription to cancel
//                    completion?(nil)
//                }
//            }
//        }
//    }
//
//    fileprivate func cancelSubscription(identifier: String, completion: ((Error?)->())?) {
//
//        database.delete(withSubscriptionID: identifier) { (subscriptionID, error) in
//            self.clearSubscriptionID(subscriptionID)
//            completion?(error)
//        }
//    }
    
    #endif
}

