module Skylab::Headless

  module CLI::Option

    module FUN::Basic_

      o = FUN.redefiner

      full_basic_switch_match = -> do
        rx = /\A--([a-z]).+\z/i
        -> sw do
          rx.match( sw ) or raise ::ArgumentError, "no - #{ sw.inspect }"
        end
      end.call

      bstmc = -> sw do  # "basic switch token match curry"
        md = full_basic_switch_match[ sw ]
        short = "-#{ md[1] }".freeze
        long = Headless::Library_::Basic::String::FUN::
          Build_proc_for_string_begins_with_string[ sw ]
        -> tok do
          if FUN.starts_with_dash[ tok ]
            short == tok or 3 < tok.length && long[ tok ]
          end
        end
      end

      o[:basic_switch_index_curry] = -> sw do
        match = bstmc[ sw ]
        -> argv do
          argv.index( & match )
        end
      end
    end
  end
end
