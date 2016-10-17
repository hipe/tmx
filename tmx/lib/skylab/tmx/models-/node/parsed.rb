module Skylab::TMX

  class Models_::ParsedNode

    class << self

      def via h, index, json_file, & p

        box = Common_::Box.new
        extra = nil
        h.each_pair do |s, x|

          attr = index.formal_via_human s
          if attr
            box.add s, AttributeValue___.new( attr,  x )
          else
            ( extra ||= [] ).push s
          end
        end

        if extra
          p.call :error, :emission, :parse_error do |y|
            y << "unrecognized attribute(s) #{ extra.inspect } in #{ json_file }"
          end
          UNABLE_
        else
          new box
        end
      end

      private :new
    end  # >>

    def initialize box
      @box = box
    end

    attr_reader(
      :box,
    )

    # ==

    class AttributeValue___

      def initialize attr, x
        @formal_attribute = attr
        @value_x = x
      end

      attr_reader(
        :formal_attribute,
        :value_x,
      )
    end

    # ==
  end
end
