require "skylab/common"

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|

  o.has_executables = false

  o.gemspec_path = __FILE__
end

Gem::Specification.new do |s|

  inf.write_all_the_common_things_and_placeholders s

  s.homepage = "http://localhost:8080/homepage-for-pa"

  s.add_runtime_dependency "skylab-common", [ "0.0.0" ]
end
