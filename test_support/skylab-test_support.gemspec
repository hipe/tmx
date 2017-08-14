require "skylab/common"

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|
  o.gemspec_path = __FILE__
end

a = inf.to_stream_of_one_or_more_codefiles.to_a

dir = inf.subject_directory
r = dir.length + 1 .. -1

%w( fixture-directories fixture-files ).each do |entry|

  ::Dir[ "#{ dir }/#{ entry }/**" ].each do |s|
    a.push s[ r ]
  end
end

Gem::Specification.new do |s|

  s.files = a

  inf.write_all_the_common_things_and_placeholders s

  s.homepage = "http://localhost:8080/homepage-for-ts"

  s.add_runtime_dependency "skylab-common", [ "0.0.0" ]

  s.add_development_dependency "rspec", "~> 3.6"  # 3.6.0

  s.add_development_dependency "adsf", "~> 1.2"  # 1.2.1

    # at writing the above dependency is first hit when testing [te]
    # we might try to phase it out or use just rack somehow #todo

  s.add_development_dependency 'simplecov', '~> 0.15'

    # (we need bundler)
    # simplecov-html-0.10.2
    # docile-1.1.5
    # simplecov-0.15.0
end
