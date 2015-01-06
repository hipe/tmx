module Skylab::Cull

  class Models_::Function_ < Model_

    class << self

      def unmarshal s, & oes_p
        Function_::Unmarshal__.new( & oes_p ).unmarshal s
      end

      def unmarshal_via_string_and_module s, mod, & oes_p
        Function_::Unmarshal__.new( & oes_p ).unmarshal_via_call_expression_and_module s, mod
      end
    end  # >>

    def initialize args, defined_function, category_symbol
      @category_symbol = category_symbol
      @composition = Composition__.new args, defined_function
    end

    def members
      [ :category_symbol, :composition, :const_string ]
    end

    def marshal
      "#{ @category_symbol }:#{ __name_as_slug }#{ __any_args_string }"
    end

    attr_reader :category_symbol, :composition

    def __name_as_slug
      Callback_::Name.via_const( const_string ).as_slug
    end

    def const_string
      @composition.defined_function.name
    end

    def __any_args_string
      args = @composition.args
      if args && args.length.nonzero?
        "(#{
          args.map do | x |
            if x.respond_to? :ascii_only?
              if RX___ =~ x
                "\"#{ x.gsub '"', '\"' }\""  # #todo bug re: a literal `\` in string
              else
                x
              end
            else
              x
            end
          end * ", "
        })"
      end
    end

    RX___ = /[\(\)\[\],"]/

    def [] ent, & oes_p
      @composition.defined_function[ ent, * @composition.args, & oes_p ]
    end

    Function_ = self
    Composition__ = ::Struct.new :args, :defined_function
  end
end
