require_relative 'test-support'

module Skylab::Task::TestSupport

  describe "[ta] the synthesis dependency" do

    TS_[ self ]
    use :memoizer_methods

    context "`parameter` `via_parameter`" do

      shared_subject :_nodes do

        class X_Synth_Link < Subject_class_[]

          depends_on_parameters :foo_foo, :la_la, :xhotango

          depends_on_call :X_Synth_Compile, :as, :frumpy,
            :parameter, :zoozie, :via_parameter, :foo_foo

          depends_on_call :X_Synth_Compile, :as, :chomber,
            :parameter, :zoozie, :via_parameter, :la_la

          def execute
            ACHIEVED_
          end

          attr_reader(
            :chomber,
            :frumpy,
          )
        end

        class X_Synth_Compile < Subject_class_[]

          depends_on_parameters :xhotango, :zoozie

          def execute
            @_VALUE_ = "compiled:(#{ @xhotango }, #{ @zoozie })"
            ACHIEVED_
          end

          attr_reader(
            :_VALUE_,
          )
        end

        NIL_
      end

      context "essential" do

        it "loads" do
          _nodes
        end
      end

      context "successful invocation" do

        shared_subject :state_ do

          _nodes
          ta = X_Synth_Link.new
          ta.add_parameter :foo_foo, :F
          ta.add_parameter :la_la, :L
          ta.add_parameter :xhotango, :X

          _ = ta.execute_as_front_task

          build_my_state_via_ _, ta
        end

        it "succeeds" do
          succeeds_
        end

        it "yay - higher task has two instances of lower task" do
          ta = state_.task
          ta.chomber._VALUE_.should eql "compiled:(X, L)"
          ta.frumpy._VALUE_.should eql "compiled:(X, F)"
        end

        # #todo - break up into a separate test that shows samed-name param transferal
      end
    end

    context "(reduction & coverage)" do

      shared_subject :_nodes do

        class X_Synth_Needer_Deeder < Subject_class_[]

          depends_on_parameters :foo, :bar

          depends_on_call :X_Synth_Needed_Deeded

          def execute
            @_VALUE_ = "(my value: #{ @X_Synth_Needed_Deeded._VALUE_ })"
            ACHIEVED_
          end

          attr_reader :_VALUE_
        end

        class X_Synth_Needed_Deeded < Subject_class_[]

          depends_on_parameters(
            bar: nil,
            baz: [ :default, :baz_D ],
          )

          def execute
            @_VALUE_ = "(hi: #{ @bar }, #{ @baz })"
            ACHIEVED_
          end

          attr_reader :_VALUE_
        end

        NIL_
      end

      context "successful invocation" do

        shared_subject :state_ do
          _nodes
          ta = X_Synth_Needer_Deeder.new
          ta.add_parameter :foo, :FOO
          ta.add_parameter :bar, :BAR
          _x = ta.execute_as_front_task
          build_my_state_via_ _x, ta
        end

        it "succeeds" do
          succeeds_
        end

        it "wahoo" do

          _ta = state_.task
          _ta._VALUE_.should eql "(my value: (hi: BAR, baz_D))"
        end
      end
    end
  end
end
