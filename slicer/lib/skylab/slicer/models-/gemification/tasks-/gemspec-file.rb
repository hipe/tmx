module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Gemspec_File < Task_[]

      depends_on :README_File, :Sigil, :VERSION_File

      def execute

        sd = @Sigil.Sidesystem_Directory
        @_fs = sd.filesystem

        @_ss_path = sd.path

        path = ::File.join @_ss_path, "skylab-#{ @Sigil.basename }.gemspec"
        @path = path

        if @_fs.exist? @path

          @_oes_p_.call :info, :expression do | y |
            y << "no [cm] for this yet! exists - #{ path }"
          end
          ACHIEVED_
        else
          __attempt_to_make_file
        end
      end

      def __attempt_to_make_file
        _ok = __gather_more_information
        _ok && __make_file
      end

      def __gather_more_information

        _dir = ::File.join @_ss_path, 'bin'
        a = ::Dir[ "#{ _dir }/*" ]  # how many can there be?
        _has_binaries = a.length.nonzero?

        @_line_about_executables = if _has_binaries
          'inf.write_one_or_more_executables_into s'
        else
          'inf.assert_no_executables'
        end

        ACHIEVED_
      end

      def __make_file

        _str = Template_string___[]
        _template = Home_.lib_.basic::String.template.via_string _str
        _output = _template.call(
          author: 'hipe',
          email: 'my@email.com',
          homepage: "http://localhost:8080/homepage-for-#{ @Sigil.sigil }",
          line_about_executables: @_line_about_executables,
        )

        path = @path
        io = @_fs.open path, ::File::CREAT | ::File::WRONLY

        bytes = io.write _output
        io.close

        @_oes_p_.call :info, :expression do | y |
          y << "wrote #{ path } (#{ bytes } bytes)"
        end

        ACHIEVED_
      end

      Template_string___ = Common_.memoize do

        s = <<-HERE
          require 'skylab/common'

          inf = Skylab::Common::Sessions::Gemspec_Inference.new

          inf.gemspec_path = __FILE__

          Gem::Specification.new do | s |

            s.author = '{{ author }}'

            s.date = inf.date_via_now

            inf.derive_summmary_and_description_from_README_and_write_into s

            s.email = '{{ email }}'

            {{ line_about_executables }}

            s.files = inf.to_stream_of_one_or_more_codefiles.to_a

            s.homepage = '{{ homepage }}'

            s.license = 'MIT'

            s.name = inf.gem_name_via_gemspec_path

            s.require_paths = %w( lib )

            s.version = inf.version_via_VERSION_file

            s.add_runtime_dependency 'skylab-common', [ '0.0.0.co.pre.bleeding' ]

            # s.add_development_dependency ..
          end
        HERE

        s.gsub!( /^#{ s.match( /\A[ ]+/ ) }/, EMPTY_S_ )
        s.freeze
      end

      EMPTY_S_ = ''
    end
  end
end
