//
//  COProcessSettings.h
//  CaptureOnePlugins
//
//  Created by Cătălin Stan on 11/07/2018.
//  Copyright © 2018 Phase One A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The keys defined in this array are used to override the default settings Capture One uses to process images.
 */
typedef NSString * COProcessSettingsKey NS_STRING_ENUM;

/** @name Setting Supported File Formats */

/**
 Expects an array of COProcessFileFormat values. Defines the file format(s) that Capture One
 lets the user choose from when starting a plugin action. The file format picked by the user is
 used to process the images for the plugin action.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COSupportedFileFormatsKey;

/** @name Setting the Default File Format */

/**
 Expects a value of type COProcessFileFormat. Defines the default selected file format or, if
 the user cannot change the recipe, the output format that is used to process the images.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessFileFormatKey;

/** @name Configuring Default Export Settings */

/**
 Expects a value of type COProcessBits. Defines the bit depth of the processed image. This key is
 only used if COProcessFileFormatKey is set to one of the following: COProcessFileFormatJPEG2000,
 COProcessFileFormatTIFF, or COProcessFileFormatPSD.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessBitsKey;

/**
 Expects an unsigned integer. Defines the processing resolution. The unit in which the resolution
 is provided is defined using the COProcessResolutionUnit key.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessResolutionKey;

/**
 Expects a value of type COProcessResolutionUnit. Defines the unit in which the resolution
 (COProcessResolutionKey) is provided.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessResolutionUnitKey;

/** @name Configuring JPEG Export Settings */

/**
 Expects a value of type COProcessBits. Defines the bit depth for JPEG processing. Only used if
 COProcessFileFormatKey is set to COProcessFileFormatJPEG2000.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessJpegBitsKey;

/**
 Expects an unsinged integer between 1 and 100. Defines the JPEG processing quality. Only used if
 COProcessFileFormatKey is set to one of the following: COProcessFileFormatJPEG, COProcessFileFormatJPEGXR,
 COProcessFileFormatJPEG2000.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessJpegQualityKey;

/** @name Configuring TIFF Export Settings */

/**
 Expects a value of type COProcessBits. Defines the bit depth for images processed as tiff. Only used if
 COProcessFileFormatKey is set to COProcessFileFormatTIFF.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessTiffBitsKey;

/**
 Expects a value of type COProcessTiffCompression. Defines the compression method for images processed as tiff.
 Only used if COProcessFileFormatKey is set to COProcessFileFormatTIFF.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessTiffCompressionKey;

/** @name Configuring Output Scaling */

/**
 Expects a value of type COProcessScaleMethod. Defines if/how the image should be scaled for processing.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleMethodKey;

/**
 Expects a value of type COProcessSizeUnit. Defines the unit in which the output size is specified. Does not
 have any effect if COProcessScaleMethod is set to COProcessScaleMethodFixed.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleUnitKey;

/**
 Expects an unsigned integer between 0 and 100. This value specifies the amount by which the image should be scaled
 relative to the original size. Only used if COProcessScaleMethodKey is set to COProcessScaleMethodFixed.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleAmountKey;

/**
 Expects a float value larger than 0. If the scale method (COProcessScaleMethodKey) is set to Width (COProcessScaleMethodWidth),
 this value specifies the target width of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleWidthKey;

/**
 Expects a float value larger than 0. If the scale method (COProcessScaleMethodKey) is set to height (COProcessScaleMethodHeight),
 this value specifies the target height of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleHeightKey;

/**
 Expects a float value larger than 0. If the scale method (COProcessScaleMethodKey) is set to long edge (COProcessLongEdgeScaleKey)
 or short edge (COProcessShortEdgeScaleKey), this values specifies the target length of the long/short edge of
 the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessScaleLengthKey;

/**
 Expects a BOOL. When set to true, images will never be upscaled during processing.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessNeverUpscaleKey;

/** @name Configuring Fixed Output Scaling */

/**
 Expects a dictionary with one entry: the COProcessScaleAmountKey. Specifies how the images
 should be scaled if COProcessScaleMethod is set to COProcessScaleMethodFixed.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessFixedScaleKey;

/** @name Configuring Width Output Scaling */

/**
 Expects a dictionary with two entries: the COProcessScaleUnitKey and COProcessScaleWidthKey. Specifies how the images
 is scaled if COProcessScaleMethod is set to COProcessScaleMethodWidth.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessWidthScaleKey;

/** @name Configuring Height Output Scaling */

/**
 Expects a dictionary with two entries: the COProcessScaleUnitKey and COProcessScaleHeightKey. Specifies how the images
 is scaled if COProcessScaleMethod is set to COProcessScaleMethodHeight.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessHeightScaleKey;

/** @name Configuring Width by Height Output Scaling */

/**
 Expects a dictionary with three entries: the COProcessScaleUnitKey, COProcessScaleWidthKey,
 and COProcessScaleHeightKey. Specifies how the images should be scaled if COProcessScaleMethod
 is set to COProcessWidthByHeightScaleKey.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessWidthByHeightScaleKey;

/** @name Configuring Long Edge Output Scaling */

/**
 Expects a dictionary with two entries: the COProcessScaleUnitKey and COProcessScaleLengthKey. Specifies the
 length of the long edge when COProcessScaleMethod is set to COProcessScaleMethodLongEdge.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessLongEdgeScaleKey;

/** @name Configuring Short Edge Output Scaling */

/**
 Expects a dictionary with two entries: the COProcessScaleUnitKey and COProcessScaleLengthKey. Specifies the
 length of the short edge when COProcessScaleMethod is set to COProcessScaleMethodShortEdge.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessShortEdgeScaleKey;

/** @name Configuring Output Color Profile */

/**
 Expects a string. Specifies the path to the ICC profile used to process the images.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessOutputProfileKey;

/** @name Configuring Cropping */

/**
 Expects a type of value COPublishCropMethod. Controls how the crop is handeled.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessExportCropMethodKey;

/** @name Configuring Output Sharpening */

/**
 Expects a type of value COProcessSharpeningControl. Specifies if sharpening should be applied.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningControlKey;

/**
 Expects an unsingned integer between 0 and 1000. Screen/Print Sharpening: Specifies the sharpening amount.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningAmountKey;

/**
 Expects a float between 0 and 8. Screen/Print Sharpening: Specifies the sharpening threshold.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningThresholdKey;

/** @name Configuring Output Sharpening for Screen */

/**
 Expects a positive float between 0 and 2.5. Screen sharpening. Specifies the sharpening radius.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningRadiusKey;

/** @name Configuring Output Sharpening for Print */

/**
 Expects a positive float. Specifies the vieweing distance for print sharpening.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningViewingDistanceKey;

/**
 Expects a type of value COProcessSharpeningViewingDistanceUnit. Print Sharpening: Specifies
 the unit in which the viewing distance (COProcessSharpeningViewingDistanceKey) is provided.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessSharpeningViewingDistanceUnitKey;

/** @name Configuring Export of Metadata */

/**
 Expects a type of value COProcessMetadataIncludeKeywords. Determines whether keywords from
 keyword libraries should be exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeKeywordsMetadataKey;

/**
 Expects a BOOL. When set to true, the rating and color tags are exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeRatingMetadataKey;

/**
 Expects a BOOL. When set to true, copyright metadata is exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeCopyrightMetadataKey;

/**
 Expects a BOOL. When set to true, GPS coordinates are exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeGPSCoordinateMetadataKey;

/**
 Expects a BOOL. When set to true, camera metadata (EXIF) is exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeCameraMetadataKey;

/**
 Expects a BOOL. When set to true, all other metadata (IPTC) is exported as part of the processed image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeAllOtherMetadataKey;

/**
 Expects a BOOL. When set to true, annotations are rendered as part of the image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeAnnotationsKey;

/**
 Expects a BOOL. When set to true, the overlay configured in Capture One is rendered as part of the image.
 */
FOUNDATION_EXPORT COProcessSettingsKey const COProcessIncludeOverlayKey;

/**
 Represents the ICC profiles available for plugins.
 */
typedef NSString * COProcessICCProfile NS_STRING_ENUM;

/**
 Export as sRGB.
 */
FOUNDATION_EXPORT COProcessICCProfile const COProcessICCProfileSRGB;
/**
 Export as Adobe RGB.
 */
FOUNDATION_EXPORT COProcessICCProfile const COProcessICCProfileAdobeRGB;
/**
 Export as ProPhoto.
 */
FOUNDATION_EXPORT COProcessICCProfile const COProcessICCProfileProPhoto;

/**
 The various file formats Capture One can process images into.
 */
typedef NS_ENUM(NSUInteger, COProcessFileFormat) {
    /** Process files as JPEG. */
    COProcessFileFormatJPEG              = 1,
    /** Process files as TIFF. */
    COProcessFileFormatTIFF              = 2,
    /** Process files as JPEG XR. */
    COProcessFileFormatJPEGXR __attribute__((deprecated("JPEGXR is not supported starting from CaptureOnePlugins SDK 1.1.0","COProcessFileFormatJPEG"))) = 4,
    /** Process files as JPEG 2000.*/
    COProcessFileFormatJPEG2000 __attribute__((deprecated("JPEG2000 is not supported starting from CaptureOnePlugins SDK 1.1.0","COProcessFileFormatJPEG"))) = 5,
    /** Process files as PNG. */
    COProcessFileFormatPNG               = 6,
    /** Process files as DNG. */
    COProcessFileFormatDNG               = 7,
    /** Process files as PSD. */
    COProcessFileFormatPSD               = 8,
    /** Process files as JPEG QuickProof. */
    COProcessFileFormatJPEGQuickProof    = 100,
};

/**
 Describes whether Capture One keywords should be included in the the processed images.
 */
typedef NS_ENUM(NSInteger, COProcessMetadataIncludeKeywords) {
    /** Do not include keywords as metadata in the processed file. */
    COProcessMetadataIncludeKeywordsOff              = 0,
    /** Include keywords as metadata in the processed file. */
    COProcessMetadataIncludeKeywordsIncludeAll       = 1,
};

/**
 Describes the compression for TIFF files. Only relevant if the selected output
 format is COProcessFileFormatTIFF.
 */
typedef NS_ENUM(NSUInteger, COProcessTiffCompression) {
    /** Do not compress TIFF files. */
    COProcessTiffCompressionNone     = 0,
    /** Compress TIFF filess using LZW. */
    COProcessTiffCompressionLZW      = 1,
    /** Compress TIFF filess using Zip. */
    COProcessTiffCompressionZip      = 2,
};

/**
 Describes the output bit depth.
 */
typedef NS_ENUM(NSUInteger, COProcessBits) {
    /** Process with 8 bit. */
    COProcessBits8bit        = 8,
    /** Process with 16 bit. */
    COProcessBits16bit       = 16,
};

/**
 Describes the unit in which the output resolution is specified.
 */
typedef NS_ENUM(NSUInteger, COProcessResolutionUnit) {
    /** Output resolution is specified in inch. */
    COProcessResolutionUnitInch              = 1L,
    /** Output resolution is specified in millimeters. */
    COProcessResolutionUnitMillimeter        = 2L,
    /** Output resolution is specified in centimeters. */
    COProcessResolutionUnitCentimeter        = 3L,
};

/**
 Describes the method used to scale the image.
 */
typedef NS_ENUM(NSUInteger, COProcessScaleMethod ) {
    /** Resample processed image to a fixed percentage. Less than 100& will downsample,
     any value above will upsample using interpolation to add pixels. */
    COProcessScaleMethodFixed            = 0L,
    /** Process image to a fixed width. The height will be scaled automatically. */
    COProcessScaleMethodWidth            = 1L,
    /** Process image to a fixed height. The width will be scaled automatically. */
    COProcessScaleMethodHeight           = 2L,
    /** Process image so that one dimension is resized to fit within the dimensions
        specified, retaining the original aspect ratio, and irrespective of orientation. */
    COProcessScaleMethodWidthByHeight    = 4L,
    /** Process image so that the long edge has a fixed size. */
    COProcessScaleMethodLongEdge         = 5L,
    /** Process image so that the short edge has a fixed size. */
    COProcessScaleMethodShortEdge        = 6L,
};

/**
 Describes the unit in which the output size is specified.
 */
typedef NS_ENUM(NSUInteger, COProcessSizeUnit ) {
    /** Output resolution is specified in pixels. */
    COProcessSizeUnitPixel           = 0L,
    /** Output resolution is specified in inch. */
    COProcessSizeUnitInch            = 1L,
    /** Output resolution is specified in millimeters. */
    COProcessSizeUnitMillimeter      = 2L,
    /** Output resolution is specified in centimeters. */
    COProcessSizeUnitCentimeter      = 3L,
};

/**
 Describes how the crop is handeled.
 */
typedef NS_ENUM(int32_t, COPublishCropMethod) {
    /** Crop the image */
    COPublishCropMethodDefault      = 0,
    /** Ignore the crop */
    COPublishCropMethodIgnore       = 1,
    /** Process the full image and include the crop as path.
     Only available if the output format is set to COProcessFileFormatPSD. */
    COPublishCropMethodAsPath       = 2,
};

/**
 Describes the various sharpening strategies Capture One offers during export.
 */
typedef NS_ENUM(int32_t, COProcessSharpeningControl) {
    /**
     Do not apply additional output sharpening, only capture and creative sharpening.
     */
    COProcessSharpeningControlDisableOutputSharpening     = 2,
    /**
     After applying capture sharpening and creative sharpening, apply output sharpening
     for screen option to counteract any softening effects caused by downsizing images.
     */
    COProcessSharpeningControlScreen                      = 0,
    /**
     After applying capture sharpening and creative sharpening, apply output sharpening
     for print.
     */
    COProcessSharpeningControlPrint                       = 1,
    /**
     No sharpening is applied.
     */
    COProcessSharpeningControlDisabled                    = 4,
};

/**
 Describes the unit in which the output size is specified.
 */
typedef NS_ENUM(int32_t, COProcessSharpeningViewingDistanceUnit) {
    /** Viewing distance is specified in inch. */
    COProcessSharpeningViewingDistanceUnitInch           = 1,
    /** Viewing distance is specified in centimeters. */
    COProcessSharpeningViewingDistanceUnitCentimeter     = 2,
    /** Viewing distance is specified in percentage of the image's diagonal. */
    COProcessSharpeningViewingDistanceUnitPercentage     = 3
};
