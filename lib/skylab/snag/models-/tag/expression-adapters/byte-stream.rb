module Skylab::Snag

  class Models_::Tag

    module Expression_Adapters::Byte_Stream

      class << self

        def express_into_under_of_ y, _expag, tag

          y << "#{ HASHTAG_PREFIX___ }#{ tag.intern }"  # :+[#007]
        end
      end  # >>

      HASHTAG_PREFIX___ = '#'

      Models_ = ::Module.new

      class Models_::Tag < Snag_::Models_::Tag

        # so we can have fast scanning of hashtags but still leverage
        # the arbitrary business methods of our parent (all from the
        # same object), experimentally we duplicate some code from [#056]

        class << self

          def new_via begin_, length, string

            # play nice with hashtag lib. override parent - we keep this info

            new begin_, length, string
          end
        end  # >>

        def reinitialize begin_, length, string

          @_begin = begin_
          @_length = length
          @_string = string

          @value_is_known = nil
          @value_is_known_is_known = nil
        end
        alias_method :initialize, :reinitialize

        def initialize_copy _
          NIL_  # just saying hello - nothing to do
        end

        def get_string
          @_string[ @_begin, @_length ]
        end

        def intern

          if @value_is_known

            @_string[ @_name_r.begin + 1 ... @_name_r.end ].intern
          else
            @_string[ @_begin + 1, @_length - 1 ].intern
          end
        end

        attr_reader :_name_r, :_value_r

        attr_accessor :_begin, :_length, :_string

        include Snag_::Models::Hashtag::Possibly_with_Value_Methods
      end

      BS_ = self
    end
  end
end
