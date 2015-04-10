module Skylab::Snag

  class Models_::Node_Identifier

    Actions = THE_EMPTY_MODULE_

    class << self

      def try_convert x
        if x.respond_to? :suffix
          x
        elsif x.respond_to? :bit_length
          new_via_integer x
        end
      end

      def new_via_integer d
        new d
      end

      def new_via_integer_and_suffix_string d, s
        new d, Node_Identifier_::Models_::Suffix.parse( s )
      end

      private :new
    end  # >>

    def initialize d, suffix_o=nil
      @suffix = suffix_o
      @to_i = d
    end

    attr_reader :suffix, :to_i

    def express_into_under y, expag
      Node_Identifier_::Expression_Adapters.
        const_get( expag.modality_const, false )[ y, expag, self ]
    end

    include ::Comparable

    def <=> otr
      if otr.kind_of? Node_Identifier_
        d = @to_i <=> otr.to_i
        if d.zero?
          o = @suffix
          o_ = otr.suffix
          if o
            if o_
              o <=> o_
            else
              1
            end
          elsif o_
            -1
          else
            d
          end
        else
          d
        end
      end
    end

    # ~ begin suffixes

    def suffix_separator_at_index d
      if @suffix
        @suffix.separator_at_index d
      end
    end

    def suffix_value_at_index d
      if @suffix
        @suffix.value_at_index d
      end
    end

    # ~ end suffixes

    Expression_Adapters = ::Module.new
    Expression_Adapters::Byte_Stream = -> y, expag, id do

      sfx = id.suffix
      if sfx
        self._DO_ME
      end

      y << "[##{ "%0#{ expag.identifier_integer_width }d" % id.to_i }]"
      NIL_
    end

    Node_Identifier_ = self
  end
end
