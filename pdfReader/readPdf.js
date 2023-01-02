const PDFJS = require("pdfjs-dist")

// source https://stackoverflow.com/a/42606717

/**
 * Retrieves the text of a specif page within a PDF Document obtained through pdf.js
 *
 * @param {Integer} pageNum Specifies the number of the page
 * @param {PDFDocument} PDFDocumentInstance The PDF document obtained
 **/
function getPageText(pageNum, PDFDocumentInstance) {
  // Return a Promise that is solved once the text of the page is retrieven
  return new Promise(function (resolve, reject) {
    PDFDocumentInstance.getPage(pageNum).then(function (pdfPage) {
      // The main trick to obtain the text of the PDF page, use the getTextContent method
      pdfPage.getTextContent().then(function (textContent) {
        var textItems = textContent.items
        var finalString = ""

        // Concatenate the string of the item to the final string
        for (var i = 0; i < textItems.length; i++) {
          var item = textItems[i]
          console.log(item);
          finalString += item.str + " "
          if (item.hasEOL)
            finalString += "\n"
        }

        // Solve promise with the text retrieven from the page
        resolve(finalString)
      })
    })
  })
}

/**
 * Extract the test from the PDF
 */

const args = process.argv.slice(2);

var PDF_URL = args[0]
PDFJS.getDocument(PDF_URL).promise.then(
  function (PDFDocumentInstance) {
    var totalPages = PDFDocumentInstance.numPages
    var pageNumber = 100
    
    // Extract the text
    getPageText(pageNumber, PDFDocumentInstance).then(function (textPage) {
      // Show the text of the page in the console
      console.log(textPage)
    })
  },
  function (reason) {
    // PDF loading error
    console.error(reason)
  }
)
