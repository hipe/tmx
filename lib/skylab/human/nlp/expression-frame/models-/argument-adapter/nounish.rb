module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Argument_Adapter

      class Nounish < self

        attr_reader :role_symbol

        module Object

          class << self

            def new_via__polymorphic_upstream__ st
              Nounish.new do
                @role_symbol = :object
                _receive_etc st
              end
            end
          end # >>
        end

        module Subject

          class << self

            def new_via__polymorphic_upstream__ st
              Nounish.new do
                @role_symbol = :subject
                _receive_etc st
              end
            end
          end  # >>
        end

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
            __init_via_array x

          elsif x.respond_to? :ascii_only?
            init_via_string x

          elsif x.respond_to? :bit_length
            __init_via_integer x

          else
            raise ::ArgumentError
          end
        end

        def __init_via_array a

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
          class << self
            attr_reader :to_integer
          end
          @to_integer = d
          @received_shape = :integer
          NIL_
        end

        module Array_Methods___

          def to_atom_argument
            if 1 == @to_array.length
              me = self
              Nounish_.new do
                @role_symbol = me.role_symbol
                init_via_string me.to_array.fetch 0
              end
            end
          end

          def quad_count_category
            case @to_array.length
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

          attr_reader :to_array
        end

        Nounish_ = self
      end
    end
  end
end
