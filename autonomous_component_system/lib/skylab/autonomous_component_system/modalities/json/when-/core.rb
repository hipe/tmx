module Skylab::Autonomous_Component_System

  # ->

    module Modalities::JSON::When_

      def self.[] * x_a, const

        const_get( const, false )[ * x_a ]
      end

      Express_context_under_ = -> context_x, expag, prep=nil do

        expag.calculate do

          _st = context_x.to_element_stream_assuming_nonsparse

          s_a = _st.reduce_into_by [] do | m, p |
            m << calculate( & p )
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

      Callback_::Autoloader[ self ]
    end
  # -
end
