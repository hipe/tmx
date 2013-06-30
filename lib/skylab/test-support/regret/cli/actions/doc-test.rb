module Skylab::TestSupport

  module Regret

    module CLI

      module Actions

        module DocTest

          a = -> do
            y = []
            f = ::Struct.new :i, :parse
            y << f[ :do_check, -> argv do
              rx = /\A#{ ::Regexp.escape argv.fetch 0 }/
              if rx =~ 'check'
                argv.shift
                true
              end
            end ]
            y << f[ :from_path, -> argv do
              if '--' == argv.fetch( 0 ) && 2 <= argv.length
                argv.shift
                argv.shift
              end
            end ]
            y.freeze
          end.call

          Recursive_Field_Values_ = ::Struct.new( * a.map( & :i ) )

          PARSER_ = MetaHell::FUN.parse_from_ordered_set.curry[
            a.map( & :parse ) ]

          Parse_auto_ = -> y, argv, x do
            x and argv.unshift x
            Recursive_Field_Values_[ * PARSER_[ argv ] ]
          end
        end
      end
    end
  end
end
