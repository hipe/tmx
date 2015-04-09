module Skylab::Snag

  class Models_::Node_Identifier

    Actions = THE_EMPTY_MODULE_

    class << self

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

    attr_reader :to_i, :suffix

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

    if false  # #todo

      Invalid = Snag_::Model_::Event.new :mixed do
        message_proc do |y, o|
          y << "invalid identifier name #{ ick o.mixed } - #{
           }rendered full identifer: #{
            }\"[#foo-001.2.3]\", equivalent to: \"001.2.3\" #{
             }(prefixes ignored), \"001\" matches the superset"
        end
      end

      Prefix_Ignored = Snag_::Model_::Event.new :identifier do
        message_proc do |y, o|
          y << "prefixes are ignored currently - #{ ick o.identifier.prefix_s }"
        end
      end

    end

    Node_Identifier_ = self
  end
end
