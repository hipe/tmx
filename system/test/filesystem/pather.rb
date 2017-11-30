module Skylab::System::TestSupport

  module Filesystem::Pather

    class << self
      def [] tcm
        tcm.extend Module_Methods___
        tcm.include Instance_Methods___
      end
    end  # >>

    module Module_Methods___

      h = { home: :_home, pwd: :_pwd }

      [ :home, :pwd ].each do |sym|

        define_method sym do |x|

          define_method h.fetch sym do
            x
          end
        end
      end

      def exemplifying s, & p

        yes = true ; x = nil
        define_method :__dootily do
          if yes
            yes = false
            x = __build_dootily
          end
          x
        end

        context s, & p
      end

      def o input, expected, * tags  # #deprecated pattern

        _verb_phrase_s = if expected == input
          'does not change'
        else
          "prettifies to #{ expected.inspect }"
        end

        it "#{ input.inspect } #{ _verb_phrase_s }", * tags do

          _ohai = __dootily

          _actual = _ohai.call input

          if _actual != expected
            expect( _actual ).to eql expected
          end
        end
      end
    end

    module Instance_Methods___

      def __build_dootily
        Home_::Filesystem::Pather.new _home, _pwd
      end

      def _home
        NOTHING_
      end

      def _pwd
        NOTHING_
      end
    end
  end
end
