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
        var bookName = ""
        var page = ""
        var commentStarted = false
        var commentWillStart = false
        
        // Concatenate the string of the item to the final string
        for (var i = 0; i < textItems.length; i++) {
          var item = textItems[i]
          //console.log(item);
          if (!commentStarted) {
            if (item.fontName = 'g_d0_f6') {
              // console.log(item)
              if (bookName.length == 0 && item.str.length > 1) {
              	bookName = item.str
              	continue
              } else if (page.length == 0 && item.str.length > 1) {
              	page = item.str
              	continue
              } else if (finalString.length > 10 && item.height < 8) {
                if (commentWillStart && item.str.length > 0 && item.str != " ") {
                  console.log(item)
                  finalString += "\n\nComments:\n"
                  commentStarted = true
                } else if (item.str.length == 0) {
                  commentWillStart = true
                }
              }
            }
          }	
          if (item.str.length > 1) {
	        finalString += item.str + " "
	        if (item.hasEOL)
	          finalString += "\n"
          }
        }

        // Solve promise with the text retrieven from the page
        resolve({pageText: finalString, page, bookName})
      })
    })
  })
}

/**
 * Extract the test from the PDF
 */

const addPage = (bible, page) => {
  for (const line of page.split("\n")) {
  	console.log(line)
  }
}


const args = process.argv.slice(2);

var PDF_URL = args[0]
PDFJS.getDocument(PDF_URL).promise.then(
  function (PDFDocumentInstance) {
    var totalPages = PDFDocumentInstance.numPages
    var pageNumber = 100
    var bible = {}
    // Extract the text
    getPageText(pageNumber, PDFDocumentInstance).then(function ({pageText, bookName}) {
      // Show the text of the page in the console
      addPage(bible, pageText)
      console.log(bible)
    })
  },
  function (reason) {
    // PDF loading error
    console.error(reason)
  }
)
