module Skylab::MetaHell

  module Parse

    module Fields__

      Exponent = MetaHell_.lib_.struct_lib.new :i, :long, :short, :first_desc_line

      # the term 'exponent' is meant in the "Grammatical_category" sense.
      # similar but not the same as a flag. this was early-abstracted
      # out of one project and is #experimental

      class Exponent

        def p
          long = Fm_[ @long ]
          short = @short ? -> tok { @short == tok } : MONADIC_EMPTINESS_
          -> r, a do
            if a.length.nonzero? and
                ( (( long[ tok = a.first ] )) or short[ tok ] )
              a.shift
              @i and r[ @i ] = true
              true
            end
          end
        end
        Fm_ = Fuzzy_matcher_.curry[ 1 ]  # min length

        def name_monikers y
          y << @long.inspect
          @short and y << @short.inspect
          y
        end

        def with_each_desc_line &blk
          if @first_desc_line
            blk[ "#{ @long } - #{ @first_desc_line }" ]
          elsif @i && @long
            blk[ "#{ @long } - #{ @long.gsub '-', ' ' }." ]  # #hack-alert
          end
          nil
        end
      end
    end
  end
end
