module Skylab::TaskExamples

  class TaskTypes::VersionFrom < Common_task_[]

    _etc = {
      must_be_in_range: :optional,
      parse_with: :optional,
      show_version: [ :_from_context, :flag, :optional ],
      version_from: nil,
    }

    depends_on_parameters( * _etc.keys )

    def initialize
      @must_be_in_range = nil
      @parse_with = nil
      @show_version = false
      super
    end

    def execute
      if @show_version
        __show_version
      else
        ___check_version
      end
    end

    # -- check version

    def check_version

      ver_r = __build_version_range

      ver_s = __procure_version_string

      if ver_s
        if ver_r.match version_s
          __when_version_yes ver_s, ver_r
        else
          ___when_version_no ver_s, ver_r
        end
      else
        ver_s
      end
    end

    def ___when_version_no ver_s, ver_r

      @_oes_p_.call :error, :expression do |y|

        y << "version mismatch: needed #{ ver_r } had #{ ick ver_s }"
      end
      UNABLE_
    end

    def __when_version_yes ver_s, ver_r

      @_oes_p_.call :info, :expression do |y|

        y << "version ok: version #{ val ver_s } is in range #{ ver_r }"
      end
      ACHIEVED_
    end

    def __build_version_range

      s = @must_be_in_range
      if s
        Home_::VersionRange.build s
      else
        fail ___say_no_term
      end
    end

    def ___say_no_term
      "Do not use \"version from\" as a target #{
        }without a \"must be in range\" assertion."
    end

    def __procure_version_string

      version_s, _regex_used = _parse_version_string  # ..
      version_s
    end

    # -- show version

    def __show_version

      version, used_regex = _parse_version_string

      (used_regex ? [version] : version.split("\n")).each do |line|
        call_digraph_listeners :payload, "#{hi 'version:'} #{line}"
      end
      true
    end

    # -- support

    def _parse_version_string  # ( version string, regex used )

      if @parse_with
        rx = ___build_regex @parse_with
      end

      buffer = Home_::Library_::StringIO.new
      read = lambda { |s| buffer.write(s) }

      Home_.lib_.system.open2 version_from do | o |
        o.out( & read )
        o.err( & read )
      end

      buffer.rewind
      s = buffer.read

      if rx
        md = rx.match s
      end

      if md
        [ md[ 1 ], true ]
      else
        [ s, false ]
      end
    end

    def ___build_regex s  # #todo - un-dry the parsing of a regex

      md = RX_RX__.match s

      if md
        body, modifiers = md.captures

        if MODIFIER_RX__ =~ modifiers
          ::Regexp.new body, modifiers
        else
          raise __say_when_bad_modifiers modifiers
        end
      else
        raise __say_when_bad_rx_string s
      end
    end

    def __say_when_bad_modifiers s
      "had modifiers #{ s.inspect }, need #{ MODIFIER_RX__.source }"
    end

    def __say_when_bad_rx_string s
      "Failed to parse regexp: #{ s }. #{ RX_RX__.source }"
    end

    RX_RX__ = %r{\A/(.+)/([a-z]*)\z}
    MODIFIER_RX___ = /\A[imox]*\z/
  end
end
