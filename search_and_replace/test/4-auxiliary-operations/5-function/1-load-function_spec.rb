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
          a.concat node.value
          mine = a * _SEP
          s_a.push mine
          p[ -> do
            [ mine ]
          end ]
        end

        _st = Common_::Stream.via_nonsparse_array s_a

        want_these_lines_in_array_ _st do |y|
          y << "Jazzmatazz"
          y << "Jazzmatazz::Bizzo"
          y << "Jazzmatazz::Bizzo::Boffo"
          y << "Jazzmatazz::Bizzo::Boffo::WAHOO_Awooga"
          y << "Jazzmatazz::Other_Module"
        end
      end

      def __subject * x_a, & x_p
        Home_.lib_.system.filesystem.hack_guess_module_tree( * x_a, & x_p )
      end

  end
end
