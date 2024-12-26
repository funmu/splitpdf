//
//  PDFSplitter.swift
//
//  splitpdf
//
//  Created by Murali Krishnan on 12/25/24.
//

import Foundation
import PDFKit
import AppKit

struct PDFSplitter {
    
    static func splitDocumentToImages(
        _ inputPDFPath: String,
        _ outputDirectory: String,
        _ fParallel: Bool) {

        // 1. Load PDF
        guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: inputPDFPath)) else {
            print("Error: Could not load PDF document.")
            return
        }

        // 2. Create Output Directory if needed
        do {
            try FileManager.default.createDirectory(atPath: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error: Could not create output directory: \(error)")
            return
        }

        // 3. Iterate Through Pages and Save as Images
        if (fParallel) {
            print( "\nSplitting pages using concurrent splitter on multiple pages\n")
            parallelPageSplitter( pdfDocument, outputDirectory as String)
        } else {
            print( "\nSplitting pages using single page splitter\n")
            singlePageSplitter( pdfDocument, outputDirectory as String)
        }
        
        print("PDF splitting complete!")
    }

    static private func singlePageSplitter(_ pdfDocument: PDFDocument, _ outputDirectory: String) {
    
        for pageIndex in 0..<pdfDocument.pageCount {
            processAPage( pdfDocument, pageIndex, outputDirectory)
        }
    }

    static private func parallelPageSplitter(_ pdfDocument: PDFDocument, _ outputDirectory: String) {

     let dispatchGroup = DispatchGroup()
        let concurrentQueue = DispatchQueue(label: "com.pdfsplitter.concurrentQueue", attributes: .concurrent)

        for pageIndex in 0..<pdfDocument.pageCount {
            dispatchGroup.enter() // Enter the dispatch group for each page

            concurrentQueue.async { // Process each page on the concurrent queue
                processAPage( pdfDocument, pageIndex, outputDirectory)
                dispatchGroup.leave() // Leave the dispatch group after processing
            }
        }

        dispatchGroup.wait() // Wait for all pages to be processed
    }

    static private func processAPage(
        _ pdfDocument: PDFDocument, _ pageIndex: Int, _ outputDirectory: String) {

        guard let page = pdfDocument.page(at: pageIndex) else {
            print("Error: Could not get page \(pageIndex + 1).")
            return
        }

        let pageNumber = pageIndex + 1
        let outputFileName = "page-\(pageNumber).png"
        let outputImagePath = (outputDirectory as NSString).appendingPathComponent(outputFileName)

        if !savePageAsImage(page: page, to: outputImagePath) {
            print("Error: Could not save page \(pageNumber) as image.")
        } else {
            print("Saved page \(pageNumber) to \(outputImagePath)")
        }
    }

    // Helper function to save a PDF page as an image (macOS version)
    static private func savePageAsImage(page: PDFPage, to path: String) -> Bool {
        
        let dpi: CGFloat = 72.0 // 300.0    // Adjust the desired DPI; start at high resolution
        let pageBounds = page.bounds(for: .mediaBox)
        let pageWidth = pageBounds.width
        let pageHeight = pageBounds.height

        // Calculate pixel dimensions
        let imageWidth = Int(pageWidth * dpi / 72.0)
        let imageHeight = Int(pageHeight * dpi / 72.0)

        // Create an NSImage
        let image = NSImage(size: NSSize(width: imageWidth, height: imageHeight))

        // Draw into the image
        image.lockFocus()
        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return false
        }

        // Set the background color to white
        context.setFillColor(NSColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

        // --- Transformations to Correct Orientation (Correct Order) ---
        // by doing experiments I found that there is no need for scaling or translation
        
        // Transformations: if required use the following
        // 1. Flip the Y-axis to match image coordinate system (origin at top-left)
        // context.scaleBy(x: 1.0, y: 1.0) // Flip vertically
        // context.translateBy(x: 0.0, y: -CGFloat(imageHeight)) // Move origin to bottom-left

        // 2. Compensate for default PDF page rotation (if any)
        //    PDFs may have a built-in rotation. This rotates the page
        //    back to its normal orientation.
        // context.rotate(by: .pi) // 180-degree rotation (in radians)

        // Set the resolution of the context to match the desired DPI
        context.scaleBy(x: dpi / 72.0, y: dpi / 72.0)

        // Draw the PDF page
        page.draw(with: .mediaBox, to: context)

        image.unlockFocus()

        // Get image data (PNG)
        guard let tiffRepresentation = image.tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffRepresentation),
            let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return false
        }

        // Write to file
        do {
            try pngData.write(to: URL(fileURLWithPath: path))
            return true
        } catch {
            print("Error writing image data: \(error)")
            return false
        }
    }
}
