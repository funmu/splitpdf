//
//  main.swift
//  splitpdf
//
//  Created by Murali Krishnan on 12/25/24.
//

import Foundation

struct MainFunction {
    
    static func main() {
        // 1. Parse Command Line Arguments
        guard CommandLine.arguments.count >= 3 else {
            printUsage()
            return
        }
        
        print( "arguments: \(CommandLine.arguments)")
        
        let inputPDFPath = CommandLine.arguments[1]
        let outputDirectory = CommandLine.arguments[2]
        
        let speed: String = (CommandLine.arguments.count > 3)
        ? CommandLine.arguments[3] as String
        : ""
        
        // 2. Validate Input
        guard FileManager.default.fileExists(atPath: inputPDFPath) else {
            print("Error: Input PDF file not found.")
            return
        }
        
        var fParallel: Bool = false
        if (speed == "parallel") {
            fParallel = true // go with parallel option for speed
        }
        
        print( "input File: \(inputPDFPath)")
        print( "output dir: \(outputDirectory)")
        
        // 3. Split PDF and write images o files
        PDFSplitter.splitDocumentToImages(inputPDFPath, outputDirectory, fParallel)
    }
    
    // Helper function to print usage instructions
    static func printUsage() {
        print("Usage: splitpdf <input_pdf_path> <output_directory>  [parallel | single]")
        print("Example: splitpdf mydocument.pdf output_images")
    }
}

// Run the main function
MainFunction.main()
