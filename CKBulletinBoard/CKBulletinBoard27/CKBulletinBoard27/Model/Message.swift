//
//  Post.swift
//  CKBulletinBoard27
//
//  Created by Leah Cluff on 7/8/19.
//  Copyright © 2019 Leah Cluff. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
    static let recordKey = "Message"
    static let textKey = "text"
    static let timestampKey = "timestamp"
}

class Message {
    var text: String
    var timestamp: Date
    var ckRecordId: CKRecord.ID
    
    init(text: String, timestamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.text = text
        self.timestamp = timestamp
        self.ckRecordId = ckRecordID
    }
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[Constants.textKey] as? String, let timestamp = ckRecord[Constants.timestampKey] as? Date else {return nil}
        self.init(text: text, timestamp: timestamp, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(message: Message) {
        self.init(recordType: Constants.recordKey, recordID: message.ckRecordId)
        self.setValue(message.text, forKey: Constants.textKey)
        self.setValue(message.timestamp, forKey: Constants.timestampKey)
    }
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.text == rhs.text && lhs.timestamp == rhs.timestamp
    }
}


