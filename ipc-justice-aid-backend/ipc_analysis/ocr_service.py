"""
OCR Service for extracting text from images
"""
import cv2
import pytesseract
import numpy as np
from PIL import Image
import io
import logging
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)


class OCRService:
    """Service for extracting text from images using Tesseract OCR"""
    
    def __init__(self):
        # Configure Tesseract (path might need adjustment in Docker)
        # pytesseract.pytesseract.tesseract_cmd = '/usr/bin/tesseract'
        pass
    
    def extract_text_from_image(self, image_file) -> Dict[str, Any]:
        """
        Extract text from an uploaded image file
        
        Args:
            image_file: Django UploadedFile object
            
        Returns:
            Dict containing extracted text and metadata
        """
        try:
            # Read image from uploaded file
            image_data = image_file.read()
            image_file.seek(0)  # Reset file pointer
            
            # Convert to PIL Image
            pil_image = Image.open(io.BytesIO(image_data))
            
            # Convert to OpenCV format for preprocessing
            opencv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
            
            # Preprocess image for better OCR results
            processed_image = self._preprocess_image(opencv_image)
            
            # Extract text using Tesseract
            extracted_text = pytesseract.image_to_string(
                processed_image,
                config='--oem 3 --psm 6'  # Use LSTM OCR Engine and assume single uniform block
            )
            
            # Clean extracted text
            cleaned_text = self._clean_extracted_text(extracted_text)
            
            # Get confidence scores
            confidence_data = pytesseract.image_to_data(
                processed_image,
                output_type=pytesseract.Output.DICT
            )
            
            # Calculate average confidence
            confidences = [int(conf) for conf in confidence_data['conf'] if int(conf) > 0]
            avg_confidence = sum(confidences) / len(confidences) if confidences else 0
            
            return {
                'success': True,
                'text': cleaned_text,
                'confidence': round(avg_confidence, 2),
                'word_count': len(cleaned_text.split()),
                'character_count': len(cleaned_text),
                'image_size': {
                    'width': pil_image.width,
                    'height': pil_image.height
                }
            }
            
        except Exception as e:
            logger.error(f"OCR extraction failed: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'text': '',
                'confidence': 0
            }
    
    def _preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """
        Preprocess image to improve OCR accuracy
        
        Args:
            image: OpenCV image array
            
        Returns:
            Preprocessed image
        """
        # Convert to grayscale
        if len(image.shape) == 3:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        else:
            gray = image
        
        # Apply gaussian blur to reduce noise
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)
        
        # Apply adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            blurred, 
            255, 
            cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
            cv2.THRESH_BINARY, 
            11, 
            2
        )
        
        # Apply morphological operations to clean up the image
        kernel = np.ones((1, 1), np.uint8)
        processed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        processed = cv2.morphologyEx(processed, cv2.MORPH_OPEN, kernel)
        
        return processed
    
    def _clean_extracted_text(self, text: str) -> str:
        """
        Clean and format extracted text
        
        Args:
            text: Raw extracted text
            
        Returns:
            Cleaned text
        """
        if not text:
            return ""
        
        # Remove extra whitespace and newlines
        lines = text.split('\n')
        cleaned_lines = []
        
        for line in lines:
            line = line.strip()
            if line:  # Only keep non-empty lines
                cleaned_lines.append(line)
        
        # Join lines with single space
        cleaned_text = ' '.join(cleaned_lines)
        
        # Remove multiple spaces
        import re
        cleaned_text = re.sub(r'\s+', ' ', cleaned_text)
        
        return cleaned_text.strip()
    
    def validate_image_file(self, image_file) -> Dict[str, Any]:
        """
        Validate uploaded image file
        
        Args:
            image_file: Django UploadedFile object
            
        Returns:
            Validation result
        """
        try:
            # Check file size (max 10MB)
            max_size = 10 * 1024 * 1024  # 10MB
            if image_file.size > max_size:
                return {
                    'valid': False,
                    'error': 'File size exceeds 10MB limit'
                }
            
            # Check file format
            allowed_formats = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp']
            if image_file.content_type not in allowed_formats:
                return {
                    'valid': False,
                    'error': f'Unsupported file format. Allowed: {", ".join(allowed_formats)}'
                }
            
            # Try to open image to validate it's a real image
            image_data = image_file.read()
            image_file.seek(0)  # Reset file pointer
            
            pil_image = Image.open(io.BytesIO(image_data))
            pil_image.verify()  # Verify it's a valid image
            
            return {
                'valid': True,
                'format': image_file.content_type,
                'size_mb': round(image_file.size / (1024 * 1024), 2)
            }
            
        except Exception as e:
            return {
                'valid': False,
                'error': f'Invalid image file: {str(e)}'
            }
