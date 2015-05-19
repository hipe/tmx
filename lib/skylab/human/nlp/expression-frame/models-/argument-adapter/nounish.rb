module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Argument

      undef_method :to_s

      class Nounish_Argument__ < self

        class << self

          def new_via__polymorphic_upstream__ st

            x = st.gets_one

            _shape_symbol = if x.respond_to? :each_index
              :array
            elsif x.respond_to? :ascii_only?
              :string
            else
              self._FUN
            end

            new do
              send :"__initialize_around__#{ _shape_symbol }__", x
            end
          end

          private :new
        end  # >>

        def initialize & edit_p
          instance_exec( & edit_p )
        end

        attr_reader :shape_category_symbol

        def __initialize_around__array__ x

          extend Methods_for_Array_as_Nounish_Argument___
          __initialize_around_array x
        end

        def __initialize_around__string__ s
          extend Methods_for_String_as_Nounish_Argument___
          __initialize_around_string s
        end
      end

      module Methods_for_Array_as_Nounish_Argument___

        def length
          @_a.length
        end

        def to_a
          @_a
        end

        def shape_category_symbol_
          :list
        end

        def __initialize_around_array a

          @_a = a
          NIL_
        end
      end

      module Methods_for_String_as_Nounish_Argument___

        def to_s
          @__s
        end

        def shape_category_symbol_
          :atom
        end

        def __initialize_around_string s

          @__s = s
          NIL_
        end
      end

      class Object_Argument < Nounish_Argument__

        def term_category_symbol_
          :object
        end
      end

      class Subject_Argument < Nounish_Argument__

        def term_category_symbol_
          :subject
        end
      end
    end
  end
end
