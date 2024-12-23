import 'dart:io';

import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';

enum ImageProcessingMethod {
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
}

class ImageProcessor {
  static Image? _initialImage, _processedImage;
  static File? _initialImageFile, _processedImageFile;
  static int threshold = 32;

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
    final Directory dir = await getTemporaryDirectory();
    _handleImageProcessingMethod(method);
    if (_processedImage != null) {
      clearProcessedImages();
      _processedImageFile = await File(
              '${dir.path}processed_image_${DateTime.now().millisecondsSinceEpoch}.jpg')
          .writeAsBytes(encodePng(_processedImage!));
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
    }
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

  File? get initialImage => _initialImageFile;

  File? get processedImage => _processedImageFile;
}
