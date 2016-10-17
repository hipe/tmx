module Skylab::TMX

  class Models_::Attribute

    class Index

      def initialize mod

        formals = []
        hu_h = {}

        mod.constants.each do |const|

          proto_x = mod.const_get const, false

          name = Common_::Name.via_const_symbol const

          attr = if proto_x.respond_to? :new
            ClassBasedAttribute___.new proto_x, name
          else
            ProcBasedAttribute___.new proto_x, name
          end

          hu_h[ attr.name.as_human ] = attr

          formals.push attr
        end

        @_formal_attributes = formals
        @_formal_via_human_hash = hu_h
      end

      def formal_via_human hu
        @_formal_via_human_hash[ hu ]
      end

      def levenshtein string, type, & emit
        ::Kernel._K_FUN
        UNABLE_
      end
    end

    # ==

    Here_ = self

    class ClassBasedAttribute___ < Here_

      def initialize cls, name
        @_class = cls
        super name
      end

      def of parsed_node
        @_class.new parsed_node
      end
    end

    # ==

    class ProcBasedAttribute___ < Here_

      def initialize prc, name
        @_proc = prc
        super name
      end

      def of parsed_node
        @_proc.call parsed_node
      end
    end

    # ==

    class Here_
      def initialize name
        @name = name
      end
      attr_reader(
        :name,
      )
    end

    # ==
  end
end
