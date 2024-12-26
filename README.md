# PDF Splitter

Split the given PDF file into images with one image per page.

This utility is built using SWIFT to run natively on Apple Silicon machines. It can work parallel or single mode.

- **Single Page Mode** Each page is processed sequentially to produce the output image one at a time
- **Paralle Page Mode** Pages are queued up to and processed in parallel. Since each page is fairly independent of the other, having concurrent execution will speed up processing.

Build the tool and run tool

Usage is:

```text

Usage: splitpdf <input_pdf_path> <output_directory>  [parallel | single]
```

Also run this program with a large file to check out the time difference

### Single Threaded Processing

```sh

#
# process using a single threaded approach
# 
splitpdf largefile.pdf outputs/largefile single

```

On my Mac M3 I get results indicating it took 9.497 seconds to process a file with 70 pages 

**8.95s user 0.47s system 99% cpu 9.497 total**

### Parallel Processing

```sh

splitpdf largefile.pdf outputs/largefile parallel
```

On my Mac M3 I get results indicating it took 1.942 seconds to process a file with 70 pages

**14.23s user 6.30s system 1057% cpu 1.942 total**

Wow! that is about 5x better performance in splitting the files up
