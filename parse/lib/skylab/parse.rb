require 'skylab/common'

module Skylab::Parse  # see [#001]

  # ->

    class << self

      def alternation
        Home_::Alternation__
      end

      def function sym
        Home_::Functions_.const_get(
          Common_::Name.via_variegated_symbol( sym ).as_const,
          false )
      end

      alias_method :function, :function

      def function_via_definition_array x_a
        _scn = Scanner_[ x_a ]
        function( scn.gets_one ).via_argument_scanner _scn
      end

      def fuzzy_matcher * a
        Home_::Functions_::Keyword.via_arglist( a ).to_matcher
      end

      def input_stream
        Home_::Input_Stream_
      end

      def test_support  # #[#ts-035]
        if ! Home_.const_defined? :TestSupport
          require_relative '../../test/test-support'
        end
        Home_::TestSupport
      end

      def lib_
        @lib ||= Common_.produce_library_shell_via_library_and_app_modules(
          Lib___, self )
      end

      def parse_serial_optionals * a
        Home_::Functions_::Serial_Optionals.parse_via_highlevel_arglist a
      end

      def via_set
        Home_::Via_Set__
      end
    end  # >>

    Common_ = ::Skylab::Common
    Autoloader_ = Common_::Autoloader

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

    Attributes_ = -> h do
      Home_.lib_.fields::Attributes[ h ]
    end

    Attributes_actor_ = -> cls, * a do
      Home_.lib_.fields::Attributes::Actor.via cls, a
    end

    Stream_ = Common_::Stream.method :via_nonsparse_array

    Scanner_ = Common_::Scanner.method :via_array

    module Lib___

      sidesys = Autoloader_.build_require_sidesystem_proc

      Basic = sidesys[ :Basic ]
      Fields = sidesys[ :Fields ]

      Stdlib_set = Autoloader_.build_require_stdlib_proc[ :Set ]
    end

    Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

    CLI = nil  # for host
    EMPTY_A_ = [].freeze
    KEEP_PARSING_ = true
    Lib_ = nil # for [sl]
    NIL_ = nil
    Home_ = self
    UNABLE_ = false
  # <-

  def self.describe_into_under y, _
    y << "support for modeling grammars and implementing parsers"
    y << "(used to be used to implement some wacky DSL's)"
  end
end
