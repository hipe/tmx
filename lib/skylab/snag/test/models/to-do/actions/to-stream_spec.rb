require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do", wip: true do

    extend TS_

    context 'this is a hack [#068]' do

      it "but will try to skip false matches" do
        @result = subject
        expect :info_event, :did_not_match do |ev|
          str = render_terminal_event ev
          str.should match %r(\Askipping a line that matched via `grep`)
          ev = ev.ev
          ev.pn.to_path.should eql '(poth)'
          ev.line.should match %r(\A@#{}todo\.blah )
          ev.line_number.should eql 33
        end
      end
    end

    def subject
      Snag_::Models::ToDo.build( * args )
    end

    def args
      [ line_s, line_number_string, path, pattern_s, listener_spy ]
    end

    def line_s
      "@#{}todo.blah  # not a todo tag"
    end

    def line_number_string
      '33'
    end

    def path
      '(poth)'
    end

    def pattern_s
      Snag_::Models::ToDo.default_pattern_s
    end
  end
end
