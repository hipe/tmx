module Skylab::MetaHell

  module Parse

    module Function_

      class Field

        class << self

          # ~ narrative (not alpha) order

          def new_via_arglist a
            st = Callback_::Iambic_Stream.via_array a
            x = new_via_iambic_stream_passively st
            st.unparsed_exists and raise ::ArgumentError, st.current_token
            x
          end

          def new_via_iambic_stream_passively st  # :+#push-up-candidate to [cb]
            ok = nil
            x = new do
              ok = process_iambic_stream_passively st
            end
            ok && x
          end

          # ~ others

          def __function_category_symbol
            @__fcs ||= Callback_::Name.via_module( self ).as_lowercase_with_underscores_symbol
          end

          def __function_supercategory_symbol
            :field
          end

        end  # >>

        Callback_::Actor.methodic self

        def initialize & edit_p  # necessary #hook-in when using [cb] methodic
          @moniker_symbol = nil
          instance_exec( & edit_p )
        end

      private

        def moniker_symbol=  # a "moniker" is a name that has zero imapct on logic - it is for humans only
          @moniker_symbol = iambic_property
          KEEP_PARSING_
        end

      public

        def moniker
          @__did_resolve_moniker_name_function ||= begin
            @__mnf = if @moniker_symbol
              Callback_::Name.via_variegated_symbol @moniker_symbol
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
      end
    end
  end
end
