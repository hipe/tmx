require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  describe "[bs] features - function - hack" do


      it "it tries to infer the module tree from a file - FALLIBLE" do

        _path = TS_::Fixtures.stfu_omg_function_file_path

        tree = subject[ _path, nil ]

        s_a = []
        tree.traverse do |node|
          s_a.push node.const_i_a * BS_::CONST_SEP_
        end
        s_a[ 0 ].should eql 'Jazzmatazz'
        s_a[ 1 ].should eql 'Jazzmatazz::Bizzo'
        s_a[ 2 ].should eql 'Jazzmatazz::Bizzo::Boffo'
        s_a[ 3 ].should eql 'Jazzmatazz::Other_Module'
        s_a.length.should eql 4
      end

      def subject
        Subject_[]::Actors_::Build_replace_function::Hack_guess_module_tree__
      end

  end
end
