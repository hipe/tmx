module Skylab::TMX

  class Models_::Attribute

    class Index

      def initialize mod

        formals = []
        hum_h = {}
        sym_h = {}

        mod.constants.each do |const|

          name = Common_::Name.via_const_symbol const

          _proto_x = mod.const_get const, false

          attr = Here_.new _proto_x, name

          d = formals.length
          hum_h[ name.as_human ] = d
          sym_h[ name.as_lowercase_with_underscores_symbol ] = d
          formals.push attr
        end

        @_formal_attributes = formals
        @_formal_via_human = hum_h
        @_formal_via_normal_symbol_hash = sym_h
      end

      def levenshtein k, & emit

        attrs = @_formal_attributes

        emit.call :error, :expression, :parse_error, :unknown_attribute do |y|

          _st = Stream_.call attrs do |attr|
            attr.name
          end

          _stringify_by = -> name do
            name.as_lowercase_with_underscores_string
          end

          say_attr = method :say_formal_attribute_

          _s_a = Home_.lib_.human::Levenshtein.with(
            :item_string, k.id2name,
            :items, _st,
            :stringify_by, _stringify_by,
            :map_result_items_by, say_attr,
            :closest_N_items, 3,
          )

          _eew = Common_::Name.via_variegated_symbol k

          _first_sentence = "unrecognized attribute \"#{ say_attr[ _eew ] }\"."
          _second_sentence = "did you mean #{ Common_::Oxford_or[ _s_a ] }?"

          y << "#{ _first_sentence } #{ _second_sentence }"
        end

        UNABLE_
      end

      def has_via_human hum
        @_formal_via_human[ hum ]
      end

      def formal_via_normal_symbol k
        d = @_formal_via_normal_symbol_hash[ k ]
        if d
          @_formal_attributes.fetch d
        end
      end
    end

    # ==

    Here_ = self
    class Here_

      def initialize proto_x, name
        @name = name
        @PROTOTYPE_X = proto_x  # we want to build it here
      end

      attr_reader(
        :name,
      )
    end
  end
end
