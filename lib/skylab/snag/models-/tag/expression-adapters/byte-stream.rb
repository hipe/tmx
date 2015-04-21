module Skylab::Snag

  class Models_::Tag

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
          @value_is_known = @value_is_known_is_known = nil
        end

        def initialize_copy _
          NIL_  # just saying hello - nothing to do
        end

        def get_string
          @_string[ @_begin, @_length ]
        end

        def intern
          if @value_is_known
            self._NOT_COVERED_YET
          else
            @_string[ @_begin + 1, @_length - 1 ].intern
          end
        end

        attr_reader :_name_r, :_value_r

        attr_accessor :_begin, :_length, :_string

        include Snag_::Models::Hashtag::Possibly_with_Value_Methods
      end
    end
  end
end
