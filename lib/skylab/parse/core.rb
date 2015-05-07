module Skylab::MetaHell

  module Parse  # read [#011]

    class << self

      def alternation
        Parse_::Alternation__
      end

      def function_ sym
        Parse_::Functions_.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const,
          false )
      end

      alias_method :function, :function_

      def function_via_definition_array x_a
        st = Callback_::Polymorphic_Stream.via_array x_a
        function_( st.gets_one ).new_via_iambic_stream st
      end

      def fuzzy_matcher * a
        Parse_::Functions_::Keyword.new_via_arglist( a ).to_matcher
      end

      def input_stream
        Parse_::Input_Stream_
      end

      def output_node
        Parse_::Output_Node_
      end

      def parse_serial_optionals * a
        Parse_::Functions_::Serial_Optionals.parse_via_highlevel_arglist a
      end

      def via_set
        Parse_::Via_Set__
      end
    end

    module Function_
      Autoloader_[ self ]
    end

    module Functions_
      Autoloader_[ self ]
    end

    module Input_Streams_
      Autoloader_[ self ]
    end

    module Fields__

      class << self

        def exponent
          Fields__::Exponent
        end

        def flag * a
          if a.length.zero?
            Fields__::Flag
          else
            Fields__::Flag.call_via_arglist a
          end
        end
      end

      Autoloader_[ self ]
    end

    NIL_ = nil
    Parse_ = self
  end
end
