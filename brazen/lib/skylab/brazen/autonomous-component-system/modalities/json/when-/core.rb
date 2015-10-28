module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON::When_

      def self.[] * x_a, const

        const_get( const, false )[ * x_a ]
      end

      Express_context_under_ = -> p_a, expag, prep=nil do

        expag.calculate do

          s_a = p_a.reduce [] do | m, p |
            m << calculate( & p )
          end

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

      Autoloader_[ self ]
    end
  end
end
