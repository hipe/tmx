require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] doc-test - actors - infer business module name loadlessly" do

    extend TS_
    use :expect_event

    it "when matching leaf nodes not found, search branch nodes" do

      _Basic = Home_.lib_.basic

      _path = ::File.join _Basic.dir_pathname.to_path, 'method.rb'

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

      _line_ups = Home_.lib_.basic::String.line_stream _whole_string

      _name = subject(
        :path, '/var/xkcd/skorlorb/morta-horl/porse/voa-ordered-set--.rb',
        :line_upstream, _line_ups, & event_log.handle_event_selectively )

      _name.should eql "Skorlab::MortaHorl::Porse::Voa_ordered_set__"

    end

    def subject * a, & p
      Subject_[]::Actors_::Infer_business_module_name_loadlessly[ * a, & p ]
    end

  end
end
