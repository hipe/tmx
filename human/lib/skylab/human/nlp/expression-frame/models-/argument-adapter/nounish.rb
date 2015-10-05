module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Argument_Adapter

      class Nounish < self

        attr_reader :role_symbol

        module Object

          class << self

            def new_via__polymorphic_upstream__ st
              Nounish._new do
                @role_symbol = :object
                _receive_etc st
              end
            end
          end # >>
        end

        module Subject

          class << self

            def new_via__polymorphic_upstream__ st
              Nounish._new do
                @role_symbol = :subject
                _receive_etc st
              end
            end
          end  # >>
        end

        class << self
          def new_via_array a
            Nounish._new do
              @role_symbol = :_neither_
              _init_via_array a
            end
          end
          alias_method :_new, :new
          private :new
        end  # >

        def slot_symbol
          :"#{ @role_symbol }_#{ @received_shape }"
        end

        attr_reader :is_adjectivial

        def _receive_etc st

          x = st.gets_one

          if x.respond_to? :id2name
            :adjectivial == x or raise ::ArgumentError
            @is_adjectivial = true

            x = st.gets_one
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

        module Array_Methods___

          def quad_count_category
            Quad_category_via_integer_[ @to_array.length ]
          end

          attr_reader :to_array
        end

        module Integer_Methods___

          def quad_count_category
            Quad_category_via_integer_[ @to_integer ]
          end

          attr_reader :to_integer
        end

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

        Nounish_ = self
      end
    end
  end
end
