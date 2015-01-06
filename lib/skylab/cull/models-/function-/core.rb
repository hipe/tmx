module Skylab::Cull

  class Models_::Mutator < Model_

    @after_name_symbol = :upstream

    Actions = ::Module.new

    class Actions::List < Action_

      # ~ ick for now

      def formal_properties
        nil
      end

      def any_formal_property_via_symbol sym
        nil
      end

      # end ick

      def produce_any_result
        Callback_.stream.via_nonsparse_array Mutator_::Items__.constants do | const_i |
          Callback_::Name.via_const const_i
        end
      end
    end

    Autoloader_[ ( Items__ = ::Module.new ), :boxxy ]

    Mutator_ = self

  class FUNCTION

    class << self

      def unmarshal s, & oes_p
        Mutator_::Models__::Unmarshal.new( & oes_p ).unmarshal s
      end

      def unmarshal_via_string_and_module s, mod, & oes_p
        Mutator_::Models__::Unmarshal.new( & oes_p ).unmarshal_via_call_expression_and_module s, mod
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

    Composition__ = ::Struct.new :args, :defined_function
  end
  end
end
