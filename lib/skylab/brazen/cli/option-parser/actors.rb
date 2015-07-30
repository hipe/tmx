module Skylab::Brazen

  module CLI::Option_Parser

    Actors = ::Module.new

    # a hack to see if a basic switch looks to be present in an array
    #
    #     p = Home_::CLI::Option_Parser::Actors::Build_basic_switch_proc[ '--foom' ]
    #     p[ [ 'abc' ] ]  # => nil
    #     p[ [ 'abc', '--fo', 'def' ] ]  # => 1
    #     p[ [ '--foomer', '-fap', '-f', '--foom' ] ]  # => 2

    Actors::Build_basic_switch_proc = -> do

      full_basic_switch_match = -> do
        rx = /\A--([a-z]).+\z/i
        -> sw do
          rx.match( sw ) or raise ::ArgumentError, "no - #{ sw.inspect }"
        end
      end.call

      bstmc = -> sw do  # "basic switch token match curry"
        md = full_basic_switch_match[ sw ]
        short = "-#{ md[1] }".freeze

        long = Home_.lib_.basic::String.
          build_proc_for_string_begins_with_string sw

        -> tok do
          if CLI::DASH_BYTE_ == tok.getbyte( 0 )  # :[#074.B].
            short == tok or 3 < tok.length && long[ tok ]
          end
        end
      end

      -> sw do
        match = bstmc[ sw ]
        -> argv do
          argv.index( & match )
        end
      end
    end.call
  end
end
