require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem

  describe "[hl] system services - filesystem hack guess module tree" do

    TestLib_::Expect_event[ self ]

    extend TS_

    it "simple - OK" do

      _whole_s = <<-'HERE'

        module Jazzmatazz  # beep boop

          Bizzo = ::Module.new

          class Bizzo::Boffo

            Stfu_OMG = -> string do
              xx
            end
          end

          module Other_Module

          end
        end
      HERE

      _lines = Headless_.lib_.string_lib.line_stream _whole_s

      root = subject :line_upstream, _lines

      o = root
      o.child_count.should eql 1
      o = o.children.first
      o.value_x.should eql [ :Jazzmatazz ]
      o.children.length.should eql 3
      o.children.first.value_x.should eql [ :Bizzo ]
      x = o.children[ 1 ]
        x.value_x.should eql [ :Bizzo, :Boffo ]
        x.children.first.value_x.should eql [ :Stfu_OMG ]
      o.children.last.value_x.should eql [ :Other_Module ]

      count = 0
      root.children_depth_first do |_|
        count += 1
      end

      count.should eql 5
    end

    # (currently this gets more coverage in [#ts-015] doc-test)

    def subject * x_a, & p
      super().hack_guess_module_tree( * x_a, & p )
    end
  end
end
