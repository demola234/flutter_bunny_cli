class FlutterBunny < Formula
    desc "Flutter Bunny: A CLI tool for Flutter development"
    homepage "https://github.com/demola234/bunny_cli"
    license "MIT"
    version "{{VERSION}}"
  
    on_macos do
      on_arm do
        url "{{MACOS_ARM64_URL}}"
        sha256 "{{MACOS_ARM64_SHA256}}"
      end
      on_intel do
        url "{{MACOS_X64_URL}}"
        sha256 "{{MACOS_X64_SHA256}}"
      end
    end
  
    def install
      bin.install "flutter_bunny"
    end
  
    test do
      # Test by showing help 
      system "#{bin}/flutter_bunny", "--help"
    end
  end