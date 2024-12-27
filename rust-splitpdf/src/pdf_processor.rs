//
//  pdf_processor.rs
//
//  splitpdf
//
//  Created by Murali Krishnan on 12/26/24.
//

pub mod pdf_processor {

    use std::path::Path;
    use std::time::Instant;
    use image::ImageFormat;
    use pdfium_render::prelude::*;

    // ToDO: enable multi-threaded execution once we ensure thread safety of PDF documents
    /*
    use std::sync::mpsc;
    use std::thread;
    */

    pub fn check_file( f: &str) -> bool {
        return Path::new(&f).exists();
    }

    // convert a given page as per configuration into an image
    //  write the image to the output_dir 
    //  with specific file name page-NNN.png
    fn convert_pdf_page( index: usize, page: &PdfPage, 
        render_config: &PdfRenderConfig,
        output_dir: &str)
    -> Result<(), Box<dyn std::error::Error>> {

        println!("Processing page {}", (index+1));

        let image = page.render_with_config(&render_config)?
            .as_image() // Renders this page to an image::DynamicImage...
            ;
        let output_path = Path::new(&output_dir)
            .join(format!("page_{}.png", index + 1));

        image.save_with_format( output_path,
            ImageFormat::Png
        ) // ... and saves it to a file.
        .map_err(|_| PdfiumError::ImageError)?;

        Ok(())
    }

    fn single_threaded_split_pdf( pdf: &PdfDocument, output_dir: &str)
        -> Result<(), Box<dyn std::error::Error>> {

        // ... set rendering options that will be applied to all pages...
        let render_config = PdfRenderConfig::new()
            .set_target_width(2000)
            .set_maximum_height(2000);
            // .rotate_if_landscape(PdfPageRenderRotation::Degrees90, true);

        // ... then render each page to a bitmap image, saving each image to a JPEG file.

        for (index, page) in pdf.pages().iter().enumerate() {

            convert_pdf_page( index, &page, &render_config, &output_dir)
            .unwrap_or_else( |error| {
                eprintln!("Error in generating image for page: {}\n{}", 
                    (index+1), error);
            });
        }

        Ok(())
    }

/*
    // ToDO: enable multi-threaded execution once we ensure thread safety of PDF documents

    fn multi_threaded_split_pdf( pdf: &PdfDocument, output_dir: &str, max_threads: usize)
        -> Result<(), Box<dyn std::error::Error>> {

        // ... set rendering options that will be applied to all pages...
        let render_config = PdfRenderConfig::new()
            .set_target_width(2000)
            .set_maximum_height(2000);
            // .rotate_if_landscape(PdfPageRenderRotation::Degrees90, true);
        
        // set up infra for multi-threaded execution
        let (tx, rx) = mpsc::channel();
        let page_count: usize = pdf.pages().len() as usize;
        let num_threads: usize = std::cmp::min( max_threads, page_count);

        // start up the threads to execute locally
        for i in 0..num_threads {
            let tx = tx.clone();
            let pdf = pdf.clone();
            let tx_output_dir = output_dir.clone();

            thread::spawn(move || {

                // within each thread, process appropriate number of pages
                for page_number in (i..page_count).step_by(num_threads) {
                    
                    let page = pdf.pages().get(page_number.try_into().unwrap()).unwrap();

                    // ... then render each page to a bitmap image, saving each image to a JPEG file.
                    convert_pdf_page( page_number, &page, &render_config, &tx_output_dir)
                    .unwrap_or_else( |error| {
                        eprintln!("Error in generating image for page: {}\n{}", 
                            (page_number+1), error);
                    });

                    tx.send(()).unwrap();
                }
            });
        }

        // Wait for all threads to finish
        for _ in 0..page_count {
            rx.recv().unwrap();
        }            

        Ok(())
    }    
*/

    pub fn split_pdf( pdf_file: &str, 
        output_dir: &str,
        multi_threaded: bool
    ) -> bool {

        let f_result : bool;
        let mut page_count: u16 = 0;

        let start_time = Instant::now();

        // Or use the ? unwrapping operator to pass any error up to the caller
        let pdfium = Pdfium::new(
            Pdfium::bind_to_library(Pdfium::pdfium_platform_library_name_at_path("./"))
                .or_else(|_| Pdfium::bind_to_system_library())
                .unwrap_or_else( |_error| {
                eprintln!("Error: Unable to bind to PDFium library. {}", _error);
                std::process::exit(1);
            })
        );

        // Load the PDF document
        let pdf_result = pdfium.load_pdf_from_file(
            &pdf_file, // pdf doc to load
            None,  // No password
        );

        // extract results
        match pdf_result {
            Ok(pdf) => {
                // Get the number of pages
                page_count = pdf.pages().len() as u16;
                
                // ToDO: enable multi-threaded execution once we ensure thread safety of PDF documents
                // switch to single threaded execution till thread safety is achieved

                if multi_threaded {
                    println!( "Multi-threaded mode is disabled for thread safety. Switching to single threaded mode.")
                }

/*                if multi_threaded {

                    let max_threads = 20;

                    multi_threaded_split_pdf( &pdf, &output_dir, max_threads)
                    .unwrap_or_else( |error| {
                        eprintln!("Error in generating images: {}", error);
                        std::process::exit(1);
                    });

                } else {
*/                 
                    single_threaded_split_pdf( &pdf, &output_dir)
                        .unwrap_or_else( |error| {
                            eprintln!("Error in generating images: {}", error);
                            std::process::exit(1);
                        });
/*                }  */
                
                f_result = true;
            }

            Err(err) => {
                eprintln!("Error loading PDF: {}", err);
                // Handle the error appropriately (e.g., exit with an error code)
                f_result = false;
            }
        }        

        let elapsed_time = start_time.elapsed();
        println!("\nPDF to image conversion completed in {:?}", elapsed_time);
        println!("\n{} page level images saved in {}", page_count, output_dir);
    
        // Ok( ())
        return f_result;
    }
}
