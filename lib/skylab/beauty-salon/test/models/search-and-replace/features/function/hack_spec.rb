require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] features - function - hack" do


      it "it tries to infer the module tree from a file - FALLIBLE" do

        _path = TS_::Fixtures.stfu_omg_function_file_path

        tree = subject :path, _path

        s_a = []

        _SEP = Home_::CONST_SEP_

        tree.children_depth_first_via_args_hook nil do |node, x, p|
          a = []
          x and a.push x
          a.concat node.value_x
          mine = a * _SEP
          s_a.push mine
          p[ -> do
            [ mine ]
          end ]
        end

        o = Callback_::Stream.via_nonsparse_array s_a

        o.gets.should eql "Jazzmatazz"
        o.gets.should eql "Jazzmatazz::Bizzo"
        o.gets.should eql "Jazzmatazz::Bizzo::Boffo"
        o.gets.should eql "Jazzmatazz::Bizzo::Boffo::Stfu_OMG"
        o.gets.should eql "Jazzmatazz::Other_Module"

        s_a.length.should eql 5
      end

      def subject * x_a, & p
        Home_::Lib_::System[].filesystem.hack_guess_module_tree( * x_a, & p )
      end

  end
end
