require "skylab/common"

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|
  o.gemspec_path = __FILE__
end

Gem::Specification.new do |s|

  s.homepage = "http://localhost:8080/homepage-for-bs"

  inf.write_all_the_common_things_and_placeholders s

  s.add_runtime_dependency "skylab-common", [ "0.0.0" ]

  s.add_runtime_dependency 'ruby_parser', '~> 3.10'  # 3.10, sexp_processor 4.10.0

  # ALSO: "Ragel State Machine Compiler version 6.10 March 2017" (more on this soon..)
end
