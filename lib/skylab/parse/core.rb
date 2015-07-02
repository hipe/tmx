require_relative '..'
require 'skylab/callback/core'

module Skylab::Parse  # see [#001]

  # ->

    class << self

      def alternation
        Home_::Alternation__
      end

      def function sym
        Home_::Functions_.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const,
          false )
      end

      alias_method :function, :function

      def function_via_definition_array x_a
        st = Callback_::Polymorphic_Stream.via_array x_a
        function( st.gets_one ).new_via_polymorphic_stream st
      end

      def fuzzy_matcher * a
        Home_::Functions_::Keyword.new_via_arglist( a ).to_matcher
      end

      def input_stream
        Home_::Input_Stream_
      end

      def lib_
        @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
          Lib___, self )
      end

      def output_node
        Home_::Output_Node_
      end

      def parse_serial_optionals * a
        Home_::Functions_::Serial_Optionals.parse_via_highlevel_arglist a
      end

      def via_set
        Home_::Via_Set__
      end
    end  # >>

    Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

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
      end  # >>

      Autoloader_[ self ]
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

    module Lib___

      Basic = Autoloader_.build_require_sidesystem_proc[ :Basic ]

      Stdlib_set = Autoloader_.build_require_stdlib_proc[ :Set ]
    end

    Autoloader_[ self ]

    EMPTY_A_ = [].freeze
    KEEP_PARSING_ = true
    NIL_ = nil
    Home_ = self
    UNABLE_ = false

  # <-
end
