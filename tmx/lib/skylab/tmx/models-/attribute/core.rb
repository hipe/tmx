module Skylab::TMX

  class Models_::Attribute

    # ==

    class Index

      def initialize args, mod

        formals = []
        hum_h = {}
        nop_h = nil
        sym_h = {}

        mod.constants.each do |const|

          _class = mod.const_get const, false
          _implementation = _class.new args
          attr = Here_.new _implementation, const
          d = formals.length

          if attr.is_derived
            nop_h ||= {}
            nop_h[ attr.name.as_human ] = [ :_because_is_derived_, d ]  # #here
          else
            hum_h[ attr.name.as_human ] = d
          end

          sym_h[ attr.normal_symbol ] = d
          formals.push attr
        end

        @_formal_attributes = formals
        @_formal_via_normal_symbol_hash = sym_h
        @_nonparsable_reason_via_human = nop_h
        @_parsable_formal_via_human = hum_h
      end

      def formal_via_normal_symbol k
        d = @_formal_via_normal_symbol_hash[ k ]
        if d
          @_formal_attributes.fetch d
        end
      end

      def is_parsable_via_human__ hum
        @_parsable_formal_via_human.key? hum
      end

      def explain_why_is_not_parsable__ s_a, json_file, & listener

        Here_::When_::Unparsable_attributes_in_JSON_file.call(
          s_a, json_file, @_nonparsable_reason_via_human, listener )
        UNABLE_
      end

      def express_levenshtein__ k, & emit
        Here_::When_::Unrecognized_attribute_levenshtein[ k, @_formal_attributes, emit ]
        UNABLE_
      end
    end

    # ==

    Here_ = self
    class Here_

      def initialize impl, const

        if impl.respond_to? :derived_from
          @is_derived = true
          @derived_from_ = impl.derived_from
        end

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

        Here_::When_::Has_no_implementation[ m, primary_sym, self, emit ]
        UNABLE_
      end

      # -- read

      def normal_symbol
        @name.as_lowercase_with_underscores_symbol
      end

      attr_reader(
        :derived_from_,
        :name,
        :implementation,
        :is_derived,
      )
    end

    # ==
  end
  Here_ = self
end
# #pending-rename: branch down
