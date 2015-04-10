module Skylab::Snag

  class Models_::Tag

    Actions = THE_EMPTY_MODULE_

    class << self

      def new_via_symbol symbol, & oes_p

        arg = Tag_::Actors_::Normalize_stem[ symbol, & oes_p ]
        arg and begin
          new arg.value_x
        end
      end
    end  # >>

    -> do
      x = :tag
      define_singleton_method :business_category_symbol do
        x
      end
      define_method :business_category_symbol do
        x
      end
    end.call

    def via_tag_position_and_tag_ d, hashtag_s
      @intern = hashtag_s[ 1 .. -1 ].intern
      self
    end

    def initialize sym  # the above method is the flyweight counterpart to this
      @intern = sym
      NIL_
    end

    attr_reader :intern

    def express_into_under y, expag

      Expression_Adapters.const_get(
        expag.modality_const, false )[ y, expag, self ]

      NIL_
    end

    def nonterminal_symbol
      # because we pass ourselves as the flyweight, we have to accord to
      # the hashtag parser. but we can result in nil.

      NIL_
    end

    Expression_Adapters = ::Module.new

    Expression_Adapters::Byte_Stream = -> y, expag, tag do
      y << "#{ HASHTAG_PREFIX___ }#{ tag.intern }" # :+[#007]
      NIL_
    end

    HASHTAG_PREFIX___ = '#'

    Tag_ = self
  end
end
