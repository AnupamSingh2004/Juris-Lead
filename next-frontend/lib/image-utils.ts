/**
 * Image processing utilities for the analyzer
 */

import { ApiService, type OCRResponse } from './api-service'

export interface ImageValidationResult {
  valid: boolean
  error?: string
  format?: string
  sizeMB?: number
}

export interface ImageExtractionResult {
  success: boolean
  text: string
  confidence: number
  metadata?: {
    wordCount: number
    characterCount: number
    imageSize: {
      width: number
      height: number
    }
    fileInfo: {
      name: string
      sizeMB: number
      format: string
    }
  }
  error?: string
}

/**
 * Validate an image file before processing
 */
export function validateImageFile(file: File): ImageValidationResult {
  // Check file size (max 10MB)
  const maxSize = 10 * 1024 * 1024 // 10MB
  if (file.size > maxSize) {
    return {
      valid: false,
      error: 'File size exceeds 10MB limit'
    }
  }

  // Check file format
  const allowedFormats = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/bmp',
    'image/webp'
  ]
  
  if (!allowedFormats.includes(file.type)) {
    return {
      valid: false,
      error: `Unsupported file format. Allowed: ${allowedFormats.join(', ')}`
    }
  }

  return {
    valid: true,
    format: file.type,
    sizeMB: Math.round((file.size / (1024 * 1024)) * 100) / 100
  }
}

/**
 * Check if image extraction is supported (i.e., user is authenticated)
 */
export function isImageExtractionSupported(): boolean {
  return ApiService.isAuthenticated()
}

/**
 * Check if file is an image
 */
export function isImageFile(file: File): boolean {
  return file.type.startsWith('image/')
}

/**
 * Extract text from image using backend OCR service
 */
export async function extractTextFromImage(file: File): Promise<ImageExtractionResult> {
  try {
    // Validate file first
    const validation = validateImageFile(file)
    if (!validation.valid) {
      return {
        success: false,
        text: '',
        confidence: 0,
        error: validation.error
      }
    }

    // Check if service is available
    if (!isImageExtractionSupported()) {
      return {
        success: false,
        text: '',
        confidence: 0,
        error: 'Image text extraction requires authentication'
      }
    }

    // Call backend OCR service
    const ocrResponse: OCRResponse = await ApiService.extractTextFromImage(file)

    return {
      success: true,
      text: ocrResponse.extracted_text,
      confidence: ocrResponse.confidence,
      metadata: {
        wordCount: ocrResponse.metadata.word_count,
        characterCount: ocrResponse.metadata.character_count,
        imageSize: ocrResponse.metadata.image_size,
        fileInfo: {
          name: ocrResponse.metadata.file_info.name,
          sizeMB: ocrResponse.metadata.file_info.size_mb,
          format: ocrResponse.metadata.file_info.format
        }
      }
    }

  } catch (error) {
    console.error('Image text extraction failed:', error)
    
    let errorMessage = 'Failed to extract text from image'
    
    if (error instanceof Error) {
      errorMessage = error.message
    }

    return {
      success: false,
      text: '',
      confidence: 0,
      error: errorMessage
    }
  }
}

/**
 * Get file size in human readable format
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

/**
 * Create image preview URL for display
 */
export function createImagePreviewURL(file: File): string {
  return URL.createObjectURL(file)
}

/**
 * Clean up image preview URL to prevent memory leaks
 */
export function revokeImagePreviewURL(url: string): void {
  URL.revokeObjectURL(url)
}
