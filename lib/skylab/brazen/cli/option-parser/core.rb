module Skylab::Brazen

  class CLI

    module Option_Parser

      class << self

        def summary_width _, __
          Summary_width___[ _, __ ]
        end
      end  # >>

      # <-

    left_peeker_hack = -> summary_width do     # i'm sorry -- there was no
      max = summary_width - 1                  # other way
      sdone = {} ; ldone = {}
      -> x, &y do
        sopts, lopts = [], []   # short and long opts that have not been done
        if x.short
          x.short.each { |s| sdone.fetch(s) { sopts.push s ; sdone[s] = true } }
        end
        if x.long
          x.long.each  { |s| ldone.fetch(s) { lopts.push s ; ldone[s] = true } }
        end
        if sopts.length.nonzero? || lopts.length.nonzero?
          left = [sopts.join(', ')]
          lopts.each do |s|
            l = left.last.length + s.length
            l += x.arg.length if 1 == left.length && x.arg
            l >= max and sopts.length.nonzeor? and
              left << EMPTY_S_
            _sep = left.last.length.zero? ? ( TERM_SEPARATOR_STRING_ * 4 ) :
              ', '
            left.last << _sep << s
          end
          x.arg and left.first.concat(
            left[1] ? "#{ x.arg.sub(/\A(\[?)=/, '\1') }," : x.arg )
          left.each { |s| y.call s }
        end
        nil
      end
    end

    Summary_width___ = -> option_parser, max=0 do

      # find the width of the widest content that will
      # go in column A in the help screen of this o.p

      left_peek = left_peeker_hack[ option_parser.summary_width ]

      _st = CLI_::Option_Parser::Option_stream[ option_parser ]

      _st.each.reduce max do | m, x |

        if x.respond_to? :summarize

          left_peek.call x do | s |

            if m < s.length
              m = s.length
            end
          end
        end

        m
      end
    end

    # ->

      TERM_SEPARATOR_STRING_ = SPACE_
    end
  end
end
# :#tombstone: ncurses
