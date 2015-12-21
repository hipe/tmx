module Skylab::Basic

  class List::Classifier  # [#054]..

    # .. the acutal algorithm is described in [#gv-026] where (in this
    # universe) it originated. what is here is a stub..
    #
    # the synopsis is that `symbols` is a array of symbols arranged in some
    # meaninful order (for exmaple `[:low, :medium, :high]`), and `actuals`
    # is an array of floats (e.g integers). the result is an array the
    # length of the `actuals` whose each value is a symbol from `symbols`
    # that classifies the value in actuals, for example:
    #
    #     #open [#ts-046] this is a perfect use-case for d.t
    #     ..when this happens consider going back to [#gv-026] and folding
    #     this back in.

    attr_writer(
      :actuals,
      :symbols,
    )

    def execute

      __init_index
      ___apply_index
    end

    def ___apply_index

      @actuals.map do | value |
        ___classification_for value
      end
    end

    def ___classification_for value

      # find the first classification whose ideal value is greater than
      # the argument value (we could do a b-tree but meh) ..

      c8n = @_index.detect do | node |
        node.ideal_value > value
      end

      if c8n
        d = c8n.index
        if d.zero?  # if it was the first classification you're sure it's right
          c8n.symbol
        else
          self._K
        end
      else
        # because ideal values are in the "middle" of the segment, there
        # will always be at least one guy that is here..
        @_index.last.symbol
      end
    end

    def __init_index

      # based only on the lowest and highest points of the distribution
      # (the min and the max), ascertain an "ideal value" for each
      # classification ..

      if @actuals.length.zero?
        self._COVER_ME
      end

      distribution_a = @actuals.uniq.sort!
      min = distribution_a.first
      max = distribution_a.last
      if min == max
        self._COVER_ME
      end

      height = max - min

      num_symbols = @symbols.length

      _distance_per_symbol = 1.0 * height / num_symbols

      half_height_of_symbol = _distance_per_symbol / 2

      wasteful_search = ::Array.new num_symbols

      num_symbols.times do | d |

        wasteful_search[ d ] = Wasteful_Node___.new(
          min + ( height * d / num_symbols ) + half_height_of_symbol,
          d,
          @symbols.fetch( d ),
        )
      end

      @_index = wasteful_search ; nil
    end

    Wasteful_Node___ = ::Struct.new :ideal_value, :index, :symbol
  end
end
