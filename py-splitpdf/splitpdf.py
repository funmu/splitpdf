# splitpdf.py
#
# split given PDF into images, one per page
#
# Created: Dec 27, 2024 by Murali Krishnan

import os
import argparse
import time

from pdf2image import convert_from_path
from pdf2image.exceptions import (
    PDFInfoNotInstalledError,
    PDFPageCountError,
    PDFSyntaxError
)

LOG_INFO = True #Can choose if we want to log at the info level or just the errors.
MAX_THREADS = 20

def setupCommandsParser():
    parser = argparse.ArgumentParser( description="Splits PDF documents into images, one per page")

    parser.add_argument("-m", "--multiple_threads", type=int, default=1,
        help="Use multi-threading with specified threads (default: 1; single threaded).")
    parser.add_argument("-p", "--pdf", type=str,
        help="Path for the location of input PDF file.")
    parser.add_argument("-o", "--output_dir", type=str,
        help="Path to save the the output files.")
    parser.add_argument("-l", "--logging", type=chr,
        help="Whether or not we want to log at the info level (y) or just the warnings and errors (n).")
    
    return parser;
    
def printUsage():
    print("splitpdf : splits PDF into images")
    parser.print_usage()

def create_folder( dir_path):
    """
    Creates a folder (including parent folders if they don't exist).

    Args:
    dir_path: The path to the folder to create.
    """

    if os.path.exists(dir_path):
        print(f"Folder '{dir_path}' already exists.")
        return True;

    try:
        os.makedirs(dir_path)
        print(f"Folder '{dir_path}' created successfully.")
        return True
    except FileExistsError:
        print(f"Folder '{dir_path}' already exists.")
    except OSError as e:
        print(f"Error creating folder '{dir_path}': {e}")

    return False

def convertToImages(pdf_path, output_folder, output_file_prefix):

    try:
        images = convert_from_path(pdf_path, fmt='png', dpi=300)
        for i, image in enumerate(images):
            image_path = os.path.join(output_folder, f"{output_file_prefix}_{i+1}.png")
            image.save(image_path, "png")
    except Exception as e:
        print(f"Error converting PDF: {e}")

def splitPDF(args):
    """
    Splits PDF file into the per-page images

    Args:
        args.pdf: location of the PDF file
        args.output_dir: folder where to place the image files
    """
    print( f"Input File:\t {args.pdf}")
    print( f"Output Dir:\t {args.output_dir}")
    print( f"# Threads:\t {args.multiple_threads}")

    start_time = time.time()  # Record start time

    # method 1: generate images and save them to output folder directly
    convert_from_path( args.pdf, output_folder=args.output_dir, \
        dpi=300, fmt='png', output_file="page", thread_count=args.multiple_threads)

    # method 2: alternate way to generate images first and then save it
    # this method is slower
    # convertToImages( args.pdf, args.output_dir, "page")

    end_time = time.time()  # Record end time
    elapsed_time = end_time - start_time  # Calculate elapsed time
    print(f"PDF converted to images in {elapsed_time:.2f} seconds and saved in '{args.output_dir}'")

if __name__ == "__main__":
    parser = setupCommandsParser();
    args = parser.parse_args()

    # Validate arguments received
    if len(vars(args)) == 0:
        parser.print_usage()
        exit(1)

    if args.logging and args.logging != "y" and args.logging != "n":
        print("\n INVALID LOGGING OPTION REQUESTED")
        parser.print_usage()
        exit(1)

    if args.pdf == None or not os.path.exists(args.pdf):
        print("\n INVALID Inputs: Input PDF file not given")
        parser.print_usage()
        exit(1)

    if args.output_dir == None or not create_folder(args.output_dir):
        print("\n INVALID Inputs: Output directory is not given")
        parser.print_usage()
        exit(1)
    
    if args.multiple_threads > MAX_THREADS or args.multiple_threads < 1:
        print("\n INVALID Inputs: Specified thread count is out of range")
        parser.print_usage()
        exit(1)

    splitPDF( args)
