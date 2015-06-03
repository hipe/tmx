module Skylab::Brazen

  Concerns_::Name = ::Class.new ::Class.new Callback_::Name

  class Concerns_::Name  # :[#005]

    class << self

      def name_with_parent_class
        Name_with_Parent__
      end

      def surrounding_module mod
        LIB_.module_lib.value_via_relative_path mod, DOT_DOT_
      end
    end  # >>

    Build_full_name_function = -> mod do

      nf = mod.name_function
      y = [ nf ]
      begin
        parent = nf.parent
        parent or break
        nf = parent.name_function
        nf or break
        y.unshift nf
        redo
      end while nil
      y.freeze
    end

    NAME_FUNCTION_METHOD___ = -> do
      @name_function ||= Build_name_function[ self ]  # :+#public-API (ivar name)
    end

    module Build_name_function ; class << self  # infects upwards

      def [] mod

        stop_index = __some_name_stop_index mod

        s_a = mod.name.split CONST_SEP_
        sym = s_a.pop.intern

        chain = LIB_.module_lib.chain_via_parts s_a
        d = chain.length

        while stop_index < ( d -= 1 )  # find nearest relevant parent

          pair = chain.fetch d
          mod_ = pair.value_x

          if ! mod_.respond_to? :name_function

            if TAXONOMIC_MODULE_RX___ =~ pair.name_symbol
              next
            end

            mod.send :define_singleton_method, :name_function, NAME_FUNCTION_METHOD___
          end

          parent = mod_
          break
        end

        mod.name_function_class.new_via mod, parent, sym
      end

      def __some_name_stop_index mod

        if mod.respond_to? :some_name_stop_index

          mod.some_name_stop_index

        elsif mod.const_defined? :NAME_STOP_INDEX

          mod::NAME_STOP_INDEX
        else
          DEFAULT_STOP_INDEX___
        end
      end
    end ; end

    DEFAULT_STOP_INDEX___ = 3  # skylab snag cli actions foo actions bar

    TAXONOMIC_MODULE_RX___ = /\AActions_{0,2}\z/  # meh / wee

    # ~ as class

    def _init_via_three cls, parent, const_i

      @class_ = cls
      super
    end

    attr_reader :class_

    def inflected_noun
      _inflection.inflected_noun
    end

    def noun_lexeme
      _inflection.noun_lexeme
    end

    def _inflection
      @___inflection ||= Brazen_::Concerns_::Inflection.for_model self
    end

    Name_with_Parent__ = superclass
    class Name_with_Parent__

      class << self

        def new_via mod, parent, const

          new do
            _init_via_three mod, parent, const
          end
        end
      end  # >>

      def _init_via_three _mod, parent, const

        @parent = parent
        init_via_const const
      end

      attr_reader :parent
    end
  end
end
