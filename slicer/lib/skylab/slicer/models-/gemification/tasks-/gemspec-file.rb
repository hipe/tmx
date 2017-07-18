module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Gemspec_File < Task_[]

      depends_on(
        :README_File,
        :Sigil,
        :For_TMX_Map_File,
        :VERSION_File,
      )

      def execute

        rsx = resources_
        @_fs = rsx.filesystem

        ss = rsx.sidesystem_path
        @_ss_path = ss

        path = ::File.join ss, "skylab-#{ ss }.gemspec"
        @path = path

        if @_fs.exist? @path

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

        if _has_binaries

          @_thing_1 = nil
        else
          @_thing_1 = "\n  o.has_executables = false\n\n"
        end

        ACHIEVED_
      end

      def __make_file

        _str = Template_string___[]
        _template = Home_.lib_.basic::String::Template.via_string _str

        _homepage = "http://localhost:8080/homepage-for-#{ @Sigil.sigil }"

        _output = _template.call(
          xx: @_thing_1,
          homepage: _homepage,
        )

        path = @path

        bytes = ::File.write path, _output

        @_listener_.call :info, :expression do |y|
          y << "wrote #{ path } (#{ bytes } bytes)"
        end

        ACHIEVED_
      end

      Template_string___ = Common_.memoize do

        s = <<-HERE
          require "skylab/common"

          inf = Skylab::Common::Magnetics::GemspecInference_via_GemspecPath_and_Specification.define do |o|
          {{ xx }}  o.gemspec_path = __FILE__
          end

          Gem::Specification.new do |s|

            inf.write_all_the_common_things_and_placeholders s

            s.homepage = "http://localhost:8080/homepage-for-{{ sigil }}"

            s.add_runtime_dependency "skylab-common", [ "0.0.0" ]
          end
        HERE

        s.gsub!( /^#{ s.match( /\A[ ]+/ ) }/, EMPTY_S_ )
        s.freeze
      end

      def resources_  # ick/meh
        @README_File.resources_
      end

      attr_reader(
        :VERSION_File,  # meh
      )

      # ==

      EMPTY_S_ = ''

      # ==
      # ==
    end
  end
end
# #history-A: dried gemspecs
