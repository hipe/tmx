require_relative "lib/skylab/common"

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|
  o.gemspec_path = __FILE__
end

Gem::Specification.new do |s|

  inf.write_all_the_common_things_and_placeholders s
end
