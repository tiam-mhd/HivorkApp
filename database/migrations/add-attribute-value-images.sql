-- Migration: Add image support to product attribute values
-- Date: 2025-11-23
-- Description: Add imageUrl field to store images for attribute values (e.g., color swatches)

-- Add imageUrl column to product_attribute_values table
ALTER TABLE product_attribute_values
ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

-- Add comment for documentation
COMMENT ON COLUMN product_attribute_values.image_url IS 
'Optional image URL for this attribute value. Used for visual attributes like colors, fabrics, patterns, etc. This provides a mid-level image between product images and variant images.';

-- Create index for faster queries when filtering by images
CREATE INDEX IF NOT EXISTS idx_product_attribute_values_image_url 
ON product_attribute_values(image_url) 
WHERE image_url IS NOT NULL;
