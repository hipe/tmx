self._TODO  # add all files under tests - those guys need them

require_relative 'lib/skylab/callback'

inf = Skylab::Callback::Sessions::Gemspec_Inference.new

inf.gemspec_path = __FILE__

Gem::Specification.new do | s |

  s.author = 'hipe'

  s.date = inf.date_via_now

  inf.derive_summmary_and_description_from_README_and_write_into s

  s.email = 'my@email.com'

  inf.write_one_or_more_executables_into s

  s.files = inf.to_stream_of_one_or_more_codefiles.to_a

  s.homepage = 'http://localhost:8080/homepage-for-ca'

  s.license = 'MIT'

  s.name = inf.gem_name_via_gemspec_path

  s.require_paths = %w( lib )

  s.version = inf.version_via_VERSION_file

  # s.add_runtime_dependency ..
  # [ca] nominally depends on [sy] to pass its tests but this is conceptually ugly..

  # s.add_development_dependency ..

end