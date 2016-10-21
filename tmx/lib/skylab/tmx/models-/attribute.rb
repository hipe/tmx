module Skylab::TMX

  class Models_::Attribute

    # ==

    class Index

      def initialize args, mod

        formals = []
        hum_h = {}
        sym_h = {}

        mod.constants.each do |const|

          _class = mod.const_get const, false
          _implementation = _class.new args
          attr = Here_.new _implementation, const
          d = formals.length
          hum_h[ attr.name.as_human ] = d
          sym_h[ attr.normal_symbol ] = d
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

      def initialize impl, const
        @implementation = impl
        @name = Common_::Name.via_const_symbol const
      end

      # -- specific modifiers

      # ~ 'order'

      def plan_for_reorder_via_reorder_request__ reo, & p

        if @implementation.respond_to? REO__
          @implementation.send REO__, reo, & p
        else
          _when_no_implementation REO__, :order, & p
        end
      end

      REO__ = :plan_for_reorder_via_reorder_request

      # --

      def _when_no_implementation m, primary_sym, & emit

        me = self
        emit.call :error, :expression, :parse_error, :no_implementation_for, primary_sym do |y|

          _eew = Common_::Name.via_variegated_symbol primary_sym
          _subj = say_formal_attribute_ me.name
          _topic = say_primary_ _eew
          y << "#{ _subj } has no implentation for #{ _topic }."
          y << "(maybe defined `#{ m }` for #{ me.implementation.class }?)"
        end
        UNABLE_
      end

      def normal_symbol
        @name.as_lowercase_with_underscores_symbol
      end

      attr_reader(
        :name,
        :implementation,
      )
    end

    # ==
  end
end
