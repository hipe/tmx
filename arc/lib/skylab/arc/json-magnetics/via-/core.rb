module Skylab::Arc

  module JSON_Magnetics::Via_

      def self.[] * x_a, const

        const_get( const, false )[ * x_a ]
      end

      Express_context_under_ = -> context_linked_list, expag, prep=nil do

        expag.calculate do

          _st = context_linked_list.to_element_stream_assuming_nonsparse

          s_a = _st.join_into [] do |p|
            calculate( & p )
          end

          s_a.reverse!

          s = s_a.pop
          if s
            if prep
              s.gsub! %r(\Ain ), "#{ prep } "
            end
            _tightest_context = "#{ s } "
          end

          if s_a.length.nonzero?
            _trailing_context = " (#{ s_a.join SPACE_ })"
          end

          [ _tightest_context, _trailing_context ]
        end
      end

      Common_::Autoloader[ self ]
  end
end
