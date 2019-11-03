//
//  NSImage+Extensions.swift
//  Timeliner
//
//  Created by Igor Leonovich on 11/3/19.
//

import Cocoa
import CoreImage

extension NSImage {
    
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    
    @discardableResult
    func pngWrite(to url: URL) -> Bool {
        do {
            try pngData?.write(to: url)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    @objc var cgImage: CGImage? {
        get {
            guard let imageData = self.tiffRepresentation else { return nil }
            guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
            return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
       }
    }
    
    func compareWithImage(_ referenceImage: NSImage, tolerance: CGFloat = 0) -> Bool {
        guard size.equalTo(referenceImage.size) else {
            return false
        }
        guard let cgImage = cgImage, let referenceCGImage = referenceImage.cgImage else {
            return false
        }
        let minBytesPerRow = min(cgImage.bytesPerRow, referenceCGImage.bytesPerRow)
        let referenceImageSizeBytes = Int(referenceImage.size.height) * minBytesPerRow
        let imagePixelsData = UnsafeMutablePointer<Pixel>.allocate(capacity: cgImage.width * cgImage.height)
        let referenceImagePixelsData = UnsafeMutablePointer<Pixel>.allocate(capacity: cgImage.width * cgImage.height)

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)

        guard let colorSpace = cgImage.colorSpace, let referenceColorSpace = referenceCGImage.colorSpace else { return false }

        guard let imageContext = CGContext(data: imagePixelsData, width: cgImage.width, height: cgImage.height, bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: minBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return false }
        guard let referenceImageContext = CGContext(data: referenceImagePixelsData, width: referenceCGImage.width, height: referenceCGImage.height, bitsPerComponent: referenceCGImage.bitsPerComponent, bytesPerRow: minBytesPerRow, space: referenceColorSpace, bitmapInfo: bitmapInfo.rawValue) else { return false }

        imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        referenceImageContext.draw(referenceCGImage, in: CGRect(x: 0, y: 0, width: referenceImage.size.width, height: referenceImage.size.height))

        var imageEqual = true

        // Do a fast compare if we can
        if tolerance == 0 {
            imageEqual = memcmp(imagePixelsData, referenceImagePixelsData, referenceImageSizeBytes) == 0
        } else {
            // Go through each pixel in turn and see if it is different
            let pixelCount = referenceCGImage.width * referenceCGImage.height

            let imagePixels = UnsafeMutableBufferPointer<Pixel>(start: imagePixelsData, count: cgImage.width * cgImage.height)
            let referenceImagePixels = UnsafeMutableBufferPointer<Pixel>(start: referenceImagePixelsData, count: referenceCGImage.width * referenceCGImage.height)

            var numDiffPixels = 0
            for i in 0..<pixelCount {
                // If this pixel is different, increment the pixel diff count and see
                // if we have hit our limit.
                let p1 = imagePixels[i]
                let p2 = referenceImagePixels[i]

                if p1.value != p2.value {
                    numDiffPixels += 1

                    let percents = CGFloat(numDiffPixels) / CGFloat(pixelCount)
                    if percents > tolerance {
                        imageEqual = false
                        break
                    }
                }
            }
        }

        free(imagePixelsData)
        free(referenceImagePixelsData)

        return imageEqual
    }

    struct Pixel {

        var value: UInt32

        var red: UInt8 {
            get { return UInt8(value & 0xFF) }
            set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
        }

        var green: UInt8 {
            get { return UInt8((value >> 8) & 0xFF) }
            set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
        }

        var blue: UInt8 {
            get { return UInt8((value >> 16) & 0xFF) }
            set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
        }

        var alpha: UInt8 {
            get { return UInt8((value >> 24) & 0xFF) }
            set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
        }

    }
}

func compareImages(image1: CGImage, image2: CGImage) -> Int {
    var diff = 0

    // First create the CIImage representations of the CGImage.
    let ciImage1 = CIImage(cgImage: image1)
    let ciImage2 = CIImage(cgImage: image2)
    
    // Create the difference blend mode filter and set its properties.
    let diffFilter = CIFilter(name: "CIDifferenceBlendMode")
    diffFilter!.setDefaults()
    diffFilter!.setValue(ciImage1, forKey: kCIInputImageKey)
    diffFilter!.setValue(ciImage2, forKey: kCIInputBackgroundImageKey)
    
    // Create the area max filter and set its properties.
    let areaMaxFilter = CIFilter(name: "CIAreaMaximum")
    areaMaxFilter!.setDefaults()
    areaMaxFilter!.setValue(diffFilter!.value(forKey: kCIOutputImageKey),
        forKey: kCIInputImageKey)
    let compareRect = CGRect(x: 0.0, y: 0.0, width: CGFloat(image1.width), height: CGFloat(image1.height))
    let extents = CIVector(cgRect: compareRect)
    areaMaxFilter!.setValue(extents, forKey: kCIInputExtentKey)

    // The filters have been setup, now set up the CGContext bitmap context the
    // output is drawn to. Setup the context with our supplied buffer.
    let alphaInfo = CGImageAlphaInfo.premultipliedLast
    let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var buf: [CUnsignedChar] = Array<CUnsignedChar>(repeating: 255, count: 16)
    let context = CGContext(data: &buf, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 16, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    // Now create the core image context CIContext from the bitmap context.
    let ciContextOpts = [CIContextOption.workingColorSpace : colorSpace, CIContextOption.useSoftwareRenderer : false] as [CIContextOption : Any]
    let ciContext = CIContext(cgContext: context!, options: ciContextOpts)
    
    // Get the output CIImage and draw that to the Core Image context.
    let valueImage = areaMaxFilter!.value(forKey: kCIOutputImageKey)! as! CIImage
    ciContext.draw(valueImage, in: CGRect(x: 0, y: 0, width: 1, height: 1), from: valueImage.extent)
    
    // This will have modified the contents of the buffer used for the CGContext.
    // Find the maximum value of the different color components. Remember that
    // the CGContext was created with a Premultiplied last meaning that alpha
    // is the fourth component with red, green and blue in the first three.
    let maxVal = max(buf[0], max(buf[1], buf[2]))
    diff = Int(maxVal)
    return diff
}
