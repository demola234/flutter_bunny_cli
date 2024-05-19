import 'package:flutter_bunny/src/common/logger_extension.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

class MockLogger extends Mock implements Logger {}

class MockStdout extends Mock implements Stdout {}

void main() {
  group('LoggerExtension', () {
    late Logger logger;
    late MockStdout mockStdout;

    setUp(() {
      logger = MockLogger();
      mockStdout = MockStdout();
    });

    test('create logs correctly formatted message', () {
      const message = 'test message';
      logger.create(message);

      verify(() => logger.info(any())).called(1);
    });

    test('wrapText handles null text', () {
      final messages = <String?>[];
      logger.wrapText(
        text: null,
        print: messages.add,
      );

      expect(messages, equals(['']));
    });

    test('wrapText wraps text with specified length', () {
      final messages = <String?>[];
      logger.wrapText(
        text: 'This is a test message that should wrap correctly',
        print: messages.add,
        length: 20,
      );

      expect(
          messages,
          equals([
            'This is a test ',
            'message that should ',
            'wrap correctly ',
          ]));
    });

    test('wrapText wraps text using terminal columns when stdout has terminal',
        () {
      when(() => mockStdout.hasTerminal).thenReturn(true);
      when(() => mockStdout.terminalColumns).thenReturn(20);

      final messages = <String?>[];
      logger.wrapText(
        text: 'This is a test message that should wrap correctly',
        print: messages.add,
      );

      expect(messages,
          equals(['This is a test message that should wrap correctly ']));
    });

    test(
        'wrapText wraps text using fallback length when stdout does not have terminal',
        () {
      when(() => mockStdout.hasTerminal).thenReturn(false);

      final messages = <String?>[];
      logger.wrapText(
        text: 'This is a test message that should wrap correctly',
        print: messages.add,
      );

      expect(
          messages,
          equals([
            'This is a test message that should wrap correctly ',
          ]));
    });

    test('wrapText handles ANSI sequences correctly', () {
      final messages = <String?>[];
      logger.wrapText(
        text: 'This is a \x1B[31mred\x1B[0m test message',
        print: messages.add,
        length: 20,
      );

      expect(
          messages,
          equals([
            'This is a \x1B[31mred\x1B[0m ',
            'test message ',
          ]));
    });
  });
}
