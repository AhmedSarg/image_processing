// import 'dart:math';
//
// //(1)
// // Function to calculate the Discrete Fourier Transform (DFT)
// List<Complex> fourierTransform(List<num> signal) {
//   int N = signal.length;
//   List<Complex> result = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     for (int n = 0; n < N; n++) {
//       double real = signal[n] * cos(2 * pi * k * n / N);
//       double imaginary = -signal[n] * sin(2 * pi * k * n / N);
//       result[k] = result[k] + Complex(real, imaginary);
//     }
//   }
//
//   return result;
// }
//
// // Complex number class to handle real and imaginary parts
// class Complex {
//   final double real;
//   final double imaginary;
//
//   Complex(this.real, this.imaginary);
//
//   Complex operator +(Complex other) {
//     return Complex(real + other.real, imaginary + other.imaginary);
//   }
//
//   @override
//   String toString() {
//     return '$real + ${imaginary}i';
//   }
// }
//
// void main() {
//   List<num> signal = [0, 1, 2, 3, 4, 5, 6, 7];
//   List<Complex> transformed = fourierTransform(signal);
//
//   print('Fourier Transform:');
//   for (var c in transformed) {
//     print(c);
//   }
// }
//
// /////////////////////////////////////////////////////////////
//
// //(2)
// // Function to calculate the Inverse Discrete Fourier Transform (IDFT)
// List<num> inverseFourierTransform(List<Complex> transformed) {
//   int N = transformed.length;
//   List<num> result = List.generate(N, (i) => 0.0);
//
//   for (int n = 0; n < N; n++) {
//     for (int k = 0; k < N; k++) {
//       double real = transformed[k].real * cos(2 * pi * k * n / N) -
//           transformed[k].imaginary * sin(2 * pi * k * n / N);
//       double imaginary = transformed[k].real * sin(2 * pi * k * n / N) +
//           transformed[k].imaginary * cos(2 * pi * k * n / N);
//       result[n] += (real + imaginary) / N;
//     }
//   }
//
//   return result;
// }
//
// List<Complex> idealLowPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency) {
//   int N = frequencyData.length;
//   double samplingFrequency = N.toDouble(); // Assuming normalized frequencies
//
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Apply the filter: keep frequencies below cutoffFrequency
//     if (frequency.abs() <= cutoffFrequency) {
//       filteredData[k] = frequencyData[k];
//     } else {
//       filteredData[k] = Complex(0, 0); // Zero out frequencies above the cutoff
//     }
//   }
//
//   return filteredData;
// }
//
// List<Complex> gaussianLowPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency) {
//   int N = frequencyData.length;
//   double samplingFrequency = N.toDouble(); // Assuming normalized frequencies
//
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Compute the Gaussian attenuation factor
//     double attenuation =
//         exp(-pow(frequency, 2) / (2 * pow(cutoffFrequency, 2)));
//
//     // Apply the filter
//     filteredData[k] = frequencyData[k] * attenuation;
//   }
//
//   return filteredData;
// }
//
// List<Complex> butterworthLowPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency, int order) {
//   int N = frequencyData.length;
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Compute the Butterworth attenuation factor
//     double attenuation =
//         1 / (1 + pow((frequency / cutoffFrequency).abs(), 2 * order));
//
//     // Apply the filter
//     filteredData[k] = frequencyData[k] * attenuation;
//   }
//
//   return filteredData;
// }
//
// List<Complex> idealHighPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency) {
//   int N = frequencyData.length;
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Apply the filter: keep frequencies above the cutoffFrequency
//     if (frequency.abs() > cutoffFrequency) {
//       filteredData[k] = frequencyData[k];
//     } else {
//       filteredData[k] = Complex(0, 0); // Zero out frequencies below the cutoff
//     }
//   }
//
//   return filteredData;
// }
//
// List<Complex> gaussianHighPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency) {
//   int N = frequencyData.length;
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Compute the Gaussian high-pass filter attenuation factor
//     double attenuation =
//         1 - exp(-pow(frequency, 2) / (2 * pow(cutoffFrequency, 2)));
//
//     // Apply the filter
//     filteredData[k] = frequencyData[k] * attenuation;
//   }
//
//   return filteredData;
// }
//
// List<Complex> butterworthHighPassFilter(
//     List<Complex> frequencyData, double cutoffFrequency, int order) {
//   int N = frequencyData.length;
//   List<Complex> filteredData = List.generate(N, (i) => Complex(0, 0));
//
//   for (int k = 0; k < N; k++) {
//     // Calculate the frequency associated with index k
//     double frequency = (k <= N / 2) ? k : k - N;
//
//     // Avoid division by zero for frequency == 0
//     if (frequency == 0) {
//       filteredData[k] = Complex(0, 0);
//     } else {
//       // Compute the Butterworth high-pass filter attenuation factor
//       double attenuation =
//           1 / (1 + pow((cutoffFrequency / frequency).abs(), 2 * order));
//
//       // Apply the filter
//       filteredData[k] = frequencyData[k] * attenuation;
//     }
//   }
//
//   return filteredData;
// }
