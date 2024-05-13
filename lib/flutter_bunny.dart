Future<void> main(List<String> arguments) async {
  if (arguments.contains('--version') || arguments.contains('-v')) {
    print("version 1.1");
  } else {
    print("no version found");
  }
}
