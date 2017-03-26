self._NOT_USED  # #open [#064] not used but would be fun to use again -

  begin

    # this was employed somewhere long ago to select one message from a
    # list of possible messages in a "diminishing pool" manner, giving
    # some semblance of originality..
    #
    # the idea is that it selects one item from a list of items "randomly",
    # and when that item is produced it is removed from the pool.
    #
    # it looks like whatever item was positioned last in the argument pool
    # stays last (maybe), and so when the rest of the pool is exhausted,
    # this last item is produced repeatedly and infinitely for each next
    # call.
    #
    # if memory serves, it was employed because there was a list of
    # comical phrases to use for some situation, and it got really
    # mechanistic when you would here the same comical phrases *in the same
    # order*, every time.
    #
    # interesting enhancements to this might include segmented weighted
    # categories, so for example there was always one item or one category
    # of items that would be selected from first, and then a second tier
    # and so on..

  end

module Skylab::Human

  module NLP::EN::Tricks
  end

  module NLP::EN::Tricks::Cycle
  end

  NLP::EN::Tricks::Cycle::Terminal = -> do
    -> arr, param_h=nil do
      rand = nil
      if param_h
        param_h_h = { rand: -> v { rand = v } }
        param_h.each { |k, v| param_h_h.fetch( k )[ v ] }
      end
      pool_a = arr.length.times.to_a
      if rand
        x = rand < 0 ? 0 : [ rand, arr.length ].min
        pool_a[ 0, x ] = x.times.to_a.shuffle
      end
      if pool_a.length.zero?
        gets = -> { }
      else
        current = 0
        last = pool_a.length - 1
        gets = -> do
          res = arr.fetch pool_a.fetch current
          if current == last
            idx = pool_a.fetch current
            gets = -> do
              arr.fetch idx
            end
          else
            current += 1
          end
          res
        end
      end
      -> do
        gets[]
      end
    end
  end.call
end
