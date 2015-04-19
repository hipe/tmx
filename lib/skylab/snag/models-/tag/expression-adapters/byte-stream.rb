module Skylab::Snag

  class Models_::Tag

    Expression_Adapters = ::Module.new

    module Expression_Adapters::Byte_Stream

      class << self

        def express_into_under_of_ y, expag, tag
          y << "#{ HASHTAG_PREFIX___ }#{ tag.intern }"  # :+[#007]
          NIL_
        end
      end  # >>

      HASHTAG_PREFIX___ = '#'

      Models_ = ::Module.new

      class Models_::Tag < Snag_::Models_::Tag

        # so we can have fast scanning of hashtags but still leverage
        # the arbitrary business methods of our parent (all from the
        # same object), experimentally we duplicate some code from [#056]

        def initialize
          @value_is_known = nil
        end

        def _reinitialize * a
          @_begin, @_length, @_string = a
          NIL_
        end

        attr_reader :_begin, :_string

        include Snag_::Models::Hashtag::Possibly_with_Value_Methods

        def intern
          if @value_is_known
            @_string[ @_begin + 1 ... @_name_r.end ]
          else
            @_string[ @_begin + 1, @_length - 1 ].intern
          end
        end
      end
    end
  end
end
