export interface PDFExtractionResult {
  text: string;
  pageCount: number;
  metadata?: any;
}

/**
 * Extract text content from a PDF file
 * @param file - The PDF file to extract text from
 * @returns Promise with extracted text and metadata
 */
export async function extractTextFromPDF(file: File): Promise<PDFExtractionResult> {
  try {
    // Dynamic import to avoid SSR issues
    const pdfjsLib = await import('pdfjs-dist');
    
    // Configure the worker to use the local copy with matching version
    if (typeof window !== 'undefined') {
      pdfjsLib.GlobalWorkerOptions.workerSrc = '/pdf.worker.min.js';
    }
    
    // Convert file to ArrayBuffer
    const arrayBuffer = await file.arrayBuffer();
    
    // Load PDF document
    const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
    
    let fullText = '';
    const pageCount = pdf.numPages;
    
    // Extract text from each page
    for (let pageNum = 1; pageNum <= pageCount; pageNum++) {
      const page = await pdf.getPage(pageNum);
      const textContent = await page.getTextContent();
      
      // Combine text items into a single string
      const pageText = textContent.items
        .map((item: any) => {
          if (item && typeof item === 'object' && 'str' in item) {
            return item.str || '';
          }
          return '';
        })
        .join(' ');
      
      fullText += pageText + '\n\n';
    }
    
    // Clean up the extracted text
    const cleanedText = cleanExtractedText(fullText);
    
    return {
      text: cleanedText,
      pageCount,
      metadata: {
        fileName: file.name,
        fileSize: file.size,
        extractedAt: new Date().toISOString()
      }
    };
  } catch (error) {
    console.error('PDF text extraction error:', error);
    throw new Error(`Failed to extract text from PDF: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
}

/**
 * Clean and normalize extracted text
 * @param text - Raw extracted text
 * @returns Cleaned text
 */
function cleanExtractedText(text: string): string {
  return text
    // Remove excessive whitespace
    .replace(/\s+/g, ' ')
    // Remove excessive line breaks
    .replace(/\n\s*\n\s*\n/g, '\n\n')
    // Trim whitespace
    .trim();
}

/**
 * Validate if file is a PDF
 * @param file - File to validate
 * @returns boolean
 */
export function isPDFFile(file: File): boolean {
  return file.type === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf');
}

/**
 * Check if PDF extraction is supported in current environment
 * @returns boolean
 */
export function isPDFExtractionSupported(): boolean {
  return typeof window !== 'undefined' && 'Worker' in window;
}
