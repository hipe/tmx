require_relative '../../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] auxiliaries - function - load" do

    TS_[ self ]

      it "it tries to infer the module tree from a file - FALLIBLE" do

        _path = ::File.join common_functions_dir_, 'wahoo-awooga.rb'

        _tree = __subject :path, _path

        s_a = []

        _SEP = '::'  # CONST_SEP_

        _tree.children_depth_first_via_args_hook nil do |node, x, p|
          a = []
          x and a.push x
          a.concat node.value_x
          mine = a * _SEP
          s_a.push mine
          p[ -> do
            [ mine ]
          end ]
        end

        o = Common_::Stream.via_nonsparse_array s_a

        o.gets.should eql "Jazzmatazz"
        o.gets.should eql "Jazzmatazz::Bizzo"
        o.gets.should eql "Jazzmatazz::Bizzo::Boffo"
        o.gets.should eql "Jazzmatazz::Bizzo::Boffo::WAHOO_Awooga"
        o.gets.should eql "Jazzmatazz::Other_Module"

        s_a.length.should eql 5
      end

      def __subject * x_a, & x_p
        Home_.lib_.system.filesystem.hack_guess_module_tree( * x_a, & x_p )
      end

  end
end
