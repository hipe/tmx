module Skylab::TaskExamples

  class TaskTypes::VersionFrom < Common_task_[]

    depends_on_parameters(
      must_be_in_range: :optional,
      parse_with: :optional,
      show_version: [ :flag, :optional ],
      version_from: nil,
    )

    def execute
      if @show_version
        __show_version
      else
        ___check_version
      end
    end

    # -- check version

    def ___check_version

      ver_r = __build_version_range
      if ver_r
        ___check_vesion_against_range ver_r
      else
        ver_r
      end
    end

    def ___check_vesion_against_range ver_r

      ver_s = __procure_version_string

      if ver_s
        if ver_r.match ver_s
          __when_version_yes ver_s, ver_r
        else
          ___when_version_no ver_s, ver_r
        end
      else
        ver_s
      end
    end

    def ___when_version_no ver_s, ver_r

      @_listener_.call :error, :expression do |y|

        y << "version mismatch: needed #{ ver_r } had #{ ick ver_s }"
      end
      UNABLE_
    end

    def __when_version_yes ver_s, ver_r

      @_listener_.call :info, :expression do |y|

        y << "version ok: version #{ ver_s } is in range #{ ver_r }"
      end
      ACHIEVED_
    end

    def __build_version_range

      s = @must_be_in_range
      if s
        Home_::VersionRange.build s, & @_listener_
      else
        ___when_no_range_term
      end
    end

    def ___when_no_range_term
      msg = ___say_no_term
      @_listener_.call :error, :expression do |y|
        y << msg
      end
      UNABLE_
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

      ver_s, did_use_regex = _parse_version_string
      if ver_s
        __do_show_version ver_s, did_use_regex
      else
        ver_s
      end
    end

    def __do_show_version ver_s, did_use_regex

      @_listener_.call :payload, :expression do |y|

        headerize = -> s do
          "#{ hdr 'version' } #{ s }"
        end

        if did_use_regex
          y << headerize[ ver_s ]
        else
          _s_a = ver_s.split NEWLINE_
          _s_a.each do |s|
            y << headerize[ s ]
          end
        end
        y
      end

      ACHIEVED_
    end

    # -- support

    def _parse_version_string  # ( version string, regex used )

      if @parse_with
        rx = ___build_regex @parse_with
      end

      buffer = Home_::Library_::StringIO.new
      read = lambda { |s| buffer.write(s) }

      Home_.lib_.system.open2 @version_from do | o |
        o.out( & read )
        o.err( & read )
      end

      buffer.rewind
      s = buffer.read

      if rx
        md = rx.match s
        if md
          [ md[ 1 ], true ]
        else
          @_listener_.call :error, :expression do |y|
            y << "using provided regex, couldn't parse version from #{ ick s }"
          end
          UNABLE_
        end
      else
        [ s, false ]
      end
    end

    def ___build_regex s  # #todo - un-dry the parsing of a regex

      md = RX_RX__.match s

      if md
        body, modifiers = md.captures

        if MODIFIER_RX___ =~ modifiers
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
