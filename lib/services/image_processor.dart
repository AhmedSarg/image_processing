import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

import 'complex_number.dart';

enum ImageProcessingMethod {
  rgb2Gray,
  rgb2Binary,
  gray2Binary,
  brightness,
  negative,
  contrast,
  histogram,
  gammaCorrection,
  histogramEqualization,
  convolution,
  blurringMean,
  blurringWeight,
  edgeDetectionPoint,
  edgeDetectionVertical,
  edgeDetectionHorizontal,
  edgeDetectionDiagonalLeft,
  edgeDetectionDiagonalRight,
  sharpeningPoint,
  sharpeningVertical,
  sharpeningHorizontal,
  sharpeningDiagonalLeft,
  sharpeningDiagonalRight,
  fourierTransform,
  fourierTransformInverse,
  frequencyDomainFilterIdealLowPass,
  frequencyDomainFilterGaussianLowPass,
  frequencyDomainFilterButterworthLowPass,
  frequencyDomainFilterIdealHighPass,
  frequencyDomainFilterGaussianHighPass,
  frequencyDomainFilterButterworthHighPass,
}

class ImageProcessor {
  static Image? _initialImage, _processedImage;
  static File? _initialImageFile, _processedImageFile;
  static const int threshold = 128;

  // static final Map<ImageProcessingMethod, File> _processedImages = {};

  loadImage(String imagePath) async {
    _initialImage = await decodeImageFile(imagePath);
    if (_initialImage != null) {
      await clearInitialImages();
      final Directory dir = await getTemporaryDirectory();
      _initialImageFile = await File(
              '${dir.path}initial_image_${DateTime.now().millisecondsSinceEpoch}.jpg')
          .writeAsBytes(encodePng(_initialImage!));
    }
  }

  processImage(ImageProcessingMethod method) async {
    _handleImageProcessingMethod(method);
    if (_processedImage != null) {
      clearProcessedImages();
      final Directory dir = await getTemporaryDirectory();
      _processedImageFile = await File(
              '${dir.path}processed_image_${DateTime.now().millisecondsSinceEpoch}.jpg')
          .writeAsBytes(encodePng(_processedImage!));
      return _processedImageFile;
    }
  }

  clear() async {
    _initialImage = null;
    _initialImageFile = null;
    _processedImage = null;
    _processedImageFile = null;
    await clearInitialImages();
    await clearProcessedImages();
  }

  clearInitialImages() async {
    final dir = await getTemporaryDirectory();
    for (var file in dir.listSync()) {
      if (file is File && file.path.contains('initial_image')) {
        await file.delete();
      }
    }
  }

  clearProcessedImages() async {
    final dir = await getTemporaryDirectory();
    for (var file in dir.listSync()) {
      if (file is File && file.path.contains('processed_image')) {
        await file.delete();
      }
    }
  }

  _handleImageProcessingMethod(ImageProcessingMethod method) {
    switch (method) {
      case ImageProcessingMethod.rgb2Gray:
        _processedImage = _rgbToGray();
        break;
      case ImageProcessingMethod.rgb2Binary:
        _processedImage = _rgbToBinary(threshold);
        break;
      case ImageProcessingMethod.gray2Binary:
        _processedImage = _grayToBinary(threshold);
        break;
      case ImageProcessingMethod.brightness:
        _processedImage = _brightness(64);
        break;
      case ImageProcessingMethod.negative:
        _processedImage = _negative();
        break;
      case ImageProcessingMethod.contrast:
        _processedImage = _contrast(1.5);
        break;
      case ImageProcessingMethod.histogram:
        _processedImage = _histogram();
        break;
      case ImageProcessingMethod.gammaCorrection:
        _processedImage = _gammaCorrection(0.5);
        break;
      case ImageProcessingMethod.histogramEqualization:
        _processedImage = _histogramEqualization();
        break;
      case ImageProcessingMethod.convolution:
        List<List<int>> sobelKernel = [
          [-1, 0, 1],
          [-2, 0, 2],
          [-1, 0, 1]
        ];
        _processedImage = _convolution(sobelKernel);
        break;
      case ImageProcessingMethod.blurringMean:
        _processedImage = _blurringMean();
        break;
      case ImageProcessingMethod.blurringWeight:
        _processedImage = _blurringWeight();
        break;
      case ImageProcessingMethod.edgeDetectionPoint:
        _processedImage = _edgeDetectionPoint(threshold);
        break;
      case ImageProcessingMethod.edgeDetectionVertical:
        _processedImage = _edgeDetectionVertical(threshold);
        break;
      case ImageProcessingMethod.edgeDetectionHorizontal:
        _processedImage = _edgeDetectionHorizontal(threshold);
        break;
      case ImageProcessingMethod.edgeDetectionDiagonalLeft:
        _processedImage = _edgeDetectionDiagonalLeft(threshold);
        break;
      case ImageProcessingMethod.edgeDetectionDiagonalRight:
        _processedImage = _edgeDetectionDiagonalRight(threshold);
        break;
      case ImageProcessingMethod.sharpeningPoint:
        _processedImage = _sharpeningPoint(threshold);
        break;
      case ImageProcessingMethod.sharpeningVertical:
        _processedImage = _sharpeningVertical(threshold);
        break;
      case ImageProcessingMethod.sharpeningHorizontal:
        _processedImage = _sharpeningHorizontal(threshold);
        break;
      case ImageProcessingMethod.sharpeningDiagonalLeft:
        _processedImage = _sharpeningDiagonalLeft(threshold);
        break;
      case ImageProcessingMethod.sharpeningDiagonalRight:
        _processedImage = _sharpeningDiagonalRight(threshold);
        break;
      case ImageProcessingMethod.fourierTransform:
        _processedImage = _fourierTransform();
        break;
      case ImageProcessingMethod.fourierTransformInverse:
        _processedImage = _inverseFFT(_computeFFT(_initialImage!));
        break;
      case ImageProcessingMethod.frequencyDomainFilterIdealLowPass:
        _processedImage = _idealLowPassFilter(50);
        break;
      case ImageProcessingMethod.frequencyDomainFilterGaussianLowPass:
        _processedImage = _gaussianLowPassFilter(20);
        break;
      case ImageProcessingMethod.frequencyDomainFilterButterworthLowPass:
        _processedImage = _butterworthLowPassFilter(30, 4);
        break;
      case ImageProcessingMethod.frequencyDomainFilterIdealHighPass:
        _processedImage = _idealHighPassFilter(50);
        break;
      case ImageProcessingMethod.frequencyDomainFilterGaussianHighPass:
        _processedImage = _gaussianHighPassFilter(20);
        break;
      case ImageProcessingMethod.frequencyDomainFilterButterworthHighPass:
        _processedImage = _butterworthHighPassFilter(40, 5);
        break;
    }
  }

  _rgbToGray() {
    Image grayImage = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        Pixel pixel = _initialImage!.getPixel(x, y);

        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        int grayValue = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
        ColorRgb8 grayPixel = ColorRgb8(grayValue, grayValue, grayValue);

        grayImage.setPixel(x, y, grayPixel);
      }
    }

    return grayImage;
  }

  _rgbToBinary(int threshold) {
    Image binaryImage = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        Pixel pixel = _initialImage!.getPixel(x, y);

        int grayValue =
            (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();
        int binaryValue = grayValue > threshold ? 255 : 0;
        ColorRgb8 binaryPixel = ColorRgb8(
          binaryValue,
          binaryValue,
          binaryValue,
        );

        binaryImage.setPixel(x, y, binaryPixel);
      }
    }
    return binaryImage;
  }

  _grayToBinary(int threshold) {
    // Create a new binary image
    Image binaryImage = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        // Get the current grayscale pixel
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Use the red channel (since it's grayscale, r = g = b)
        int grayValue = pixel.r.toInt();

        // Determine if the pixel is black or white based on the threshold
        int binaryValue = grayValue > threshold ? 255 : 0;

        // Create a binary pixel (black or white)
        ColorRgb8 binaryPixel =
            ColorRgb8(binaryValue, binaryValue, binaryValue);

        // Set the binary pixel in the new image
        binaryImage.setPixel(x, y, binaryPixel);
      }
    }

    return binaryImage;
  }

  _brightness(int adjustment) {
    // Create a new image for brightness adjustment
    Image brightnessAdjusted = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        // Get the current pixel
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Adjust brightness for each channel and clamp values between 0 and 255
        int newRed = (pixel.r + adjustment).clamp(0, 255).toInt();
        int newGreen = (pixel.g + adjustment).clamp(0, 255).toInt();
        int newBlue = (pixel.b + adjustment).clamp(0, 255).toInt();

        // Create a new pixel with adjusted brightness
        ColorRgb8 newPixel = ColorRgb8(newRed, newGreen, newBlue);

        // Set the adjusted pixel in the new image
        brightnessAdjusted.setPixel(x, y, newPixel);
      }
    }

    return brightnessAdjusted;
  }

  _negative() {
    // Create a new image for the negative
    Image negativeImage = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        // Get the current pixel
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Invert each color channel to get the negative
        int newRed = (255 - pixel.r).clamp(0, 255).toInt();
        int newGreen = (255 - pixel.g).clamp(0, 255).toInt();
        int newBlue = (255 - pixel.b).clamp(0, 255).toInt();

        // Create a new pixel with the inverted colors
        ColorRgb8 newPixel = ColorRgb8(newRed, newGreen, newBlue);

        // Set the negative pixel in the new image
        negativeImage.setPixel(x, y, newPixel);
      }
    }

    return negativeImage;
  }

  _contrast(double factor) {
    // Create a new image for contrast adjustment
    Image contrastAdjusted = Image(
      width: _initialImage!.width,
      height: _initialImage!.height,
    );

    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        // Get the current pixel
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Adjust contrast for each channel
        int newRed = ((factor * (pixel.r - 128)) + 128).clamp(0, 255).toInt();
        int newGreen = ((factor * (pixel.g - 128)) + 128).clamp(0, 255).toInt();
        int newBlue = ((factor * (pixel.b - 128)) + 128).clamp(0, 255).toInt();

        // Create a new pixel with adjusted contrast
        ColorRgb8 newPixel = ColorRgb8(newRed, newGreen, newBlue);

        // Set the adjusted pixel in the new image
        contrastAdjusted.setPixel(x, y, newPixel);
      }
    }

    return contrastAdjusted;
  }

  _histogram() {
    // Initialize arrays for R, G, and B histograms
    List<int> redHistogram = List.filled(256, 0);
    List<int> greenHistogram = List.filled(256, 0);
    List<int> blueHistogram = List.filled(256, 0);

    // Calculate the histograms
    for (int y = 0; y < _initialImage!.height; y++) {
      for (int x = 0; x < _initialImage!.width; x++) {
        // Get the current pixel
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Increment the counts for each channel
        redHistogram[pixel.r.toInt()]++;
        greenHistogram[pixel.g.toInt()]++;
        blueHistogram[pixel.b.toInt()]++;
      }
    }

    Map<String, List<int>> histogram = {
      'red': redHistogram,
      'green': greenHistogram,
      'blue': blueHistogram,
    };

    // Create a blank image for the histogram visualization
    int histogramWidth = 256; // Fixed width for intensity values
    int histogramHeight = _initialImage!.height; // Can be adjusted
    Image histogramImage = Image(
      width: histogramWidth,
      height: histogramHeight,
    );

    // Get the maximum value for normalization
    int maxValue =
        histogram.values.expand((list) => list).reduce((a, b) => a > b ? a : b);

    // Draw histograms for each channel
    for (int intensity = 0; intensity < 256; intensity++) {
      // Scale bar heights for each channel
      int redHeight =
          ((histogram['red']![intensity] / maxValue) * histogramHeight).toInt();
      int greenHeight =
          ((histogram['green']![intensity] / maxValue) * histogramHeight)
              .toInt();
      int blueHeight =
          ((histogram['blue']![intensity] / maxValue) * histogramHeight)
              .toInt();

      // Draw red bar
      for (int y = 0; y < redHeight; y++) {
        histogramImage.setPixel(intensity, histogramHeight - y - 1,
            ColorRgb8(255, 0, 0)); // Red bars
      }

      // Draw green bar
      for (int y = 0; y < greenHeight; y++) {
        histogramImage.setPixel(intensity, histogramHeight - y - 1,
            ColorRgb8(0, 255, 0)); // Green bars
      }

      // Draw blue bar
      for (int y = 0; y < blueHeight; y++) {
        histogramImage.setPixel(intensity, histogramHeight - y - 1,
            ColorRgb8(0, 0, 255)); // Blue bars
      }
    }

    return histogramImage;
  }

  _gammaCorrection(double gamma) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Precompute the gamma correction lookup table for performance
    List<int> gammaLookupTable = List.generate(256, (i) {
      return (255 * pow(i / 255, 1 / gamma)).clamp(0, 255).toInt();
    });

    // Loop over the pixels and apply gamma correction
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Pixel pixel = _initialImage!.getPixel(x, y);

        int correctedR = gammaLookupTable[pixel.r.toInt()];
        int correctedG = gammaLookupTable[pixel.g.toInt()];
        int correctedB = gammaLookupTable[pixel.b.toInt()];

        newImage.setPixel(x, y, ColorRgb8(correctedR, correctedG, correctedB));
      }
    }

    return newImage;
  }

  _histogramEqualization() {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Step 1: Compute the histogram of the grayscale intensities
    List<int> histogram = List.filled(256, 0);
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Pixel pixel = _initialImage!.getPixel(x, y);
        int gray = ((pixel.r.toInt() + pixel.g.toInt() + pixel.b.toInt()) ~/ 3);
        histogram[gray]++;
      }
    }

    // Step 2: Compute the cumulative distribution function (CDF)
    List<int> cdf = List.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // Step 3: Normalize the CDF to map the values to the range [0, 255]
    int cdfMin =
        cdf.firstWhere((value) => value > 0); // Find the first non-zero value
    int totalPixels = width * height;
    List<int> equalizationMap = List.generate(256, (i) {
      return (((cdf[i] - cdfMin) / (totalPixels - cdfMin)) * 255).round();
    });

    // Step 4: Apply the equalization map to each pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Pixel pixel = _initialImage!.getPixel(x, y);

        // Convert to grayscale intensity
        int gray = ((pixel.r.toInt() + pixel.g.toInt() + pixel.b.toInt()) ~/ 3);

        // Apply the equalization map
        int newGray = equalizationMap[gray];

        // Set the new pixel as grayscale (same value for R, G, and B)
        newImage.setPixel(x, y, ColorRgb8(newGray, newGray, newGray));
      }
    }

    return newImage;
  }

  _convolution(List<List<int>> kernel, {int divisor = 1, int offset = 0}) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Compute the kernel dimensions
    int kernelWidth = kernel[0].length;
    int kernelHeight = kernel.length;

    // Assume kernel dimensions are odd (e.g., 3x3, 5x5)
    int kCenterX = kernelWidth ~/ 2;
    int kCenterY = kernelHeight ~/ 2;

    // Loop over each pixel in the image
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int r = 0, g = 0, b = 0;

        // Apply the kernel
        for (int ky = 0; ky < kernelHeight; ky++) {
          for (int kx = 0; kx < kernelWidth; kx++) {
            int px = x + kx - kCenterX;
            int py = y + ky - kCenterY;

            // Ensure the coordinates are within bounds
            if (px >= 0 && px < width && py >= 0 && py < height) {
              Pixel pixel = _initialImage!.getPixel(px, py);
              int weight = kernel[ky][kx];

              r += pixel.r.toInt() * weight;
              g += pixel.g.toInt() * weight;
              b += pixel.b.toInt() * weight;
            }
          }
        }

        // Normalize by divisor and add offset, then clamp values
        int newR = ((r ~/ divisor) + offset).clamp(0, 255);
        int newG = ((g ~/ divisor) + offset).clamp(0, 255);
        int newB = ((b ~/ divisor) + offset).clamp(0, 255);

        // Set the new pixel value
        newImage.setPixel(x, y, ColorRgb8(newR, newG, newB));
      }
    }

    return newImage;
  }

  _blurringMean() {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a copy of the image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Define the size of the kernel (3x3 for a basic mean filter)
    int kernelSize = 3;
    int offset = kernelSize ~/ 2;

    // Loop over the pixels and apply the mean filter
    for (int y = offset; y < height - offset; y++) {
      for (int x = offset; x < width - offset; x++) {
        int r = 0, g = 0, b = 0;

        // Calculate the average color values within the kernel
        for (int ky = -offset; ky <= offset; ky++) {
          for (int kx = -offset; kx <= offset; kx++) {
            Pixel pixel = _initialImage!.getPixel(x + kx, y + ky);
            r += pixel.r.toInt();
            g += pixel.g.toInt();
            b += pixel.b.toInt();
          }
        }

        // Set the new pixel value as the average
        int avgR = r ~/ (kernelSize * kernelSize);
        int avgG = g ~/ (kernelSize * kernelSize);
        int avgB = b ~/ (kernelSize * kernelSize);
        newImage.setPixel(x, y, ColorRgb8(avgR, avgG, avgB));
      }
    }

    return newImage;
  }

  _blurringWeight() {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a copy of the _initialImage! to store the processed result
    Image newImage = Image(width: width, height: height);

    // Define the weighted kernel (example: 3x3 Gaussian-like kernel)
    List<List<int>> kernel = [
      [1, 2, 1],
      [2, 4, 2],
      [1, 2, 1]
    ];

    int kernelSum =
        kernel.fold(0, (sum, row) => sum + row.fold(0, (s, v) => s + v));

    // Loop over the pixels and apply the weighted filter
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int r = 0, g = 0, b = 0;

        // Apply the kernel to the surrounding pixels
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            Pixel pixel = _initialImage!.getPixel(x + kx, y + ky);
            int weight = kernel[ky + 1][kx + 1];

            r += pixel.r.toInt() * weight;
            g += pixel.g.toInt() * weight;
            b += pixel.b.toInt() * weight;
          }
        }

        // Normalize by the sum of the kernel
        int avgR = r ~/ kernelSum;
        int avgG = g ~/ kernelSum;
        int avgB = b ~/ kernelSum;
        newImage.setPixel(x, y, ColorRgb8(avgR, avgG, avgB));
      }
    }

    return newImage;
  }

  _edgeDetectionPoint(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels and check the intensity difference between adjacent pixels
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get pixel intensity (grayscale value) of the current pixel
        Pixel pixel = _initialImage!.getPixel(x, y);
        int currentPixelIntensity = (pixel.r + pixel.g + pixel.b) ~/ 3;

        // Get pixel intensities of the neighboring pixels (right, left, up, down)
        Pixel pixelRight = _initialImage!.getPixel(x + 1, y);
        Pixel pixelLeft = _initialImage!.getPixel(x - 1, y);
        Pixel pixelUp = _initialImage!.getPixel(x, y - 1);
        Pixel pixelDown = _initialImage!.getPixel(x, y + 1);

        int rightIntensity = (pixelRight.r + pixelRight.g + pixelRight.b) ~/ 3;
        int leftIntensity = (pixelLeft.r + pixelLeft.g + pixelLeft.b) ~/ 3;
        int upIntensity = (pixelUp.r + pixelUp.g + pixelUp.b) ~/ 3;
        int downIntensity = (pixelDown.r + pixelDown.g + pixelDown.b) ~/ 3;

        // Calculate the differences in intensity between the current pixel and its neighbors
        int intensityDiff = (currentPixelIntensity - rightIntensity).abs() +
            (currentPixelIntensity - leftIntensity).abs() +
            (currentPixelIntensity - upIntensity).abs() +
            (currentPixelIntensity - downIntensity).abs();

        // If the intensity difference exceeds the threshold, set the pixel to white (edge)
        if (intensityDiff > threshold) {
          newImage.setPixel(x, y, ColorRgb8(255, 255, 255)); // White for edge
        } else {
          newImage.setPixel(x, y, ColorRgb8(0, 0, 0)); // Black for non-edge
        }
      }
    }

    return newImage;
  }

  _edgeDetectionVertical(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 0; y < height; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel intensity
        Pixel currentPixel = _initialImage!.getPixel(x, y);
        int currentIntensity =
            (currentPixel.r + currentPixel.g + currentPixel.b) ~/ 3;

        // Get the left and right neighbor pixels' intensities
        Pixel leftPixel = _initialImage!.getPixel(x - 1, y);
        Pixel rightPixel = _initialImage!.getPixel(x + 1, y);

        int leftIntensity = (leftPixel.r + leftPixel.g + leftPixel.b) ~/ 3;
        int rightIntensity = (rightPixel.r + rightPixel.g + rightPixel.b) ~/ 3;

        // Calculate the intensity difference for vertical edges
        int intensityDiff = (currentIntensity - leftIntensity).abs() +
            (currentIntensity - rightIntensity).abs();

        // Set the pixel to white if the intensity difference exceeds the threshold
        if (intensityDiff > threshold) {
          newImage.setPixel(x, y, ColorRgb8(255, 255, 255)); // White for edge
        } else {
          newImage.setPixel(x, y, ColorRgb8(0, 0, 0)); // Black for non-edge
        }
      }
    }

    return newImage;
  }

  _edgeDetectionHorizontal(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 0; x < width; x++) {
        // Get the current pixel intensity
        Pixel currentPixel = _initialImage!.getPixel(x, y);
        int currentIntensity =
            (currentPixel.r + currentPixel.g + currentPixel.b) ~/ 3;

        // Get the top and bottom neighbor pixels' intensities
        Pixel topPixel = _initialImage!.getPixel(x, y - 1);
        Pixel bottomPixel = _initialImage!.getPixel(x, y + 1);

        int topIntensity = (topPixel.r + topPixel.g + topPixel.b) ~/ 3;
        int bottomIntensity =
            (bottomPixel.r + bottomPixel.g + bottomPixel.b) ~/ 3;

        // Calculate the intensity difference for horizontal edges
        int intensityDiff = (currentIntensity - topIntensity).abs() +
            (currentIntensity - bottomIntensity).abs();

        // Set the pixel to white if the intensity difference exceeds the threshold
        if (intensityDiff > threshold) {
          newImage.setPixel(x, y, ColorRgb8(255, 255, 255)); // White for edge
        } else {
          newImage.setPixel(x, y, ColorRgb8(0, 0, 0)); // Black for non-edge
        }
      }
    }

    return newImage;
  }

  _edgeDetectionDiagonalLeft(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel intensity
        Pixel currentPixel = _initialImage!.getPixel(x, y);
        int currentIntensity =
            (currentPixel.r + currentPixel.g + currentPixel.b) ~/ 3;

        // Get the top-left and bottom-right neighbor pixels' intensities
        Pixel topLeftPixel = _initialImage!.getPixel(x - 1, y - 1);
        Pixel bottomRightPixel = _initialImage!.getPixel(x + 1, y + 1);

        int topLeftIntensity =
            (topLeftPixel.r + topLeftPixel.g + topLeftPixel.b) ~/ 3;
        int bottomRightIntensity =
            (bottomRightPixel.r + bottomRightPixel.g + bottomRightPixel.b) ~/ 3;

        // Calculate the intensity difference for diagonal left edges
        int intensityDiff = (currentIntensity - topLeftIntensity).abs() +
            (currentIntensity - bottomRightIntensity).abs();

        // Set the pixel to white if the intensity difference exceeds the threshold
        if (intensityDiff > threshold) {
          newImage.setPixel(x, y, ColorRgb8(255, 255, 255)); // White for edge
        } else {
          newImage.setPixel(x, y, ColorRgb8(0, 0, 0)); // Black for non-edge
        }
      }
    }

    return newImage;
  }

  _edgeDetectionDiagonalRight(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel intensity
        Pixel currentPixel = _initialImage!.getPixel(x, y);
        int currentIntensity =
            (currentPixel.r + currentPixel.g + currentPixel.b) ~/ 3;

        // Get the top-right and bottom-left neighbor pixels' intensities
        Pixel topRightPixel = _initialImage!.getPixel(x + 1, y - 1);
        Pixel bottomLeftPixel = _initialImage!.getPixel(x - 1, y + 1);

        int topRightIntensity =
            (topRightPixel.r + topRightPixel.g + topRightPixel.b) ~/ 3;
        int bottomLeftIntensity =
            (bottomLeftPixel.r + bottomLeftPixel.g + bottomLeftPixel.b) ~/ 3;

        // Calculate the intensity difference for diagonal right edges
        int intensityDiff = (currentIntensity - topRightIntensity).abs() +
            (currentIntensity - bottomLeftIntensity).abs();

        // Set the pixel to white if the intensity difference exceeds the threshold
        if (intensityDiff > threshold) {
          newImage.setPixel(x, y, ColorRgb8(255, 255, 255)); // White for edge
        } else {
          newImage.setPixel(x, y, ColorRgb8(0, 0, 0)); // Black for non-edge
        }
      }
    }

    return newImage;
  }

  _sharpeningPoint(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel
        Pixel currentPixel = _initialImage!.getPixel(x, y);

        // Get the neighboring pixels
        Pixel leftPixel = _initialImage!.getPixel(x - 1, y);
        Pixel rightPixel = _initialImage!.getPixel(x + 1, y);
        Pixel topPixel = _initialImage!.getPixel(x, y - 1);
        Pixel bottomPixel = _initialImage!.getPixel(x, y + 1);

        // Calculate the average of neighboring intensities for each channel
        int avgRed =
            (leftPixel.r + rightPixel.r + topPixel.r + bottomPixel.r) ~/ 4;
        int avgGreen =
            (leftPixel.g + rightPixel.g + topPixel.g + bottomPixel.g) ~/ 4;
        int avgBlue =
            (leftPixel.b + rightPixel.b + topPixel.b + bottomPixel.b) ~/ 4;

        // Sharpen the pixel for each channel
        int sharpenedRed = currentPixel.r.toInt() +
            threshold * (currentPixel.r - avgRed).toInt();
        int sharpenedGreen = currentPixel.g.toInt() +
            threshold * (currentPixel.g - avgGreen).toInt();
        int sharpenedBlue = currentPixel.b.toInt() +
            threshold * (currentPixel.b - avgBlue).toInt();

        // Clamp the values to the valid range [0, 255]
        sharpenedRed = sharpenedRed.clamp(0, 255);
        sharpenedGreen = sharpenedGreen.clamp(0, 255);
        sharpenedBlue = sharpenedBlue.clamp(0, 255);

        // Set the sharpened pixel in the new image
        newImage.setPixel(
          x,
          y,
          ColorRgb8(sharpenedRed, sharpenedGreen, sharpenedBlue),
        );
      }
    }

    return newImage;
  }

  _sharpeningVertical(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the top and bottom borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 0; x < width; x++) {
        // Get the current pixel
        Pixel currentPixel = _initialImage!.getPixel(x, y);

        // Get the neighboring pixels above and below
        Pixel topPixel = _initialImage!.getPixel(x, y - 1);
        Pixel bottomPixel = _initialImage!.getPixel(x, y + 1);

        // Calculate the average of vertical neighbors for each channel
        int avgRed = (topPixel.r + bottomPixel.r) ~/ 2;
        int avgGreen = (topPixel.g + bottomPixel.g) ~/ 2;
        int avgBlue = (topPixel.b + bottomPixel.b) ~/ 2;

        // Sharpen the pixel for each channel
        int sharpenedRed = currentPixel.r.toInt() +
            threshold * (currentPixel.r - avgRed).toInt();
        int sharpenedGreen = currentPixel.g.toInt() +
            threshold * (currentPixel.g - avgGreen).toInt();
        int sharpenedBlue = currentPixel.b.toInt() +
            threshold * (currentPixel.b - avgBlue).toInt();

        // Clamp the values to the valid range [0, 255]
        sharpenedRed = sharpenedRed.clamp(0, 255);
        sharpenedGreen = sharpenedGreen.clamp(0, 255);
        sharpenedBlue = sharpenedBlue.clamp(0, 255);

        // Set the sharpened pixel in the new image
        newImage.setPixel(
          x,
          y,
          ColorRgb8(sharpenedRed, sharpenedGreen, sharpenedBlue),
        );
      }
    }

    return newImage;
  }

  _sharpeningHorizontal(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the left and right borders
    for (int y = 0; y < height; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel
        Pixel currentPixel = _initialImage!.getPixel(x, y);

        // Get the neighboring pixels to the left and right
        Pixel leftPixel = _initialImage!.getPixel(x - 1, y);
        Pixel rightPixel = _initialImage!.getPixel(x + 1, y);

        // Calculate the average of horizontal neighbors for each channel
        int avgRed = (leftPixel.r + rightPixel.r) ~/ 2;
        int avgGreen = (leftPixel.g + rightPixel.g) ~/ 2;
        int avgBlue = (leftPixel.b + rightPixel.b) ~/ 2;

        // Sharpen the pixel for each channel
        int sharpenedRed = currentPixel.r.toInt() +
            threshold * (currentPixel.r - avgRed).toInt();
        int sharpenedGreen = currentPixel.g.toInt() +
            threshold * (currentPixel.g - avgGreen).toInt();
        int sharpenedBlue = currentPixel.b.toInt() +
            threshold * (currentPixel.b - avgBlue).toInt();

        // Clamp the values to the valid range [0, 255]
        sharpenedRed = sharpenedRed.clamp(0, 255);
        sharpenedGreen = sharpenedGreen.clamp(0, 255);
        sharpenedBlue = sharpenedBlue.clamp(0, 255);

        // Set the sharpened pixel in the new image
        newImage.setPixel(
          x,
          y,
          ColorRgb8(sharpenedRed, sharpenedGreen, sharpenedBlue),
        );
      }
    }

    return newImage;
  }

  _sharpeningDiagonalLeft(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        // Get the current pixel
        Pixel currentPixel = _initialImage!.getPixel(x, y);

        // Get the diagonal neighbors (top-left and bottom-right)
        Pixel topLeftPixel = _initialImage!.getPixel(x - 1, y - 1);
        Pixel bottomRightPixel = _initialImage!.getPixel(x + 1, y + 1);

        // Calculate the average of diagonal neighbors for each channel
        int avgRed = (topLeftPixel.r + bottomRightPixel.r) ~/ 2;
        int avgGreen = (topLeftPixel.g + bottomRightPixel.g) ~/ 2;
        int avgBlue = (topLeftPixel.b + bottomRightPixel.b) ~/ 2;

        // Sharpen the pixel for each channel
        int sharpenedRed = currentPixel.r.toInt() +
            threshold * (currentPixel.r - avgRed).toInt();
        int sharpenedGreen = currentPixel.g.toInt() +
            threshold * (currentPixel.g - avgGreen).toInt();
        int sharpenedBlue = currentPixel.b.toInt() +
            threshold * (currentPixel.b - avgBlue).toInt();

        // Clamp the values to the valid range [0, 255]
        sharpenedRed = sharpenedRed.clamp(0, 255);
        sharpenedGreen = sharpenedGreen.clamp(0, 255);
        sharpenedBlue = sharpenedBlue.clamp(0, 255);

        // Set the sharpened pixel in the new image
        newImage.setPixel(
          x,
          y,
          ColorRgb8(sharpenedRed, sharpenedGreen, sharpenedBlue),
        );
      }
    }

    return newImage;
  }

  _sharpeningDiagonalRight(int threshold) {
    int width = _initialImage!.width;
    int height = _initialImage!.height;

    // Create a new image to store the processed result
    Image newImage = Image(width: width, height: height);

    // Loop over the pixels, skipping the borders
    for (int y = 1; y < height - 1; y++) {
      for (int x = 0; x < width - 1; x++) {
        // Get the current pixel
        Pixel currentPixel = _initialImage!.getPixel(x, y);

        // Get the diagonal neighbors (top-right and bottom-left)
        Pixel topRightPixel = _initialImage!.getPixel(x + 1, y - 1);
        Pixel bottomLeftPixel = _initialImage!.getPixel(x - 1, y + 1);

        // Calculate the average of diagonal neighbors for each channel
        int avgRed = (topRightPixel.r + bottomLeftPixel.r) ~/ 2;
        int avgGreen = (topRightPixel.g + bottomLeftPixel.g) ~/ 2;
        int avgBlue = (topRightPixel.b + bottomLeftPixel.b) ~/ 2;

        // Sharpen the pixel for each channel
        int sharpenedRed = currentPixel.r.toInt() +
            threshold * (currentPixel.r - avgRed).toInt();
        int sharpenedGreen = currentPixel.g.toInt() +
            threshold * (currentPixel.g - avgGreen).toInt();
        int sharpenedBlue = currentPixel.b.toInt() +
            threshold * (currentPixel.b - avgBlue).toInt();

        // Clamp the values to the valid range [0, 255]
        sharpenedRed = sharpenedRed.clamp(0, 255);
        sharpenedGreen = sharpenedGreen.clamp(0, 255);
        sharpenedBlue = sharpenedBlue.clamp(0, 255);

        // Set the sharpened pixel in the new image
        newImage.setPixel(
          x,
          y,
          ColorRgb8(sharpenedRed, sharpenedGreen, sharpenedBlue),
        );
      }
    }

    return newImage;
  }

  List<ComplexNumber> _fft(List<ComplexNumber> input) {
    int n = input.length;

    if (n == 1) return [input[0]];

    List<ComplexNumber> even = [for (int i = 0; i < n; i += 2) input[i]];
    List<ComplexNumber> odd = [for (int i = 1; i < n; i += 2) input[i]];

    List<ComplexNumber> fftEven = _fft(even);
    List<ComplexNumber> fftOdd = _fft(odd);

    List<ComplexNumber> output = List.filled(n, ComplexNumber(0, 0));
    for (int k = 0; k < n ~/ 2; k++) {
      double angle = -2 * pi * k / n;
      ComplexNumber twiddle = ComplexNumber(cos(angle), sin(angle)) * fftOdd[k];

      output[k] = fftEven[k] + twiddle;
      output[k + n ~/ 2] = fftEven[k] - twiddle;
    }

    return output;
  }

  List<ComplexNumber> _ifft(List<ComplexNumber> input) {
    int n = input.length;

    if (n == 1) return [input[0]];

    List<ComplexNumber> even = [for (int i = 0; i < n; i += 2) input[i]];
    List<ComplexNumber> odd = [for (int i = 1; i < n; i += 2) input[i]];

    List<ComplexNumber> ifftEven = _ifft(even);
    List<ComplexNumber> ifftOdd = _ifft(odd);

    List<ComplexNumber> output = List.filled(n, ComplexNumber(0, 0));
    for (int k = 0; k < n ~/ 2; k++) {
      double angle = 2 * pi * k / n;
      ComplexNumber twiddle =
          ComplexNumber(cos(angle), sin(angle)) * ifftOdd[k];

      output[k] = ifftEven[k] + twiddle;
      output[k + n ~/ 2] = ifftEven[k] - twiddle;
    }

    for (int i = 0; i < n; i++) {
      output[i] = output[i] / n;
    }

    return output;
  }

  List<List<ComplexNumber>> _fft2D(List<List<int>> image) {
    int width = image[0].length;
    int height = image.length;

    List<List<ComplexNumber>> rowTransformed = List.generate(
      height,
      (y) => _fft(
          image[y].map((value) => ComplexNumber(value.toDouble(), 0)).toList()),
    );

    List<List<ComplexNumber>> transposed = List.generate(
      width,
      (x) => [for (int y = 0; y < height; y++) rowTransformed[y][x]],
    );

    List<List<ComplexNumber>> columnTransformed = List.generate(
      width,
      (x) => _fft(transposed[x]),
    );

    return List.generate(
      height,
      (y) => [for (int x = 0; x < width; x++) columnTransformed[x][y]],
    );
  }

  List<List<ComplexNumber>> _ifft2D(List<List<ComplexNumber>> frequencyDomain) {
    int width = frequencyDomain[0].length;
    int height = frequencyDomain.length;

    List<List<ComplexNumber>> rowTransformed = List.generate(
      height,
      (y) => _ifft(frequencyDomain[y]),
    );

    List<List<ComplexNumber>> transposed = List.generate(
      width,
      (x) => [for (int y = 0; y < height; y++) rowTransformed[y][x]],
    );

    List<List<ComplexNumber>> columnTransformed = List.generate(
      width,
      (x) => _ifft(transposed[x]),
    );

    return List.generate(
      height,
      (y) => [for (int x = 0; x < width; x++) columnTransformed[x][y]],
    );
  }

  List<List<ComplexNumber>> _computeFFT(Image image) {
    int width = image.width;
    int height = image.height;

    // Convert the image to a grayscale intensity matrix
    List<List<int>> intensityMatrix = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          Pixel pixel = image.getPixel(x, y);
          return ((pixel.r.toInt() + pixel.g.toInt() + pixel.b.toInt()) ~/ 3);
        },
      ),
    );

    // Apply 2D FFT
    return _fft2D(intensityMatrix);
  }

  List<List<ComplexNumber>> _centerFrequencyDomain(
      List<List<ComplexNumber>> frequencyDomain) {
    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;

    List<List<ComplexNumber>> centered = List.generate(
      height,
      (_) => List.generate(width, (_) => ComplexNumber(0, 0)),
    );

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int newX = (x + width ~/ 2) % width;
        int newY = (y + height ~/ 2) % height;

        centered[newY][newX] = frequencyDomain[y][x];
      }
    }

    return centered;
  }

  _fourierTransform() {
    Image inputImage = _rgbToGray();
    int width = inputImage.width;
    int height = inputImage.height;

    List<List<int>> intensityMatrix = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          Pixel pixel = inputImage.getPixel(x, y);
          return ((pixel.r.toInt() + pixel.g.toInt() + pixel.b.toInt()) ~/ 3);
        },
      ),
    );

    List<List<ComplexNumber>> frequencyDomain = _fft2D(intensityMatrix);
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    Image newImage = Image(width: width, height: height);

    double maxMagnitude = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double magnitude = frequencyDomain[y][x].magnitude;
        maxMagnitude = max(maxMagnitude, magnitude);
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double magnitude = frequencyDomain[y][x].magnitude;
        double scaledMagnitude = log(1 + magnitude) / log(1 + maxMagnitude);
        int intensity = (scaledMagnitude * 255).clamp(0, 255).toInt();
        newImage.setPixel(x, y, ColorRgb8(intensity, intensity, intensity));
      }
    }

    return newImage;
  }

  Image _inverseFFT(List<List<ComplexNumber>> frequencyDomain) {
    // Perform IFFT to get the spatial domain
    List<List<ComplexNumber>> spatialDomain = _ifft2D(frequencyDomain);

    int height = spatialDomain.length;
    int width = spatialDomain[0].length;
    Image newImage = Image(width: width, height: height);

    // Normalize pixel intensities
    double minIntensity = double.infinity;
    double maxIntensity = double.negativeInfinity;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double value = spatialDomain[y][x].real;
        if (value < minIntensity) minIntensity = value;
        if (value > maxIntensity) maxIntensity = value;
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        double value = spatialDomain[y][x].real;

        // Normalize to [0, 1]
        double normalized =
            (value - minIntensity) / (maxIntensity - minIntensity);

        // Scale to [0, 255]
        int intensity = (normalized * 255).clamp(0, 255).toInt();

        newImage.setPixel(x, y, ColorRgb8(intensity, intensity, intensity));
      }
    }

    return newImage;
  }

  _idealLowPassFilter(double radius) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
        return (distance <= radius)
            ? frequencyDomain[y][x]
            : ComplexNumber(0, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  _idealHighPassFilter(double radius) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distance = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2));
        return (distance > radius)
            ? frequencyDomain[y][x]
            : ComplexNumber(0, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  _gaussianLowPassFilter(double sigma) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distanceSquared =
            pow(x - centerX, 2) + pow(y - centerY, 2).toDouble();
        double filterValue = exp(-distanceSquared / (2 * sigma * sigma));
        return frequencyDomain[y][x] * ComplexNumber(filterValue, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  _gaussianHighPassFilter(double sigma) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distanceSquared =
            pow(x - centerX, 2) + pow(y - centerY, 2).toDouble();
        double filterValue = 1 - exp(-distanceSquared / (2 * sigma * sigma));
        return frequencyDomain[y][x] * ComplexNumber(filterValue, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  _butterworthLowPassFilter(double radius, int n) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distanceSquared =
            pow(x - centerX, 2) + pow(y - centerY, 2).toDouble();
        double filterValue =
            1 / (1 + pow(sqrt(distanceSquared) / radius, 2 * n));
        return frequencyDomain[y][x] * ComplexNumber(filterValue, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  _butterworthHighPassFilter(double radius, int n) {
    List<List<ComplexNumber>> frequencyDomain = _computeFFT(_rgbToGray());
    frequencyDomain = _centerFrequencyDomain(frequencyDomain);

    int height = frequencyDomain.length;
    int width = frequencyDomain[0].length;
    int centerX = width ~/ 2;
    int centerY = height ~/ 2;

    List<List<ComplexNumber>> filteredFrequencyDomain =
        List.generate(height, (y) {
      return List.generate(width, (x) {
        double distanceSquared =
            pow(x - centerX, 2) + pow(y - centerY, 2).toDouble();
        double filterValue =
            1 / (1 + pow(radius / sqrt(distanceSquared), 2 * n));
        return frequencyDomain[y][x] * ComplexNumber(filterValue, 0);
      });
    });

    filteredFrequencyDomain = _centerFrequencyDomain(filteredFrequencyDomain);
    return _inverseFFT(filteredFrequencyDomain);
  }

  File? get initialImage => _initialImageFile;

  File? get processedImage => _processedImageFile;
}
