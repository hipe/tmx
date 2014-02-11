module Skylab::TestSupport

  module Regret

    module CLI::Actions

      module DocTest

        RegretLib_ = Regret::API::RegretLib_

        Parse_Recursive_ = RegretLib_::Struct[ :y, :v, :argv ]

        # the things we do for love. **necessary** to support argv's like:
        #
        #   foo -r   some-path     # ordinary recursive
        #   foo -rn  some-path     # dry run
        #   foo -r n some-path     # same
        #   foo -r list list       # e.g use the "list" sub-opt on path "list"
        #

        class Parse_Recursive_

          Lib_::Funcy[ self ]

          def execute
            if @argv.length.nonzero?
              did = P_[ @v, @argv ]
              if ! did && (( t = @argv[ 0 ] )) && REST_RX_.match( t )
                if P_[ @v, [ $~[:stem] ] ]
                  @argv.shift
                else
                  @v[ :did_error ] = true
                  @y << "did not recognize \"#{ t }\" as a valid argument #{
                  }to -r (expected #{
                  }#{ Or_[ A_.reduce [] { |m, fld| fld.name_monikers m }]}#{
                  }). if you intended \"#{ t }\" as other option(s), please#{
                  } use \"--\" to sepearate them from -r."
                  @argv.shift  # it may or may not be a valid option - but
                    # just in case, this way we avoid triggering 2 notices
                end
              end
            end
            nil
          end

          o = RegretLib_::Field_exponent_proc[]

          A_ = [ o[ :do_list, 'list', nil, "just list the files" ],
                 o[ :do_check, 'check', nil, "write to stdout all output" ],
                 o[ :is_dry_run, 'dry-run', 'n' ],
                 o[  nil, '--' ] ]

          P_ = RegretLib_::Parse_alternation[].
            curry[ :pool_procs, A_.map(& :p ) ]

          Or_ = RegretLib_::Oxford_or

          REST_RX_ = /\A-(?<stem>[^-].*)\z/

          Value_ = Regret::API::Lib_::Struct[ :did_error, *
            A_.reduce( [] ) { |m, x| x.i and m << x.i ; m } ]
          class Value_
            def to_i
              @did_error and fail "sanity"
              one = A_.reduce nil do |_, fld|
                fld.i and self[ fld.i ] and break fld.i
              end
              one || :do_execute
            end
          end
        end
      end
    end
  end
end
