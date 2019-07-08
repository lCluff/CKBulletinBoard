//
//  PostController.swift
//  CKBulletinBoard27
//
//  Created by Leah Cluff on 7/8/19.
//  Copyright © 2019 Leah Cluff. All rights reserved.
//

import Foundation
import CloudKit

class MessageController {
    
    static let sharedInstance = MessageController()
    
    var messages: [Message] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func saveMessage(message: Message, completion: @escaping (Bool) -> ()) {
        let messageRecord = CKRecord(message: message)
        privateDB.save(messageRecord) { (record, error) in
            if let error = error {
                print("Oh H*CK, there was an error in \(#function) ; \(error) ; \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let record = record, let message = Message(ckRecord: record) else {completion(false); return}
            self.messages.append(message)
            completion(true)
        }
    }
    
    func removeMessage(message: Message, completion: @escaping(Bool) -> ()) {
        
        // Removing Locally
        guard let index = MessageController.sharedInstance.messages.firstIndex(of: message) else {return}
        MessageController.sharedInstance.messages.remove(at: index)
        
        // Removing from the Cloud
        privateDB.delete(withRecordID: message.ckRecordId) { (_, error) in
            if let error  = error {
                print("There was an error deleting \(#function) ; \(error) ; \(error.localizedDescription)")
                completion(false)
                return
            } else {
                print("By George it worked! It's been deleted!")
                completion(true)
            }
        }
    }
    
    func fetchMessage(completion: @escaping(Bool) -> ()){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let records = records else {completion(false); return}
            let messages = records.compactMap({Message(ckRecord: $0)})
            self.messages = messages
            completion(true)
        }
    }
}


