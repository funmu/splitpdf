# SplitPDF implemented with RUST

Let us check it out and see how to build a simple app using RUST.

## Play with PDF using RUST

Let us also add some of the PDF management utilities.
We have to use **pdfium**, the PDF utility from Google built for Chromium.
There is a publicly available binary for **libpdfiy.dylib** at https://github.com/bblanchon/pdfium-binaries?tab=readme-ov-file. However, there is a security issue in using the downloaded item.
We need to remove the code signature and install with my own signature to make it work for me.

```sh

# after downloading, copy the file to local folder
# then, remove signature
codesign --remove-signature ./libpdfium.dylib

# next, add a local developer certification to sign it
codesign -s "Apple Development: YOUR ID FOR signing" libpdfium.dylib

```

Now the libray is ready for usage.

## SplitPDF using RUST

Code for Splitting PDF is in [pdf_processor](./src/pdf_processor.rs).
The command line interface is in [main.rs](./src/main.rs)

Compile and run the program as follows:

```sh

# compile the binaries; make sure to have all dependencies installed
cargo build

# run the binary generated (by default we will use the debug build)
./target/debug -p PDFFile -o OUTPUTDIR

```

The underlying library *libpdfiy* does not support thread safe access to PdfDocument.
We have to wrap the object within locking sections; we will revisit this later on.

## References

- [Tools Doc: Rust](https://github.com/funmu/tooldocs/docs/rust_tools.md)
- [PDFium-render library in Rust](https://crates.io/crates/pdfium-render)

### PDFium Source 1

- [PDFium library for MacOS / Apple Silicon chips](https://github.com/bblanchon/pdfium-binaries?tab=readme-ov-file)

### PDFium Source 2

- [PDFium library from Google](https://pdfium.googlesource.com/)
- [PDFium library for cross platform](https://github.com/paulocoutinhox/pdfium-lib)
- [PDFium library read-to-use on cross platform](https://github.com/paulocoutinhox/pdfium-lib/releases)
