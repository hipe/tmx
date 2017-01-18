module Skylab::Zerk

  module CLI

    class SynopsisLines_via_HelpScreen < Home_::SimpleModel_  # :[#063.2]

      # in a manner that is variously violent, efficient and beautiful;
      # attempt to derive N (eg. 2) "synopsis lines" from any agent that
      # expresses a help screen for use in [#tmx-018.2] deep listings, based
      # on a set of axiomatic heuristics detailed in our document.

      # we implement this through a state-machine-based parser written to
      # accomodate the (at writing) 28 help screens of our target use case.
      # this parser is not assumed robust for all streams of strings; there
      # is a chance that it is but we don't care.

      # (there is a known issue with agents that use `<<` instead of `puts`
      # on its byte downstream (nominally STDERR) - fixing this is trivial
      # but instead we have worked around it by writing dedicated synopsis
      # sections for those one-offs (something they should have anyway),
      # which has the side-effect of causing the expression to exit early
      # before it reaches the invoved code (which comes from `optparse`,
      # not us.)

      # as for what is both "violent" and "efficient" about it: if we can
      # decide conclusively that we have the ideal lines of output from a
      # help screen, then (so the thinking goes) there is no need to put
      # the further work into expressing the remainder of the help screen
      # (much less parsing it). (our document describes these ideal lines
      # indirectly.)
      #
      # accomplishing this, while "easy", is a bit nasty: all of our help
      # screens are generally written the same way, in a "push" paradigm
      # where the agent writes each line of expression to an ostensible
      # STDERR until all lines are expressed.
      #
      # this "push" mode is contrary to the "pull" mode we would rather have
      # here, where we would pull lines from a producer until our criteria
      # is satisfied. while converting from a pull paradigm to a push
      # paradigm is trivial, the reverse is not.
      #
      # so the nasty trick we exploit to try to accomplish this anyway is
      # this: if we reach a point where we know we are done, we `throw`.
      # somewhere else lower on our own call stack we `catch` this throw.
      # as well as being a stunt that is generally frowned upon, this could
      # lead to particular problems if for example the remote agent was
      # expecting to do some cleanup (like maybe closing a file it was
      # reading to express help).
      #
      # but since we "know" that none of our ~28 agents have any such
      # special requirements, we brute-force this early exit in such a
      # manner. but note this isn't future-safe.

      # this is also tracked by :[#054.3] being that it is in this
      # strain of facilities that parse similar such documents. (this is
      # the third of five facilities in that strain.)

      # the remote document has more about parsing help screens generally.

      # -

        def initialize

          @listener = nil

          yield self

          0 < @number_of_synopsis_lines ||
            self._INVALID__this_number_must_be_one_or_greater__  # because #here-1

          @section_header_symbols_in_order_of_preference ||= IN_THIS_ORDER___

          Require_unstylizers___[]
        end

        attr_writer(
          :listener,  # optional. used to emit debugging info only.
          :number_of_synopsis_lines,
        )

        def synopsis_lines_by & p
          rec = dup
          rec.extend RecordingMethods___
          rec.invoke_by( & p )
          SynopsisLines_via_Recording___[ rec ]
        end

        attr_reader(
          :number_of_synopsis_lines,
          :section_header_symbols_in_order_of_preference,
        )
      # -

      # ==

      IN_THIS_ORDER___ = %i( synopsis description usage )  # per pseudocode

      # ==

      class SynopsisLines_via_Recording___ < Common_::Monadic

        def initialize rec
          @_ = rec
        end

        def execute
          h = @_.section_box.h_
          sect = nil
          @_.section_header_symbols_in_order_of_preference.each do |sym|
            sect = h[ sym ]
            sect && break
          end
          if sect
            sect.N_content_lines
          else
            self._COVER_ME__no_such_section_found_among_these_N_sections__
          end
        end
      end

      # ==

      module RecordingMethods___

        def invoke_by( & p )
          __init_section_box_by( & p )
          NIL
        end

        def __init_section_box_by
          @section_box = Common_::Box.new
          @_state_machine_session = __state_machine_session
          _downstream_IO = __downstream_IO

          @_is_finished_early = false

          catch FINISH_EARLY_ do
            yield _downstream_IO
          end

          _sms = remove_instance_variable :@_state_machine_session
          _sms.close
          NIL
        end

        def __downstream_IO
          _Proxy = Home_::lib_.system_lib::IO::DownstreamProxy
          _Proxy.define do |o|
            o.listener = method :__receive_string_from_helpscreen
            o.stream_identifier = NOTHING_
          end
        end

        def __receive_string_from_helpscreen s, m, _
          send METHODS___.fetch(m), s
        end

        METHODS___ = {
          puts: :__receive_semi_normal_string,
          # ..
        }

        def __receive_semi_normal_string s

          if s  # agent can puts nil to mean blank line #coverpoint-2-2

            use_s = if Styling__::SIMPLE_STYLE_RX =~ s  # 1/3 of agents (see #note-1)
              Styling__::Unstyle_styled[ s ]
            else
              s
            end

            if MULTIPLE_LINES___ =~ use_s  # #coverpoint-2-4

              line_stream = Basic_[]::String::LineStream_via_String[ use_s ]
              use_s = line_stream.gets
              again = -> do
                use_s = line_stream.gets
                use_s ? TRUE : FALSE
              end
            else
              again = EMPTY_P_
            end
          else
            use_s = s  # nil or false
            again = EMPTY_P_
          end

          begin
            @_state_machine_session.puts use_s
            if @_is_finished_early
              __FINISH_EARLY
            end
            again[] ? redo : break
          end while above

          NIL
        end

        def __FINISH_EARLY
          if @listener
            @listener.call :debug, :expression, :finishing_early do |y|
              y << "(DEBUG: throwing a finish early!)"
            end
          end
          throw FINISH_EARLY_
        end

        def __state_machine_session
          _sm = Memoized_state_machine___[]
          _sm.begin_driven_session_by do |o|
            o.page_listener = method :__receive_section
            o.downstream_by = -> do
              Section___.new self
            end
          end
        end

        def __receive_section sect

          # (this tacitly confirms that we aren't getting multiple sections
          # with the same header content string. *maybe* this would fail
          # against some help screen case we haven't imagined yet..)

          sect.finish
          @section_box.add sect.header_symbol, sect
          if sect.is_target_section
            @_is_finished_early = true
          end
          NIL
        end

        attr_reader(
          :section_box,
        )
      end

    #===

    Memoized_state_machine___ = Lazy_.call do

      o = Basic_[]::StateMachine.begin_definition

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

        :on_entry, -> _sm do

          :after_section  # not `beginning` per #coverpoint-2-6
        end,
      )

      o.add_state( :blank_line_after_section,

        :entered_by, -> scn do

          # rather than map every line with this check, we just write this
          # particular node to be indifferent to whether the remote agent
          # did (for example) `serr.puts` or `serr puts ""`
          # #coverpoint-2-2

          if ! scn.no_unparsed_exists
            x = scn.head_as_is
            ! x or BLANK_RX_ =~ x
          end
        end,

        :on_entry, -> sm do

          # (we could change the grammar if we wanted to eliminiate the contitional)

          if sm.downstream
            stay = sm.downstream.__receive_notification_of_blank_line_
            sm.send_downstream
          else
            # another part of #coverpoint-2-5
            stay = true
          end

          if stay
            :after_section
          else
            :early_ending
          end
        end,
      )

      o.add_state( :line_with_header,

        :entered_by_regex,
          /\A (?<hdr> [a-z]+ ): [[:space:]]+ (?<rest> .+) $/ix,

        :on_entry, -> sm do

          sm.send_any_previous_and_reinit_downstream

          md = sm.user_matchdata
          ds = sm.downstream

          ds.receive_header md[ :hdr ]
          _stay = ds.receive_content_line md[ :rest ]
          if _stay
            :after_common_section_line
          else
            sm.send_downstream  # #coverpoint-2-7
            :early_ending
          end
        end,
      )

      o.add_state( :dedicated_header_line,

        :entered_by_regex,
          /\A (?<hdr> [a-z]+ ):? $/ix,

        :on_entry, -> sm do

          sm.send_any_previous_and_reinit_downstream

          sm.downstream.receive_header sm.user_matchdata[ :hdr ]
          :after_dedicated_header_line
        end,
      )

      # #todo - above state and below should be merged (look at them)

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
          ) $/ix,

        :on_entry, -> sm do

          _stay = sm.downstream.receive_content_line sm.user_matchdata[ :content ]
          if _stay
            :after_common_section_line
          else
            sm.send_downstream
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
        :on_entry, -> _sm do
          self._THIS_CHANGED__do_it_earlier__  # #tombstone-A
        end,
      )

      o.add_state( :ending,
        :entered_by, -> _st do

          # any state that indicated this as a possible next
          # state may enter without barrier from this state

          :_trueish_
        end,

        :on_entry, -> sm do
          sm.receive_end_of_solution  # declare that you have no next state
        end,
      )

      o.finish
    end

    #===

      # ==

      class Section___

        def initialize choices

          @__header_mutex = nil
          @number_of_synopsis_lines = choices.number_of_synopsis_lines
          @_receive_content_line = :__receive_content_line_while_recording
          @_target_header_symbol = choices.
            section_header_symbols_in_order_of_preference.first

          @N_content_lines = []
        end

        def receive_header content_s
          remove_instance_variable :@__header_mutex
          @header_symbol = content_s.downcase.intern
            # downcasing above is #coverpoint-2-6
          NIL
        end

        def receive_content_line content_s

          # (when this is the (tail) content of a usage line, note that it
          # is not including the (head) of the header. out of context such
          # a line might look confusing, depending on the context. and there
          # is no further structured categorization (for now) to tell us that
          # this is such a line..)

          send @_receive_content_line, content_s
        end

        def __receive_content_line_while_recording content_s

          # assume we want at least one line (:#here-1)

          @N_content_lines.push content_s
          if @number_of_synopsis_lines == @N_content_lines.length

            # (the reason we say "XX" is because the below 4 lines of code
            # are repeated exactly as-is 2x in this document, for stepability
            # ("literality") during development)

            if _is_target_section_XX
              _stop_parsing_XX
            else
              _change_to_pass_thru_mode_XX
            end
          else
            KEEP_PARSING_
          end
        end

        def __receive_notification_of_blank_line_

          # for now, reaching a blank line means that as far as we're
          # concerned the section is closed: even if subsequent lines are
          # actually part of the section proper, they aren't as significant
          # (probably) as the "paragraphs" before them, so we'll allow such
          # an event to "cut off" our memoizing of lines even if the number
          # of lines we have is lower than the cutoff number.
          #
          # indeed this seems to be the least surprising behavior. a help
          # screen designer armed with this knowlege could phrase sections
          # knowing that such a cut-off would happen.
          # :#coverpoint-2-3

          if _is_target_section_XX
            _stop_parsing_XX
          else
            _change_to_pass_thru_mode_XX
          end
        end

        def _is_target_section_XX
          @_target_header_symbol == @header_symbol
        end

        def _change_to_pass_thru_mode_XX
          @_receive_content_line = :__ignore_additional_content_line
          KEEP_PARSING_
        end

        def __ignore_additional_content_line _line

          # if we are not the ideal target section (per our header), we
          KEEP_PARSING_
          # because our ideal target section is yet to come.
        end

        def _stop_parsing_XX
          @is_target_section = true
          @_receive_content_line = :_CLOSED
          STOP_PARSING_
        end

        def finish

          remove_instance_variable :@number_of_synopsis_lines
          remove_instance_variable :@_receive_content_line
          remove_instance_variable :@_target_header_symbol

          @N_content_lines.freeze
          freeze
        end

        attr_reader(
          :header_symbol,
          :is_target_section,
          :N_content_lines,
        )
      end

      # ==

      Require_unstylizers___ = Lazy_.call do
        Styling__ = Home_::CLI::Styling
        NIL
      end

      # ==

      BLANK_RX_ = /\A[[:space:]]*\z/
      FINISH_EARLY_ = :"Skylab::TMX::__finish_early__"
      line = '[^\r\n]*(?:\n|\r\n?)'  # [#sa-002] "line termination sequence"
      MULTIPLE_LINES___ = /\A#{ line }#{ line }/
      STOP_PARSING_ = false

      # ==
    end
  end
end
# #tombstone-A: rewrote half
