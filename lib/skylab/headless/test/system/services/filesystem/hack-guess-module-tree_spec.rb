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

      _lines = Headless_._lib.string_lib.line_stream _whole_s

      root = subject :line_upstream, _lines
      o = root
      o.child_count.should eql 1
      o = o.children.first
      o.value_x.should eql [ :Jazzmatazz ]
      o.children.length.should eql 2
      o.children.first.value_x.should eql [ :Bizzo, :Boffo ]
      o.children.last.value_x.should eql [ :Other_Module ]

      count = 0
      root.children_depth_first do |_|
        count += 1
      end

      count.should eql 3
    end


    if false  # #todo

    _RX = /[^[:space:]]+/

    it "CHECK ALL (visual test for now)" do
      dflts = Headless_.system.defaults
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
      debug_IO.puts "DOING-->#{ path }<---"
      subject path  # xx
    end

    end

    def subject * x_a, & p
      super().hack_guess_module_tree( * x_a, & p )
    end
  end
end
