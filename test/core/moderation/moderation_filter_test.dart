import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core: Directiva de Moderación Táctica Local', () {
    final RegExp forbiddenWordsRegExp = RegExp(
      r'(arma|droga|estafa|falso|falsa)',
      caseSensitive: false,
    );

    test(
      'Debe aceptar y dar por válidos textos limpios sin términos ilegales',
      () {
        final text1 =
            'Ofrezco iPhone 14 Pro en perfecto estado por una bicicleta de montaña.';
        final text2 =
            'Excelente vendedor, trato en mano muy agradable en Madrid Centro.';

        expect(forbiddenWordsRegExp.hasMatch(text1), isFalse);
        expect(forbiddenWordsRegExp.hasMatch(text2), isFalse);
      },
    );

    test(
      'Debe interceptar y detectar de inmediato palabras prohibidas en minúsculas',
      () {
        final illegalText1 =
            'Cambio una sustancia o droga por componentes de PC.';
        final illegalText2 =
            'Cuidado con este usuario, es una estafa absoluta.';

        expect(forbiddenWordsRegExp.hasMatch(illegalText1), isTrue);
        expect(forbiddenWordsRegExp.hasMatch(illegalText2), isTrue);
      },
    );

    test(
      'Debe ser insensible a mayúsculas e interceptar términos camuflados o en mayúsculas',
      () {
        final caseText1 = 'Vendo ARMA de aire comprimido como nueva.';
        final caseText2 = 'Zapatillas de marca pero son una FALSA imitación.';

        expect(forbiddenWordsRegExp.hasMatch(caseText1), isTrue);
        expect(forbiddenWordsRegExp.hasMatch(caseText2), isTrue);
      },
    );
  });
}
