module Skylab::TMX

  class Models_::Means

    # (purely a specialized session, just for expression)

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize sym, & defn
      @__defn = defn
      @_do = true
      @normal_symbol = sym
    end

    def sayer_under expag
      Sayer___.new expag, self
    end

    def __couple_for_self
      @_do && _do
      @__couple_for_self
    end

    def __couple_for_dependency
      @_do && _do
      @__couple_for_dependency
    end

    def _do
      @_do = false
      _y = ::Enumerator::Yielder.new do |* sym_a |
        @_scn = Common_::Scanner.via_array sym_a
        begin
          send DSL___.fetch @_scn.head_as_is
        end until @_scn.no_unparsed_exists
        NIL
      end
      ( remove_instance_variable :@__defn )[ _y ]
      NIL
    end

    DSL___ = {
      depends_on: :__parse_depends_on,
      is_expressed_as: :__parse_is_expressed_as,
    }

    def __parse_is_expressed_as
      @_scn.advance_one
      @__couple_for_self = Couple__.new( @normal_symbol, @_scn.gets_one )
      NIL
    end

    def __parse_depends_on
      @_scn.advance_one
      _ref_sym = @_scn.gets_one
      k = @_scn.gets_one
      k == :which_is_expressed_as || fail
      @__couple_for_dependency = Couple__.new( _ref_sym, @_scn.gets_one )
      NIL
    end

    attr_reader(
      :normal_symbol,
    )

    # ==

    class Sayer___

      def initialize exp, means
        @expag = exp
        @means = means
      end

      def say_self
        _say_couple @means.__couple_for_self
      end

      def say_dependency
        _say_couple @means.__couple_for_dependency
      end

      def _say_couple coup
        send METHOD___.fetch( coup.manner_symbol ), coup.name
      end

      METHOD___ = {
        human: :__say_human,
        primary: :__say_primary,
      }

      def __say_human name
        name.as_human
      end

      def __say_primary name
        @expag.calculate do
          say_primary_ name
        end
      end
    end

    # ==

    class Couple__

      def initialize sym, manner_sym
        @manner_symbol = manner_sym
        @__normal_symbol = sym
      end

      def name
        @___name ||= Common_::Name.via_variegated_symbol @__normal_symbol
      end

      attr_reader(
        :manner_symbol,
      )
    end
    # ==
  end
end
