require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::Toucher

  ::Skylab::Face::TestSupport::CLI::Client[ self, :CLI_party ]

  describe "[fa] CLI client toucher (hooks)" do

    extend TS__

    context "some context" do

      with_body do
        def initialize( * )
          super
          @mechanics.is_not_touched!
        end
        def foo
        end
        class self::Kernel_ < Home_::CLI::Client::CLI_Kernel_  # sketchville
          def touch
            @sheet.node_open!
            @sheet.close_node do |a|
              a.set_method_name :haxxville
              a.set_command_parameters_proc -> do
                [ [ :opt, :foo ], [ :req, :bar ] ]
              end
            end
            @sheet._scooper.add_name_at_this_point :haxxville
            is_touched!
            nil
          end
        end
      end

      it "lets you manipulate your command tree dynamically" do
        wat = client.instance_variable_get( '@mechanics' ).sheet.command_tree
        wat.instance_variable_get( :@a ).should eql [ :foo ]
        invoke '-h'
        rx = /\A[ ]+([^ ]+)(?=[ ])/
        two = lines[:err][-3..-2]
        two.map do |line| rx.match( unstyle line )[ 1 ]
        end.should eql( [ 'foo', 'haxxville' ] )
        two[1].include?( '[<foo>] <bar>' ).should eql( true )  # snark
        wat.instance_variable_get( :@a ).should eql [ :foo, :haxxville ]
      end
    end
  end
end
