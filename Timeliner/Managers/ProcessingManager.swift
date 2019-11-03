//
//  ProcessingManager.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Cocoa
import RealmSwift
import AVFoundation

class ProcessingManager {
    
    var lastScreenshot: NSImage?
    var lastScreenshotURL = URL(fileURLWithPath: "last.png")
    
    init() {
        lastScreenshot = NSImage(contentsOf: lastScreenshotURL)
    }
    
    func process() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "processed == false")
        let unprocessedRecords = realm.objects(ScreenRecord.self).filter(predicate)
        unprocessedRecords.forEach { screenRecord in
            let dateFormatter = SecondDateFormatter()
            let dateString = dateFormatter.string(from: screenRecord.created)
            let url = URL(fileURLWithPath: "\(dateString).mp4")
            let asset = AVURLAsset(url: url, options: [:])
            
            let videoDuration: CMTime = asset.duration
//            let durationInSeconds: Float64 = CMTimeGetSeconds(videoDuration)

            let numerator = Int64(1)
            let denominator = videoDuration.timescale
            let time = CMTimeMake(value: numerator, timescale: denominator)
            
            if let newScreenshot = thumbnailImage(for: asset, at: time) {
                if lastScreenshot == nil {
                    newScreenshot.pngWrite(to: lastScreenshotURL)
                    lastScreenshot = newScreenshot
                }
                if let lastScreenshot = lastScreenshot {
                    let comparisonResult = compareImages(image1: lastScreenshot.cgImage!, image2: newScreenshot.cgImage!)
                    print("🔴 Comparison Result: \(comparisonResult)")
                }
            }

//            let thumbURL = URL(fileURLWithPath: "scrn.png")
//            thumb?.pngWrite(to: thumbURL)
        }
    }
    
    func thumbnailImage(for asset: AVURLAsset, at time: CMTime) -> NSImage? {

        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = NSImage(cgImage: img, size: NSSize(width: img.width, height: img.height))
            return thumbnail
        } catch {
            print(error)
            return nil
        }
    }
}
