module Skylab::Basic

  class List::Scanner

    class For::String  # read [#024] (in [@022]) the string scanner narrative

      class << self
        alias_method :[], :new
        private :new
      end

      def initialize s
        @count = 0
        scn = Library_::StringScanner.new s
        @gets_p = -> do
          if (( s = scn.scan LINE_RX_ ))
            @count += 1
            s
          else
            scn.eos? or fail "sanity - rx logic failure"
            @gets_p = MetaHell::EMPTY_P_ ; nil
          end
        end ; nil
      end

      def gets
        @gets_p.call
      end

      def line_number
        @count.nonzero?
      end

      # ~

      def self.Reverse mutable_string
        yield Reverse[ mutable_string ] ; nil
      end

      Reverse = -> mutable_string do
        is_first = true
        ::Enumerator::Yielder.new do |line|
          if is_first
            is_first = false
            mutable_string.concat line
          else
            mutable_string.concat "\n#{ line }"
          end ; nil
        end
      end
    end
  end
end
