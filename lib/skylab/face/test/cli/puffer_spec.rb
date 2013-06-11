require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Puffer

  ::Skylab::Face::TestSupport::CLI[ Puffer_TestSupport = self ]

  CONSTANTS::Common_setup_[ self ]

  describe "#{ Face::CLI } puffer (hooks)" do

    extend Puffer_TestSupport

    context "some context" do

      with_body do
        def initialize( * )
          super
          @mechanics.is_not_puffed!
        end
        def foo
        end
        class self::Mechanics_ < Face::CLI_Mechanics_  # sketchville
          def puff
            @sheet.node_open!
            @sheet.close_node do |a|
              a.set_method_name :haxxville
              a.set_command_parameters_function -> do
                [ [ :opt, :foo ], [ :req, :bar ] ]
              end
            end
            @sheet._scooper.add_name_at_this_point :haxxville
            is_puffed!
            nil
          end
        end
      end

      it "lets you manipulate your command tree dynamically" do
        wat = client.instance_variable_get( '@mechanics' ).sheet.command_tree
        wat._order.should eql( [:foo] )
        invoke '-h'
        rx = /\A[ ]+([^ ]+)(?=[ ])/
        two = lines[:err][-3..-2]
        two.map do |line| rx.match( unstylize line )[ 1 ]
        end.should eql( [ 'foo', 'haxxville' ] )
        two[1].include?( '[<foo>] <bar>' ).should eql( true )  # snark
        wat._order.should eql( [:foo, :haxxville] )
      end
    end
  end
end
