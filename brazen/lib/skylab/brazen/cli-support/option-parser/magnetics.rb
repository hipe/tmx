module Skylab::Brazen

  module CLI_Support::Option_Parser

    Magnetics = ::Module.new

    # a hack to see if a basic switch looks to be present in an array
    # build it with the full switch as its only argument:
    #
    #     p = Home_::CLI_Support::Option_Parser::Magnetics::Build_basic_switch_proc[ '--foom' ]
    #
    # if the argv doesn't include it, result is nil:
    #
    #     p[ [ 'abc' ] ]  # => nil
    #
    # if the argv includes a token that matches it partially, result is index:
    #
    #     p[ [ 'abc', '--fo', 'def' ] ]  # => 1
    #
    # but it won't do this fuzzy matching in the other direction:
    #
    #     p[ [ '--foomer', '-fap', '-f', '--foom' ] ]  # => 2

    Magnetics::Build_basic_switch_proc = -> do

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
          if DASH_BYTE_ == tok.getbyte( 0 )  # :[#074.B].
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

    DASH_BYTE_ = '-'.getbyte 0  # 2nd
  end
end
