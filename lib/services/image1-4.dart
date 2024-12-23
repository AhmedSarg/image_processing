import 'dart:math';

import 'package:image/image.dart';

Image rgbToGray(Image image) {
  Image grayImage = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int grayValue = (0.299 * r + 0.587 * g + 0.114 * b).toInt();

      int grayPixel =
          (255 << 24) | (grayValue << 16) | (grayValue << 8) | grayValue;

      grayImage.setPixel(x, y, grayPixel as Color);
    }
  }

  return grayImage;
}

Image grayToBinary(Image grayImage, {int threshold = 128}) {
  Image binaryImage = Image(width: grayImage.width, height: grayImage.height);

  for (int y = 0; y < grayImage.height; y++) {
    for (int x = 0; x < grayImage.width; x++) {
      int pixel = grayImage.getPixel(x, y) as int;
      int grayValue = pixel & 0xFF;
      int binaryValue = grayValue >= threshold ? 255 : 0;
      int binaryPixel =
          (255 << 24) | (binaryValue << 16) | (binaryValue << 8) | binaryValue;
      binaryImage.setPixel(x, y, binaryPixel as Color);
    }
  }

  return binaryImage;
}

Image processImage(Image image, String op, int val) {
  Image processedImage = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int newR, newG, newB;

      if (op == '+') {
        newR = (r + val).clamp(0, 255);
        newG = (g + val).clamp(0, 255);
        newB = (b + val).clamp(0, 255);
      } else if (op == '*') {
        newR = (r * val).clamp(0, 255);
        newG = (g * val).clamp(0, 255);
        newB = (b * val).clamp(0, 255);
      } else if (op == '-') {
        newR = (r - val).clamp(0, 255);
        newG = (g - val).clamp(0, 255);
        newB = (b - val).clamp(0, 255);
      } else if (op == '/') {
        newR = (r ~/ val).clamp(0, 255);
        newG = (g ~/ val).clamp(0, 255);
        newB = (b ~/ val).clamp(0, 255);
      } else {
        throw ArgumentError("Unknown operation");
      }

      int newPixel = (255 << 24) | (newR << 16) | (newG << 8) | newB;
      processedImage.setPixel(x, y, newPixel as Color);
    }
  }

  return processedImage;
}

Image logImage(Image image, {double c = 1}) {
  Image logTransformedImage = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      double rLog = c * log(1 + r) / log(10);
      double gLog = c * log(1 + g) / log(10);
      double bLog = c * log(1 + b) / log(10);

      rLog = rLog.clamp(0, 255);
      gLog = gLog.clamp(0, 255);
      bLog = bLog.clamp(0, 255);

      int logPixel = (255 << 24) |
          ((rLog.toInt()) << 16) |
          ((gLog.toInt()) << 8) |
          (bLog.toInt());
      logTransformedImage.setPixel(x, y, logPixel as Color);
    }
  }

  return logTransformedImage;
}

Image inverseLogImage(Image image, {double c = 1}) {
  Image invLogTransformedImage =
      Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      double rInvLog = exp(r.toDouble());
      double gInvLog = exp(g.toDouble());
      double bInvLog = exp(b.toDouble());

      rInvLog = rInvLog.clamp(0, 255);
      gInvLog = gInvLog.clamp(0, 255);
      bInvLog = bInvLog.clamp(0, 255);

      int invLogPixel = (255 << 24) |
          ((rInvLog.toInt()) << 16) |
          ((gInvLog.toInt()) << 8) |
          (bInvLog.toInt());
      invLogTransformedImage.setPixel(x, y, invLogPixel as Color);
    }
  }

  return invLogTransformedImage;
}

Image gammaCorrection(Image image, {double gamma = 1.0}) {
  Image gammaImg = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int rGamma = (pow(r / 255.0, (gamma)) * 255).clamp(0, 255).toInt();
      int gGamma = (pow(g / 255.0, (gamma)) * 255).clamp(0, 255).toInt();
      int bGamma = (pow(b / 255.0, (gamma)) * 255).clamp(0, 255).toInt();

      int gammaPixel = (255 << 24) | (rGamma << 16) | (gGamma << 8) | bGamma;
      gammaImg.setPixel(x, y, gammaPixel as Color);
    }
  }

  return gammaImg;
}

Image negativeTransformation(Image image) {
  Image negImg = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int negR = 255 - r;
      int negG = 255 - g;
      int negB = 255 - b;

      int negPixel = (255 << 24) | (negR << 16) | (negG << 8) | negB;
      negImg.setPixel(x, y, negPixel as Color);
    }
  }

  return negImg;
}

List<int> calculateHistogram(Image grayImage) {
  List<int> histogram = List.filled(256, 0);

  for (int y = 0; y < grayImage.height; y++) {
    for (int x = 0; x < grayImage.width; x++) {
      int pixel = grayImage.getPixel(x, y) as int;

      int intensity = (pixel >> 16) & 0xFF;
      histogram[intensity]++;
    }
  }

  return histogram;
}

/*
var series = [
    charts.Series<int, int>(
      id: 'Histogram',
      domainFn: (int intensity, index) => index,
      measureFn: (int intensity, index) => intensity,
      data: List.generate(256, (index) => originalHistogram[index]),
    )
  ];
var chart = charts.LineChart(series, animate: true);
*/

Image contrastStretching(Image image) {
  int minVal = 255;
  int maxVal = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int intensity = (r + g + b) ~/ 3;

      minVal = min(minVal, intensity);
      maxVal = max(maxVal, intensity);
    }
  }

  Image stretchedImage = Image(width: image.width, height: image.height);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int intensity = (r + g + b) ~/ 3;

      int stretchedIntensity =
          ((intensity - minVal) / (maxVal - minVal) * 255).toInt();
      int stretchedPixel = (255 << 24) |
          (stretchedIntensity << 16) |
          (stretchedIntensity << 8) |
          stretchedIntensity;

      stretchedImage.setPixel(x, y, stretchedPixel as Color);
    }
  }

  return stretchedImage;
}

Image histogramEqualization(Image image) {
  List<int> histogram = calculateHistogram(image);
  int totalPixels = image.width * image.height;

  List<int> cdf = List.filled(256, 0);
  Image equalizedImage = Image(width: image.width, height: image.height);

  int cumulativeSum = 0;
  for (int i = 0; i < 256; i++) {
    cumulativeSum += histogram[i];
    cdf[i] = cumulativeSum;
  }

  int cdfMin = cdf.firstWhere((element) => element > 0);

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      int pixel = image.getPixel(x, y) as int;

      int r = (pixel >> 16) & 0xFF;
      int g = (pixel >> 8) & 0xFF;
      int b = pixel & 0xFF;

      int intensity = (r + g + b) ~/ 3;
      int equalizedIntensity =
          ((cdf[intensity] - cdfMin) / (totalPixels - cdfMin) * 255).toInt();
      int equalizedPixel = (255 << 24) |
          (equalizedIntensity << 16) |
          (equalizedIntensity << 8) |
          equalizedIntensity;

      equalizedImage.setPixel(x, y, equalizedPixel as Color);
    }
  }

  return equalizedImage;
}
