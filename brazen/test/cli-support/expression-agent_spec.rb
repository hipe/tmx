
require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - expression agent" do

    TS_[ self ]
    use :memoizer_methods

    context "(for ignoring)" do

      shared_subject :_lines do

        he = _common_begin
        he.ignore_emissions_ending_with :la_la
        he.finish
        he.handle [ :shooomie, :doomie, :la_la ]
        he.downstream_yielder
      end

      it "ignore appears to work" do
        _lines.length.zero? or fail
      end
    end

    context "(event)" do

      shared_subject :_tuple do

        he = _common_begin.finish

        _ =  he.handle [ :info, :doozie ] do
          _fake_event do |y|
            y << ick( 'yay' )
          end
        end

        [ _, he.downstream_yielder ]
      end

      it "result" do
        :_unreliable_ == _tuple.fetch( 0 ) or fail
      end

      it "emission" do
        _ = _tuple.fetch( 1 )
        [ '"yay"' ] == _ or fail
      end
    end

    context "(expression)" do

      shared_subject :_lines do
        he = _common_begin.finish
        he.handle [ :info, :expression ] do |y|
          y << ick( 'yay' )
        end
        he.downstream_yielder
      end

      it "ok." do
        _ = _lines
        [ '"yay"' ] == _ or fail
      end
    end

    def _common_begin
      he = Home_::CLI_Support::Expression_Agent.instance.begin_handler_expresser
      he.downstream_yielder = []
      he
    end

    def _fake_event & y_p
      _Fake_Event.new y_p
    end

    shared_subject :_Fake_Event do
      class X_CS_EA_Fake_Event
        def initialize y_p
          @_y_p = y_p
        end
        def express_into_under y, expag
          expag.calculate y, & @_y_p
        end
        self
      end
    end
  end
end
