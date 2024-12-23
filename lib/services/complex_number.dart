import 'dart:math';

class ComplexNumber {
  double real, imaginary;

  ComplexNumber(this.real, this.imaginary);

  ComplexNumber operator +(ComplexNumber other) =>
      ComplexNumber(real + other.real, imaginary + other.imaginary);

  ComplexNumber operator -(ComplexNumber other) =>
      ComplexNumber(real - other.real, imaginary - other.imaginary);

  ComplexNumber operator *(ComplexNumber other) => ComplexNumber(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );

  ComplexNumber operator /(Object other) {
    if (other is ComplexNumber) {
      // Division by another complex number
      double denominator =
          other.real * other.real + other.imaginary * other.imaginary;
      return ComplexNumber(
        (real * other.real + imaginary * other.imaginary) / denominator,
        (imaginary * other.real - real * other.imaginary) / denominator,
      );
    } else if (other is int || other is double) {
      // Division by an integer or a double
      double divisor = (other as int).toDouble();
      return ComplexNumber(real / divisor, imaginary / divisor);
    } else {
      throw ArgumentError('Unsupported divisor type: $other');
    }
  }

  double get magnitude => sqrt(real * real + imaginary * imaginary);

  @override
  String toString() =>
      '${real.toStringAsFixed(2)} + ${imaginary.toStringAsFixed(2)}i';
}
