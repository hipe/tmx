module Skylab::Snag

  class Models_::Tag

    class << self

      def new_via begin_, length, string

        # act like a hashtag - we assume appropriate modality conventions

        new string[
          begin_ + HASHTAG_PREFIX_LENGTH___,
          length - HASHTAG_PREFIX_LENGTH___
        ].intern
      end

      def interpret_for_mutation_session arg_st, & x_p  # :+#ACS-tenet-5

        arg = Tag_::Actors_::Normalize_stem[ arg_st.gets_one, & x_p ]
        arg and begin
          new arg.value_x
        end
      end

      def category_symbol
        :tag
      end

      private :new  # :+#ACS-tenet-1
    end  # >>

    HASHTAG_PREFIX_LENGTH___ = 1

    def initialize sym
      @_sym = sym
      @value_is_known_is_known = nil
    end

    def express_under expag

      Tag_::Expression_Adapters::Byte_Stream.express_into_under_of_(
        "", expag, self )
    end

    def express_into_ y

      # only because expression for the tag under a byte-stream mode needs
      # no assistance from the expression adapter can we do this reach-down
      # but this is fragile, begin wholly dependant on that assumption.

      Tag_::Expression_Adapters::Byte_Stream.express_into_under_of_(
        y, nil, self )
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

    Brazen_ = Home_.lib_.brazen
    Tag_ = self
  end
end
