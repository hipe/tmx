require "skylab/common"

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|
  o.gemspec_path = __FILE__
end

Gem::Specification.new do |s|

  s.homepage = "http://localhost:8080/homepage-for-bs"

  inf.write_all_the_common_things_and_placeholders s

  s.add_runtime_dependency "skylab-common", [ "0.0.0" ]

  s.add_runtime_dependency 'ast', '~> 2.3'  # 2.3.0

  s.add_runtime_dependency 'parser', '~> 2.4.0'  # 2.4.0.0

  # ALSO: "Ragel State Machine Compiler version 6.10 March 2017" (more on this soon..)

  s.add_runtime_dependency 'unparser', '~>0.2'  # 0.2.6
  # YIKES we need bundler. the above also installed:
    # abstract_type-0.0.7
    # thread_safe-0.3.6
    # memoizable-0.4.2
    # ice_nine-0.11.2
    # adamantium-0.2.0
    # equalizer-0.0.11
    # concord-0.1.5
    # procto-0.0.3
end
# #history-A.1: begin to dismantle dependency on 'ruby_parser'
