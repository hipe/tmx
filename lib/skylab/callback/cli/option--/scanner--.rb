module Skylab::Callback

  module CLI

    module Option__

      module Parser__

        class Scanner__

    # there are others like it, but this one is [#008]. and the best.
    # (in contrast to h.l's [#hl-053] this simply parses e.g an ARGV as
    # opposed to scanning an option parser)

    #         ~ nerpy derpies ~

    # true if the scan pointer is at the end of the argv

    def eos?
      @index > @last
    end

    def last?
      @index == @last
    end

    def current  # assume that there will never be a nil element
      if @index <= @last
        @argv[ @index ]
      end
    end

    #         ~ what does it look like? ~
    -> do

      opt_rx, long_rx =

        Callback_.lib_.CLI_lib.option.values_at :opt_rx, :long_rx

      [ [ :long, -> do
            md = long_rx.match current
            if md  # exploit the fact that nil never matches.
              @opt.replace_with_long_rx_matchdata md
              @opt
            end
          end,
          -> do
            "--long expected, had #{ current.inspect }"
          end ],
        [ :arg, -> do
            x = current
            x if opt_rx !~ current  # might be nil
          end,
          -> do
            "argument expected, had #{ current.inspect }"
          end
      ] ].each do |sym, match, err|

        scn = :"scan_#{ sym }"

        define_method :"expect_#{ sym }" do
          x = send scn
          if x then x else
            @err[ instance_exec(& err ) ]
            false
          end
        end

        mtch = :"looks_like_#{ sym }?"

        define_method scn do
          x = send mtch
          x and @index += 1
          x
        end

        define_method mtch, & match
      end
    end.call

    def initialize argv, err
      @index = 0
      @argv = argv
      @last = argv.length - 1
      @err = err
      @opt = Callback_.lib_.CLI_lib.option.new_flyweight
    end

        end
      end
    end
  end
end
