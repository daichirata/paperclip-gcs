# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "paperclip/gcs/version"

Gem::Specification.new do |spec|
  spec.name          = "paperclip-gcs"
  spec.version       = Paperclip::Gcs::VERSION
  spec.authors       = ["Daichi HIRATA"]
  spec.email         = ["daichirata@gmail.com"]
  spec.summary       = "Extends Paperclip with Google Cloud Storage"
  spec.description   = "Extends Paperclip with Google Cloud Storage"
  spec.homepage      = "https://github.com/daichirata/paperclip-gcs"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "kt-paperclip", ">= 4.0"
  spec.add_runtime_dependency "google-cloud-storage", "~> 1.0"
end
