self._TODO  # add all files under tests - those guys need them

require_relative 'lib/skylab/common'

inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.begin

inf.gemspec_path = __FILE__

Gem::Specification.new do | s |

  s.author = 'hipe'

  s.date = inf.date_via_now

  inf.derive_summmary_and_description_from_README_and_write_into s

  s.email = 'my@email.com'

  inf.write_one_or_more_executables_into s

  s.files = inf.to_stream_of_one_or_more_codefiles.to_a

  s.homepage = 'http://localhost:8080/homepage-for-co'

  s.license = 'MIT'

  s.name = inf.gem_name_via_gemspec_path

  s.require_paths = %w( lib )

  s.version = inf.version_via_VERSION_file

  # s.add_runtime_dependency ..
  # [co] nominally depends on [sy] to pass its tests but this is conceptually ugly..

  # s.add_development_dependency ..

end
