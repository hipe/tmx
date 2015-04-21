module Skylab::Snag

  class Models_::Tag

    Actions = THE_EMPTY_MODULE_

    class << self

      def category_symbol
        :tag
      end

      def new_via_symbol symbol, & oes_p

        arg = Tag_::Actors_::Normalize_stem[ symbol, & oes_p ]
        arg and begin
          new arg.value_x
        end
      end
    end  # >>

    def initialize sym
      @_sym = sym
    end

    def category_symbol
      :tag
    end

    def intern
      @_sym
    end

    define_method :express_into_under, EXPRESS_INTO_UNDER_

    module Expression_Adapters
      EN = nil
      Autoloader_[ self ]
    end

    Tag_ = self
  end
end
