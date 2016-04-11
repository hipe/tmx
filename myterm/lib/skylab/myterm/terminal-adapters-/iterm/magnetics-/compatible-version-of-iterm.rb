module Skylab::MyTerm

  class Terminal_Adapters_::Iterm

    class Magnetics_::Compatible_Version_of_Iterm < Callback_::Actor::Monadic

      THRESHOLD_ITERM2_VERSION___ = [ 2, 9, 20140903 ]

      def initialize o, & p
        @_mags = o ; @_oes_p = p
      end

      def execute
        ok = true
        ok &&= __resolve_version_string
        ok &&= __resolve_version_parts
        ok && Callback_::Known_Known[ __check_iTerm2_version ]
      end

      def __check_iTerm2_version

        major, minor, patch = @__version_parts

        _target_major, _target_minor, _target_patch = THRESHOLD_ITERM2_VERSION___

        _ok = case _target_major <=> major
        when  0
          case _target_minor <=> minor
          when  0
            case _target_patch <=> patch
            when  0 ; ACHIEVED_
            when  1 ; UNABLE_
            when -1 ; ACHIEVED_
            end
          when  1 ; UNABLE_
          when -1 ; ACHIEVED_
          end
        when  1 ; UNABLE_
        when -1 ; ACHIEVED_
        end

        if _ok
          ACHIEVED_
        else
          self._COVER_ME_iTerm2_version_is_too_low
        end
      end

      def __resolve_version_parts

        ok = true
        rx = /\A\d+\z/
        a = []
        v_s = @_version_string
        v_s.split( '.' ).each do |s|  # DOT_
          if rx =~ s
            a.push s.to_i
            next
          end
          @_oes_p.call :error, :emission, :etc do |y|
            y << "version component is not an integer: #{ s.inspect } (of #{ v_s.inspect })"
          end
          ok = false
        end
        if ok
          if 3 == a.length
            @__version_parts = a
          else
            self._COVER_ME_not_three_parts
          end
        end
        ok
      end

      def __resolve_version_string

        _, o, e, w = @_mags.system_conduit_.popen3( 'osascript',
          '-e', 'tell application "iTerm2"',
          '-e', 'return version',
          '-e', 'end tell',
        )

        s = e.gets
        if s
          self._COVER_ME
        else
          s = o.read
          w.value.exitstatus.zero? or self._SANITY
          s.chomp!
          @_version_string = s
          ACHIEVED_
        end
      end
    end
  end
end
