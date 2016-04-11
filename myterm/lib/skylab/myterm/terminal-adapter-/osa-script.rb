module Skylab::MyTerm

  module Terminal_Adapter_  # NOTE for now, this file is the "creator"
    # of this module but change this as soon as there is more than one
    # file under this node.

    class OSA_Script

      # wrap the byte-per-byte content of an applescript (which can be
      # expressed as an array of lines) and expose an interface for
      # executing that script on the system (complete with some kind of
      # error handling).
      #
      # we have called it "OSA script" (Apple's "Open Scripting Architecture")
      # and not just AppleScript to invest in the mental real estate of
      # imagining supporting other languages in that family (like maybe for
      # example one day JavaScript); but for today that avenue is not coded
      # for at all, beyond this class name.

      class << self

        def via_one_big_string s
          _begin_empty.__init_by_one_big_string s
        end
        alias_method :_begin_empty, :new
        undef_method :new
      end  # >>

      def initialize
        NOTHING_  # (hi.)
      end

      def __init_by_one_big_string s
        if ! s.frozen?
          s = s.dup.freeze
        end
        @__one_big_string = s ; freeze
      end

      def send_into_system_conduit sycond, & oes_p

        Execution___.new( sycond, self, & oes_p ).execute
      end

      def each_line( & p )
        to_line_stream.each( & p )
      end

      def to_line_stream

        # (this probably doesn't belong here, considering how low-level
        # it is. OCS prevents us from using `split`. what we do here is
        # a sketch for a solution to [#sa-011]. #todo )

        big_s = @__one_big_string
        len = big_s.length
        pos = 0
        rx = /\G[^\n\r]*(?:\n|\r\n?)?/

        Callback_.stream do
          if len != pos
            md = rx.match big_s, pos
            pos = md.offset( 0 ).last
            md[ 0 ]  # (or 0 if you want the whole newline)
          end
        end
      end

      # ==

      class Execution___

        def initialize system_conduit, osa_script, & oes_p
          @_oes_p = oes_p
          @OSA_script = osa_script
          @system_conduit = system_conduit
        end

        def execute

          ok = true
          ok &&= __resolve_system_command_token_string_array
          ok &&= __send_to_system_without_error
          ok && __mixed_result
        end

        def __mixed_result

          s = @_o.read  # ..
          # (we could instead result in a special stream, but not today)

          if @_w.value.exitstatus.zero?
            if s
              s  # to parse this is out of our domain
            else
              # (for now, let's allow for scripts that output nothing,
              #  and the client has to anticipate that it does this.)
              ACHIEVED_
            end
          end
        end

        def __send_to_system_without_error

          _i, @_o, e, @_w = @system_conduit.
            popen3( * @__system_command_token_string_array )

          s = e.gets
          if s
            self._COVER_ME_did_not_succeed
          else
            ACHIEVED_
          end
        end

        def __resolve_system_command_token_string_array

          st = @OSA_script.to_line_stream
          line = st.gets
          if line
            s_a = [ 'osascript' ]
            begin
              line.chomp!
              s_a.push '-e', line
              line = st.gets
            end while line
            @__system_command_token_string_array = s_a
            ACHIEVED_
          else
            self._COVER_ME_script_is_empty
          end
        end
      end

      # ==
    end
  end
end
# #history: broke out of "osascript via path" (for iTerm terminal adapter node)
