module Skylab::Face

  module CLI::Set
    def self.touch ; end  # for loading explicitly and without warning
  end

  class Namespace  # #re-open for facet.
    class << self
      remove_method :set
      def set *a
        @story.absorb_set a
        nil
      end
    end
  end

  class NS_Sheet_  # #re-open
    def absorb_set a
      _xtra_pairs = Services::Basic::Hash::Pair_Enumerator.new a
      absorb_xtra _xtra_pairs
      nil
    end
  end

  class Command  # #re-open
  private
    def process_deferred_set  # assume trueish `@sheet.set_a`
      @sheet.set_a.each do |k, v|  # do *NOT* mutate the set_a here!!
        instance_variable_set :"@#{ k }_value", v
      end
      nil
    end
  end

  class Node_Sheet_
  private
    remove_method :defer_set
    def defer_set i, x
      ( @set_a ||= [ ] ) << [ i, x ]
      nil
    end
  end
end
