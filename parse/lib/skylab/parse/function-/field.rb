module Skylab::Parse

  # ->

    module Function_

      class Field

        Attributes_actor_[ self ]  # if you change this to add defined
          # attributes, you will have to answer to [#fi-023] in this lib.)

        class << self

          # ~ narrative (not alpha) order

          def new_via_arglist a
            new_via_argument_scanner scanner_via_array a
          end

          # ~ others

          def __function_category_symbol
            @__fcs ||= Common_::Name.via_module( self ).as_lowercase_with_underscores_symbol
          end

          def __function_supercategory_symbol
            :field
          end

          private :new
        end  # >>

        def initialize
          block_given? and self._MODERNIZE_ME
          @moniker_symbol = nil
        end

      private

        def moniker_symbol=  # a "moniker" is a name that has zero imapct on logic - it is for humans only
          @moniker_symbol = gets_one_polymorphic_value
          KEEP_PARSING_
        end

      public

        def moniker
          @__did_resolve_moniker_name_function ||= begin
            @__mnf = if @moniker_symbol
              Common_::Name.via_variegated_symbol @moniker_symbol
            end
            true
          end
          @__mnf
        end

        def function_category_symbol
          self.class.__function_category_symbol
        end

        def function_supercategory_symbol
          self.class.__function_supercategory_symbol
        end

        # ~ #hook-ins (custom implementations for adjunct facets)

        def express_all_segments_into_under y, expression_agent
          mnkr = moniker
          if mnkr
            y << mnkr.as_lowercase_with_underscores_symbol.id2name.upcase
          else
            y << "«#{ function_supercategory_symbol }:#{ function_category_symbol }»"  # :+#guillemets
          end
          nil
        end
      end

      class Field::Proc_Based < Field

        class << self

          def new_via_argument_scanner_passively st
            new_via_proc st.gets_one
          end

          def new_via_proc p
            new( p )
          end
        end

        def initialize p
          @p = p
        end
      end
    end
    # <-
end
