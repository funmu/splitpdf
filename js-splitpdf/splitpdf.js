/*
    splitpdf.js

    Splits input PDF file into images

*/

const fs = require('node:fs');
const { pdfToPng } = require('pdf-to-png-converter');

async function renderAPage( pageIndex,  page, outputDir) {

  try {
      const viewport = page.getViewport({ scale: 1.0 }); // Adjust scale as needed

      const canvas = new Canvas(viewport.width, viewport.height);
      const canvasContext = canvas.getContext('2d');

      // Set the global composite operation to 'source-over'
      canvasContext.globalCompositeOperation = 'source-over';

      // await page.render({ canvasContext, viewport }).promise;
        // Render the page with the modified transform
      await page.render({
          canvasContext,
          viewport,
          transform: [1, 0, 0, 1, 0, 0],
          imageLayer: new Canvas(viewport.width, viewport.height)
      }).promise;

      // Save the image as PNG (CORRECTED)
      const outputPath = `${outputDir}/page_${i}.png`;
      const stream = canvas.createPNGStream();
      const out = fs.createWriteStream(outputPath);

      console.log( `Rendering page ${pageIndex} as image to ${outputPath}`)
      stream.pipe(out);
      await new Promise((resolve, reject) => {
          out.on('finish', resolve);
          out.on('error', reject);
      });
  } catch (error) {
      console.error( `Error rendering a single page ${pageIndex} as Image:`, error);
  }
}


async function splitPdf(pdfPath, outputDir) {
  try {

    // check if the input file exits

    if (!fs.existsSync( pdfPath)) {
      console.error( `Missing the input file ${pdfPath}`)
      throw "Input PDF file does not exist"
    }

    // Create the output directory if it doesn't exist
     if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    const pngPages = await pdfToPng(pdfPath, { // The function accepts PDF file path or a Buffer
        disableFontFace: false, // When `false`, fonts will be rendered using a built-in font renderer that constructs the glyphs with primitive path commands. Default value is true.
        useSystemFonts: false, // When `true`, fonts that aren't embedded in the PDF document will fallback to a system font. Default value is false.
        enableXfa: false, // Render Xfa forms if any. Default value is false.
        viewportScale: 2.0, // The desired scale of PNG viewport. Default value is 1.0.
        outputFolder: outputDir, // Folder to write output PNG files. If not specified, PNG output will be available only as a Buffer content, without saving to a file.
        outputFileMaskFunc: (pageNum) => `page_${pageNum}.png`, // Function to generate custom output filenames. Example: (pageNum) => `page_${pageNum}.png`
        pdfFilePassword: '', // Password for encrypted PDF.
//        pagesToProcess: [1, 3, 11], // Subset of pages to convert (first page = 1), other pages will be skipped if specified.
//        strictPagesToProcess: false, // When `true`, will throw an error if specified page number in pagesToProcess is invalid, otherwise will skip invalid page. Default value is false.
        verbosityLevel: 0 // Verbosity level. ERRORS: 0, WARNINGS: 1, INFOS: 5. Default value is 0.
    });
    // Further processing of pngPages

    /* output is in the form
      {
        pageNumber: number; // Page number in PDF file
        name: string; // PNG page name (use outputFileMaskFunc to change it)
        content: Buffer; // PNG page Buffer content
        path: string; // Path to the rendered PNG page file (empty string if outputFolder is not provided)
        width: number; // PNG page width
        height: number; // PNG page height
      }
    */
   
    // Iterate over pages and extract each as an image
    for (let i = 0; i < pngPages.length; i++) {
      const pageInfo = pngPages[i];

      console.log( `Page [${pageInfo.pageNumber}] picture at ${pageInfo.width} x ${pageInfo.height} is ${pageInfo.content.length} bytes long.
        Saved at ${pageInfo.path}`)
        // renderAPage( i, page, outputDir);
    }

    console.log('PDF split into images successfully!');
  } catch (error) {
    console.error('Error splitting PDF:', error);
  }
}

// ToDO: use command line parameters to fetch the file names and output directory
const pdfFilePath = '../../pdf-files/1p-math.pdf';
const outputDirectory = '../../outputs/1p';

splitPdf(pdfFilePath, outputDirectory);

