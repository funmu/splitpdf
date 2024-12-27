//
//  main.rs
//
//  splitpdf
//
//  Created by Murali Krishnan on 12/26/24.
//

use clap::Parser;
mod pdf_processor;

/// Simple program to given split PDF file into per-page images 
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Path to the input PDF file
    #[arg(short, long)]
    pdf_file: String,

    /// Path to the output directory
    #[arg(short, long)]
    output_dir: String,

    /// Use multi-threading (default: single-threaded)
    #[arg(short, long)]
    multi_threaded: bool,    
}


fn main() {

    let args = Args::parse();

    // Validate the input parameters
    if !pdf_processor::pdf_processor::check_file( &args.pdf_file) {
        eprintln!("Error: Input PDF file not found.");
        std::process::exit(1);
    }

    // Create output directory if it doesn't exist
    std::fs::create_dir_all(&args.output_dir).unwrap_or_else( |error| {
        eprintln!("Error creating output directory: {}", error);
        std::process::exit(1);
    });

    println!( "\nGot valid inputs.");
    println!( "Input file: \t{}", args.pdf_file);
    println!( "Output Dir: \t{}", args.output_dir);
    println!( "Let us proceed with the splitting operation\n");

    // split up the PDF file into page level images
    if !pdf_processor::pdf_processor::split_pdf(
         &args.pdf_file,
         &args.output_dir,
         args.multi_threaded
        ) {
        eprintln!("Error: Unable to split PDF file.");
        std::process::exit(1);
    }
}
