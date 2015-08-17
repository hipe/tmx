module Skylab::Snag

  class Models_::To_Do

    Models_ = ::Module.new

    class Models_::Matched_Line

      def reinitialize line

        md = RX__.match line
        if md
          @full_source_line = md[ :full_source_line ]
          @is_valid = true
          @lineno = md[ :line ].to_i
          @path = md[ :path ]
        else
          @full_source_line = false
          @is_valid = false
          @lineno = false
          @path = false
        end
        NIL_
      end

      alias_method :initialize, :reinitialize

      RX__ = /\A (?<path>[^:]+) : (?<line>\d+) : (?<full_source_line>.*) \z/mx

      attr_reader :full_source_line, :is_valid, :lineno, :path

    end
  end
end
