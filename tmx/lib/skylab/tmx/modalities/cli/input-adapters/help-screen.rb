module Skylab::TMX

  class Modalities::CLI::Input_Adapters::Help_Screen

    attr_reader(
      :number_of_lines,
    )

    def initialize

      @_pass = -> _ do  # MONADIC_TRUTH_
        true
      end

      @_state_machine = nil
    end

    attr_writer(
      :proxy_class,
    )

    def skip_blanks

      @_pass = -> line do
        BLANK_RX_ !~ line
      end
      NIL_
    end

    def unstylize

      _p = Home_.lib_.brazen::CLI_Support::Styling::Unstyle

      @_lone_filter = -> line do

        _p[ line ]
      end

      NIL_
    end

    def match_the_following_section_names_in_a_case_insensitive_manner
      @_be_case_sensitive = false ; nil
    end

    def number_of_lines= d

      @_prepare = -> do
        @_count = 0
      end

      @_tick = -> do
        @_count += 1 ; nil
      end

      @_stop = -> do
        d == @_count
      end

      @number_of_lines = d
    end

    def use_section_in_descending_order_of_preference * sym_a

      _ok = __init_box sym_a
      _ok && __init_state_machine
    end

    def __init_box sym_a

      same = -> sym do
        Common_::Name.via_variegated_symbol( sym ).as_human
      end

      p = if @_be_case_sensitive
        -> sym do
          /\A#{ same[ sym ] }\z/
        end
      else
        -> sym do
          /\A#{ same[ sym ] }\z/i
        end
      end

      bx = Common_::Box.new

      sym_a.each do | sym |
        bx.add sym, p[ sym ]
      end

      @_box = bx
      ACHIEVED_
    end

    def __init_state_machine

      @_state_machine = Memoized_state_machine___[]
      ACHIEVED_
    end

    Lazy_ = Common::Lazy

    Memoized_state_machine___ = Lazy_.call do  # see [#003]

      o = Home_.lib_.basic::State::Machine::Edit_Session.new

      o.add_state( :beginning,

        :can_transition_to, [
          :line_with_header,
          :dedicated_header_line,
        ],
      )

      o.add_state( :after_section,

        :can_transition_to, [
          :line_with_header,
          :dedicated_header_line,
          :indented_line,
          :directive_line,
        ],
      )

      o.add_state( :indented_line,

        :entered_by_regex, /\A[[:space:]]+[^[:space:]]/,

        :can_transition_to, [
          :indented_line,
          :blank_line_after_section,
        ],
      )

      o.add_state( :directive_line,

        :entered_by_regex, /\A[[:space:]]*[^[:space:]]+[[:space:]]/,

        :on_entry, -> _guy, _md do

          :beginning  # OR `after_section` (as needed)
        end,
      )

      o.add_state( :blank_line_after_section,

        :entered_by_regex, BLANK_RX_,

        :on_entry, -> guy, _md do

          _stay = guy.close_section
          if _stay
            :after_section
          else
            :early_ending
          end
        end,
      )

      o.add_state( :line_with_header,

        :entered_by_regex,
          /\A (?<hdr> [a-z]+ ): [[:space:]]+ (?<rest> .+) \z/ix,

        :on_entry, -> guy, md do

          guy.receive_header md[ :hdr ]
          _stay = guy.receive_content_line md[ :rest ]
          if _stay
            :after_common_section_line
          else
            :early_ending
          end
        end,
      )

      o.add_state( :dedicated_header_line,

        :entered_by_regex,
          /\A (?<hdr> [a-z]+ ):? \z/ix,

        :on_entry, -> guy, md do

          guy.receive_header md[ :hdr ]
          :after_dedicated_header_line
        end,
      )

      o.add_state( :after_dedicated_header_line,
        :can_transition_to, [
          :line_of_current_section,
        ],
      )

      o.add_state( :line_of_current_section,

        :entered_by_regex,
          /\A (?:
            [[:space:]]+  (?<content> .+ ) |  # any indented line -OR-
            (?<content> [^[:space:]:]+\b (?! : ) .* )  # any non-header looking line
          ) \z/ix,

        :on_entry, -> guy, md do

          _stay = guy.receive_content_line md[ :content ]
          if _stay
            :after_common_section_line
          else
            :early_ending
          end
        end,
      )

      o.add_state( :after_common_section_line,
        :can_transition_to, [
          :line_of_current_section,
          :blank_line_after_section,
          :line_with_header,
          :dedicated_header_line,
          :ending,
        ],
      )

      o.add_state( :early_ending,

        :on_entry, -> do
          throw STOP_
        end,
      )

      o.add_state( :ending,
        :entered_by, -> _st do

          # any state that indicated this as a possible next
          # state may enter without barrier from this state

          :_trueish_
        end,

        :on_entry, -> ob, st do
          NIL_  # you must declare that you have no next state
        end,
      )

      o.flush_to_state_machine
    end

    def lines_by & receive_proxy

      if @_state_machine
        __lines_by_with_state_machine( & receive_proxy )
      else
        __lines_by_easy( & receive_proxy )
      end
    end

    def __lines_by_easy & receive_proxy

      a = []

      filt = @_lone_filter ; pass = @_pass ; stop = @_stop ; tick = @_tick
      @_prepare[]
      if ! stop[]

        _proxy = @proxy_class.new do | o |

          o[ :receive_string ] = -> line do
            _yes = pass[ line ]
            if _yes
              a.push filt.call line
              tick[]
              if stop[]
                throw STOP_
              end
            end
          end

          o[ :receive_line_args ] = -> line_a do
            self._NEVER
          end
        end

        catch STOP_ do
          receive_proxy[ _proxy ]
        end
      end

      a
    end

    def __lines_by_with_state_machine & receive_proxy

      filt = @_lone_filter
      stop = @_stop

      @_prepare[]
      if ! stop[]

        guy = __build_guy

        sm = @_state_machine

        sess = sm.begin guy

        _String = Home_.lib_.basic::String

        receive_paragraph = -> para_s do

          st = _String.line_stream para_s

          begin

            s = st.gets
            s or break
            s_ = filt.call s
            s_.chomp!
            if s_.index( $/, -1 )
              self._WHAT
            end
            sess.puts s_
            redo
          end while nil
        end

        _proxy = @proxy_class.new do | o |

          o[ :receive_line_args ] = -> s_a do

            case 1 <=> s_a.length
            when 0
              paragraph_s = s_a.fetch 0
              if paragraph_s
                receive_paragraph[ paragraph_s ]
              else
                sess.puts EMPTY_S_
              end
            when 1
              sess.puts EMPTY_S_
            else
              self._COVER_ME
            end
            NIL_
          end

          o[ :receive_string ] = -> para_s do

            # this happens with clients that pass their would-be stderr
            # (actually our proxy) to a platform option parser's `summarize`
            # method - it sends `<<` to the object, with an already newline-
            # -terminated string..

            receive_paragraph[ para_s ]
          end
        end

        catch STOP_ do
          receive_proxy[ _proxy ]
        end

        a = guy.line_array
      end

      a
    end

    def __build_guy
      Guy___.new @_box, @number_of_lines
    end

    class Guy___

      attr_reader :line_array

      def initialize bx, no

        @_box = bx
        @line_array = []
        @_number_of_lines = no
        @_ordinal_to_beat = bx.length
      end

      def receive_header hdr

        found = nil
        d = -1
        @_box.each_pair do | k, rx |
          d += 1
          if rx =~ hdr
            found = k
            break
          end
        end

        if found
          if d <= @_ordinal_to_beat
            @_is_first_pick = d.zero?
            @_ordinal_to_beat = d
            @line_array.clear
            @_do_ignore = false
          else
            @_do_ignore = true
          end
        else
          # e.g 'action', 'argument[s]' 'option[s]'
          @_do_ignore = true
        end
        NIL_
      end

      def receive_content_line line

        if @_do_ignore
          ACHIEVED_
        else
          @line_array.push line
          case @_number_of_lines <=> @line_array.length
          when 1
            ACHIEVED_
          when 0

            # if you reach your target number of lines, what you do depends
            # on whether or not you know with certainty that you are done
            # with the help screen:

            if @_is_first_pick

              NIL_  # for STOP_
            else

              # ignore subsequent lines in this section, but stay in the screen

              @_do_ignore = true
              ACHIEVED_
            end
          when -1
            self._SANTIY
          end
        end
      end

      def close_section
        ACHIEVED_
      end
    end

    BLANK_RX_ = /\A[[:space:]]*\z/
    STOP_ = :"::Skylab::TMX::__stop__"
  end
end
