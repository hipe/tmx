require 'skylab/common'

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.begin

inf.gemspec_path = __FILE__

Gem::Specification.new do |o|

  o.author = 'hipe'

  o.date = inf.date_via_now

  inf.derive_summmary_and_description_from_README_and_write_into o

  o.email = 'my@email.com'

  # inf.write_one_or_more_executables_into o
  inf.assert_no_executables

  o.files = inf.to_stream_of_one_or_more_codefiles.to_a

  o.homepage = 'http://localhost:8080/homepage-for-tab'

  o.license = 'MIT'

  o.name = inf.gem_name_via_gemspec_path

  o.require_paths = %w( lib )

  o.version = inf.version_via_VERSION_file

  o.add_runtime_dependency 'skylab-common', [ '0.0.0.co.pre.bleeding' ]

  # o.add_development_dependency ..
end
