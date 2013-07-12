module Skylab::Headless

  module CLI::Option

    module FUN::Basic_

      o = FUN_.o

      bsmc = o[:basic_switch_match_curry] = -> do
        rx = /\A--([a-z]).+\z/i
        -> sw do
          md = rx.match( sw ) or raise ::ArgumentError, "no - #{ sw.inspect }"
          short = "-#{ md[1] }".freeze
          long = Headless::Services::Basic::String::FUN.
            string_begins_with_string_curry[ sw ]
          -> argv do
            if argv.length.nonzero? and FUN.starts_with_dash[ argv.fetch 0 ]
              short == (( tok = argv.fetch 0 )) or
                3 <= tok.length && long[ tok ]
            end
          end
        end
      end.call

      o[:basic_switch_scan_curry] = -> x do
        p = bsmc[ x ]
        -> argv do
          if p[ argv ]
            argv.shift
          end
        end
      end
    end
  end
end
