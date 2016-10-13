module Skylab::Snag

  class Models_::To_Do

    class Actors_::To_do_stream_via_matching_line_stream < Common_::Actor::Dyadic

      def initialize st, psa, & p
        @on_event_selectively = p
        @pattern_s_a = psa
        @st = st
      end

      def execute

        _ok = __resolve_platform_regex
        _ok && __via_platform_regex
      end

      def __resolve_platform_regex

        ok = true
        rx_s_a = ::Array.new @pattern_s_a.length

        @pattern_s_a.each_with_index do | s, d |

          rx_s = Rx_Lib__.string_via_grep_string s, & @on_event_selectively
          if rx_s
            rx_s_a[ d ] = rx_s
          else
            ok = rx
            break
          end
        end

        if ok

          @rx = ::Regexp.new( rx_s_a * PIPE_ )
          ACHIEVED_
        else
          ok
        end
      end

      def __via_platform_regex

        rx = @rx

        @st.expand_by do | line_o |

          _st = Rx_Lib__.stream_of_matches line_o.full_source_line, rx

          md_a = _st.to_a

          case 1 <=> md_a.length
          when 0, -1
            __stream_via_one_or_more_matches md_a, line_o.dup.freeze
          when 1
            __when_no_matches line_o
          end
        end
      end

      def __when_no_matches line_o

        @on_event_selectively.call :info, :did_not_match do
          __build_did_not_match_event line_o
        end
      end

      def __build_did_not_match_event line_o

        Common_::Event.inline_neutral_with :did_not_match,
            :line, line_o.full_source_line,
            :lineno, line_o.lineno,
            :path, line_o.path,
            :pattern, ( @pattern_s_a * PIPE_ ),  # meh
            :rx, @rx do | y, o |

          y << "skipping a line that matched via `grep` but #{
           }did not pass our internal regexp (#{
            }#{ pth o.path }:#{ o.lineno })"

          y << "line: #{ o.line }"
          y << "find pattern: #{ val o.pattern }"
          y << "internal regexp: #{ o.rx.inspect }"
        end
      end

      def __stream_via_one_or_more_matches md_a, shared_line_o

        # each match that has a match after it has to know where the after
        # it match starts so that it can report that it ends there, yeah?
        #
        # the matches come at us from left to right on the line, so start
        # with the last match (the one with none after it) and build it.
        # then with each match to the left of the current one, build it
        # via passing the item that came to its right.
        #
        # add each item that is built in the above to a stack. the reverse
        # of this stack (as a stream) is our result. whew!

        st = Common_::Stream.via_range( md_a.length - 1 .. 0 )

        item = __item_via_match md_a.fetch( st.gets ), shared_line_o

        stack = [ item ]
        begin

          d = st.gets
          d or break
          item = __item_via_match item, md_a.fetch( d ), shared_line_o
          stack.push item
          redo
        end while nil

        stack.reverse!
        Common_::Stream.via_nonsparse_array stack
      end

      def __item_via_match greater_neighbor=nil, md, my_line_o

        d = _index_of_matched_body_capture md
        body_begin, body_end = md.offset d
        header_begin, header_end = md.offset( d - 1 )

        Home_::Models_::To_Do.new do | o |

          o.accept_matching_line my_line_o
          o.accept_header_range header_begin, header_end
          o.accept_body_range body_begin, body_end

          if greater_neighbor
            o.accept_ending_of_message greater_neighbor.beginning_of_header
          end
        end
      end

      def _index_of_matched_body_capture md

        # NOTE this assume the regex's captures happen in pairs (head, body..)

        d = 2
        begin
          d_, = md.offset d
          d_ and break
          d += 2
          redo
        end while nil
        d
      end

      Rx_Lib__ = Home_.lib_.basic::Regexp
    end
  end
end
