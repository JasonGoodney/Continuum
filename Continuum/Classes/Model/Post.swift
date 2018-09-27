//
//  Post.swift
//  Continuum
//
//  Created by Jason Goodney on 9/26/18.
//  Copyright © 2018 Jason Goodney. All rights reserved.
//

import UIKit
import CloudKit

struct PostKey {
    static let RecordType = "Post"
    
    static let Timestamp = "timestamp"
    static let Caption = "caption"
    static let PhotoAsset = "photoAsset"
}

class Post {
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment] {
        didSet {
            DispatchQueue.main.async {            
                NotificationCenter.default.post(name: PostController.shared.PostCommentsChangedNotification, object: self)
            }
        }
    }
    var ckRecordId: CKRecord.ID
    var tempUrl: URL?
    
    var photo: UIImage? {
        get {
            guard let photoData = photoData else { return nil }
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    var photoAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryUrl = URL(fileURLWithPath: tempDirectory)
            let fileUrl = tempDirectoryUrl.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            self.tempUrl = fileUrl
            do {
                try photoData?.write(to: fileUrl)
            } catch let error {
                print("🎅🏻\nerror writing to file url \(#function): \(error)\n\n\(error.localizedDescription)\n🎄")
            }
            
            return CKAsset(fileURL: fileUrl)
        }
    }
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = [],
         ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.ckRecordId = ckRecordId
        self.photo = photo
        
    }
    
    init?(record: CKRecord) {
        guard let caption = record[PostKey.Caption] as? String,
            let timestamp = record[PostKey.Timestamp] as? Date,
            let photoAsset = record[PostKey.PhotoAsset] as? CKAsset else { return nil }
        
        guard let photoData = try? Data(contentsOf: photoAsset.fileURL) else { return nil }
        
        self.caption = caption
        self.timestamp = timestamp
        self.photoData = photoData
        self.comments = []
        self.ckRecordId = record.recordID
        
    }
    
    deinit {
        if let url = tempUrl {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                print("Error deleting temp file, or may cause memory leak: \(error)")
            }
        }
    }
}

extension CKRecord {
    convenience init(post: Post) {
        let recordId = post.ckRecordId
        self.init(recordType: PostKey.RecordType, recordID: recordId)
        
        self.setValue(post.caption, forKey: PostKey.Caption)
        self.setValue(post.timestamp, forKey: PostKey.Timestamp)
        self.setValue(post.photoAsset, forKey: PostKey.PhotoAsset)
            
    }
}

extension Post: SearchableRecord {
    func matches(_ searchTerm: String) -> Bool {
        return comments.contains(where: { $0.matches(searchTerm.lowercased()) })
//        return caption.lowercased().contains(searchTerm.lowercased())
    }
}
