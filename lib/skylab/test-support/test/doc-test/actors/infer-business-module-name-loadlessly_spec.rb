require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - actors - infer business module name loadlessly" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "when matching leaf nodes not found, search branch nodes" do
      _path = ::Skylab.dir_pathname.join( 'basic/method.rb' ).to_path
      subject( _path ).should eql "Skylab::Basic::Method"
    end

    it "detect const assignment also #experimental" do

      _whole_string = <<-'HERE'

        module Skorlab::MortaHorl

          module Porse

            Voa_ordered_set__ = Parse::Curry_[ etc ]
          end
        end
      HERE

      _line_ups = TestSupport_.lib_.basic::String.line_stream _whole_string

      _name = subject(
        :path, '/var/xkcd/skorlorb/morta-horl/porse/voa-ordered-set--.rb',
        :line_upstream, _line_ups, & handle_event_selectively )

      _name.should eql "Skorlab::MortaHorl::Porse::Voa_ordered_set__"

    end

    if false  # visual test - useful for debugging

      _RX = /[^[:space:]]+/

      it "CHECK ALL (visual test for now)" do
        @oes_p = handle_event_selectively
        dflts = TestSupport_.lib_.system.defaults
        _mani_path = dflts.doc_test_manifest_path
        lines = ::File.open _mani_path, 'r'
        pn = dflts.top_of_the_universe_pathname
        count = 0
        while line = lines.gets
          count += 1
          _path = _RX.match( line )[ 0 ]
          try_this_path pn.join( _path ).to_path
        end
        debug_IO.puts "DONE with #{ count } paths."
      end

      def try_this_path path
        debug_IO.write "DOING: -->#{ path }<---"
        x = subject path, & @oes_p
        if x
          debug_IO.puts "  -->#{ x }<----"
        else
          self._HERE
        end
      end

    end

    def subject * a, & p
      Subject_[]::Actors_::Infer_business_module_name_loadlessly[ * a, & p ]
    end

  end
end
