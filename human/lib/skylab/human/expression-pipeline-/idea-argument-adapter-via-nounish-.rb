module Skylab::Human

  module ExpressionPipeline_

    class IdeaArgumentAdapter_via_Nounish_ < Common_::SimpleModel

      # ==

      module Subject ; class << self
        def via__argument_scanner__ scn
          Self_.define do |o|
            o.role_symbol = :subject
            o._interpret scn
          end
        end
      end ; end

      # ==

      module Object ; class << self
        def via__argument_scanner__ scn
          Self_.define do |o|
            o.role_symbol = :object
            o._interpret scn
          end
        end
      end ; end

      # ==

      class << self
        def via_array
          Self_.define do |o|
            o.role_symbol = :_neither_
            o._init_via_array a
          end
        end
      end  # >>

      # -

        attr_writer(
          :role_symbol,
        )

        def _interpret scn

          x = scn.gets_one

          if x.respond_to? :id2name
            :adjectivial == x or raise ::ArgumentError
            @is_adjectivial = true

            x = scn.gets_one
          end

          if x.respond_to? :each_with_index
            _init_via_array x

          elsif x.respond_to? :ascii_only?
            init_via_string x

          elsif x.respond_to? :bit_length
            __init_via_integer x

          else
            raise ::ArgumentError
          end
        end

        def _init_via_array a

          extend Array_Methods___
          @to_array = a
          @received_shape = :list
          NIL_
        end

        def init_via_string s
          class << self
            attr_reader :to_string
          end
          @to_string = s
          @received_shape = :atom
          NIL_
        end

        def __init_via_integer d

          extend Integer_Methods___
          @to_integer = d
          @received_shape = :count
          NIL_
        end

        # -- read

        def slot_symbol
          :"#{ @role_symbol }_#{ @received_shape }"
        end

        attr_reader(
          :is_adjectivial,
          :role_symbol,
        )

      # ==

        module Array_Methods___

          def quad_count_category
            Quad_category_via_integer_[ @to_array.length ]
          end

          def to_stream
            Stream_[ @to_array ]
          end

          attr_reader :to_array
        end

      # ==

        module Integer_Methods___

          def quad_count_category
            Quad_category_via_integer_[ @to_integer ]
          end

          attr_reader :to_integer
        end

      # ==

        Quad_category_via_integer_ = -> d do

          if 0 > d
            :negative
          else
            case d
            when 0
              :none
            when 1
              :one
            when 2
              :two
            else
              :more_than_two
            end
          end
        end

        Self_ = self
      # -
    end
  end
end
