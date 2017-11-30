require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - hack guess module tree" do

    TS_[ self ]
    use :want_event

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

      _lines = Basic_[]::String::LineStream_via_String[ _whole_s ]

      root = __subject :line_upstream, _lines

      o = root
      expect( o.children_count ).to eql 1
      o = o.children.first
      expect( o.value ).to eql [ :Jazzmatazz ]
      expect( o.children.length ).to eql 3
      expect( o.children.first.value ).to eql [ :Bizzo ]
      x = o.children[ 1 ]
        expect( x.value ).to eql [ :Bizzo, :Boffo ]
        expect( x.children.first.value ).to eql [ :Stfu_OMG ]
      expect( o.children.last.value ).to eql [ :Other_Module ]

      count = 0
      root.children_depth_first do |_|
        count += 1
      end

      expect( count ).to eql 5
    end

    # (currently this gets more coverage in [dt])

    def __subject * x_a, & x_p

      services_.filesystem.hack_guess_module_tree( * x_a, & x_p )
    end
  end
end
