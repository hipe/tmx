module Skylab::Snag

  class Models_::Tag

    class << self

      def new_via__mixed__ x, & oes_p

        if x.respond_to? :ascii_only?
          x = x.intern
        end

        new_via__symbol__ x, & oes_p
      end

      def new_via__symbol__ symbol, & oes_p

        arg = Tag_::Actors_::Normalize_stem[ symbol, & oes_p ]
        arg and begin
          new arg.value_x
        end
      end

      def category_symbol
        :tag
      end
    end  # >>

    def initialize sym
      @_sym = sym
      @value_is_known_is_known = nil
    end

    def == otr  # assume same cat sym for now

      if @_sym == otr.intern
        if otr.value_is_known_is_known
          self._ETC
        elsif @value_is_known_is_known
          false
        else
          true
        end
      end
    end

    def intern
      @_sym
    end

    def model_class
      self.class
    end

    def category_symbol
      :tag
    end

    include Expression_Methods_

    module Expression_Adapters
      EN = nil
      Autoloader_[ self ]
    end

    Brazen_ = Snag_.lib_.brazen
    Tag_ = self
  end
end
