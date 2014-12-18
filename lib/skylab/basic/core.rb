require_relative '../callback/core'

module Skylab::Basic  # introduction at [#020]

  class << self

    def default_property
      Default_property_instance__[]
    end

    def _lib
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def minimal_property name
      Minimal_Property__.new name
    end

    def normalizers
      Normalizers_instance__[]
    end

    def trio * x_a
      if x_a.length.zero?
        Trio_
      else
        Trio_.new( * x_a )
      end
    end
  end

  Callback_ = ::Skylab::Callback

  Default_property_instance__ = Callback_.memoize do
    Minimal_Property__.via_variegated_symbol :argument
  end

  class Minimal_Property__

    class << self

      def via_variegated_symbol i
        new Callback_::Name.via_variegated_symbol i
      end
    end

    def initialize name
      @name = name
      freeze
    end

    attr_reader :name

    def name_i
      @name.as_variegated_symbol
    end

    def description
      "« #{ @name.as_slug } »"  # :+#guillemets
    end
  end

  Normalizers_instance__ = Callback_.memoize do

    class Normalizers__

      _MEMBERS = [ :number, :pathname, :range ].freeze

      define_method :members do
        _MEMBERS.dup
      end

      _MEMBERS.each do |i|
        _CONST = Callback_::Name.via_variegated_symbol( i ).as_const
        define_method i do | * a |
          if a.length.zero?
            Basic_.const_get( _CONST, false ).normalization
          else
            Basic_.const_get( _CONST, false ).normalization.via_arguments a
          end
        end
      end

      self
    end.new
  end

  class Trio_  # :[#038].

    class << self

      def via_value_and_variegated_symbol x, i
        new x, true, Minimal_Property__.via_variegated_symbol( i )
      end

      alias_method :via_x_and_i, :via_value_and_variegated_symbol

    end

    def initialize * a
      @value_x, @actuals_has_name, @property = a
      freeze
    end

    attr_reader :value_x, :actuals_has_name, :property

    attr_writer :value_x

    def members
      [ :actuals_has_name, :property, :name_i, :name, :value_x ]
    end

    def name_i
      @property.name_i
    end

    def name
      @property.name
    end
  end

  Autoloader_ = Callback_::Autoloader
  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true
  Basic_ = self
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  IDENTITY_ = -> x { x }
  KEEP_PARSING_ = true
  MONADIC_EMPTINESS_ = -> _ {}
  MONADIC_TRUTH_ = -> _ { true }
  NILADIC_FALSEHOOD_ = -> { false }
  PROCEDE_ = true
  UNABLE_ = false

end
