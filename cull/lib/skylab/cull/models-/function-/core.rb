module Skylab::Cull

  class Models_::Function_ < Model_

    # :+[#br-013]:API.A trailing underscore = not part of reactive model tree)

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
      @p = method :__first_call
    end

    def members
      [ :category_symbol, :composition, :const_symbol ]
    end

    def marshal
      "#{ @category_symbol }:#{ __name_as_slug }#{ __any_args_string }"
    end

    attr_reader :category_symbol, :composition

    def __name_as_slug
      _name.as_slug
    end

    def const_symbol
      _name.as_const
    end

    def _name
      @nm ||= Callback_::Name.via_module @composition.defined_function
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
      @p[ ent, & oes_p ]
    end

    def __first_call ent, & oes_p

      p = @composition.defined_function
      a = @composition.args

      if a
        @p = p.curry[ * a ]
      else
        @p = p
      end

      @p[ ent, & oes_p ]
    end

    Function_ = self
    Composition__ = ::Struct.new :args, :defined_function
  end
end
