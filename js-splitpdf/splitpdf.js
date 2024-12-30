/*
    splitpdf.js

    Splits input PDF file into images

*/

const fs = require('node:fs');
// const pdfjsLib = require('pdfjs-dist');
const pdfjsLib = require('pdfjs-dist/legacy/build/pdf.js'); // Use legacy build
const { Canvas } = require('canvas'); 


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
    // Read the PDF file
    const data = new Uint8Array(fs.readFileSync(pdfPath));

    // Load the PDF document
    const pdf = await pdfjsLib.getDocument({ data }).promise;

    // Create the output directory if it doesn't exist
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Iterate over pages and extract each as an image
    for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        renderAPage( i, page, outputDir);
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
