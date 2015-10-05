require 'skylab/callback'

inf = Skylab::Callback::Sessions::Gemspec_Inference.new

inf.gemspec_path = __FILE__

spec = Gem::Specification.new do | s |

  s.author = 'hipe'

  s.date = inf.date_via_now

  inf.derive_summmary_and_description_from_README_and_write_into s

  s.email = 'my@email.com'

  inf.write_one_or_more_executables_into s

  s.homepage = 'http://localhost:8080/homepage-for-ts'

  s.license = 'MIT'

  s.name = inf.gem_name_via_gemspec_path

  s.require_paths = %w( lib )

  s.version = inf.version_via_VERSION_file

  s.add_runtime_dependency 'skylab-basic', [ '0.0.0.ba.pre.bleeding' ]

  s.add_runtime_dependency 'skylab-brazen', [ '0.0.0.br.pre.bleeding' ]
    # to render the tables of help screens

end

a = inf.to_stream_of_one_or_more_codefiles.to_a

dir = inf.subject_directory
r = dir.length + 1 .. -1

%w( fixture-directories fixture-files ).each do | entry |

  ::Dir[ "#{ dir }/#{ entry }/**" ].each do | s |
    a.push s[ r ]
  end
end

spec.files = a

spec or false
