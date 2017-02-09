require_relative '../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - plan via index" do

    TS_[ self ]
    use :memoizer_methods

    context "simple dependence - two nodes, one arc" do

      shared_subject :_nodes do

        class X_G_Broseph_One < Subject_class_[]

          depends_on :X_G_Broseph_Two

          def execute
            @_yup_ = :_sure_
            ACHIEVED_
          end

          attr_reader(
            :_yup_,
            :X_G_Broseph_Two,
          )
        end

        class X_G_Broseph_Two < Subject_class_[]

          def execute
            @_yay_ = :_hi_
            ACHIEVED_
          end

          attr_reader(
            :_yay_,
          )
        end

        NIL_
      end

      shared_subject :state_ do

        _nodes
        ta = X_G_Broseph_One.new
        _hi = ta.execute_as_front_task
        build_my_state_via_ _hi, ta
      end

      it "succeeds, the front task was called" do

        state = state_
        true == state.result or fail
        :_sure_ == state.task._yup_ or fail
      end

      it "the dependee task was called too" do

        :_hi_ == state_.task.X_G_Broseph_Two._yay_ or fail
      end
    end

    context "triangle circle dependence" do

      shared_subject :_nodes do

        class X_G_Circ_A < Subject_class_[]
          depends_on :X_G_Circ_B
        end

        class X_G_Circ_B < Subject_class_[]
          depends_on :X_G_Circ_C
        end

        class X_G_Circ_C < Subject_class_[]
          depends_on :X_G_Circ_A
        end

        NIL_
      end

      it "such a graph can load" do
        _nodes
      end

      shared_subject :state_ do

        _nodes
        el = Home_::Common_.test_support::Expect_Emission::Log.new
        _ = el.handle_event_selectively
        _task = X_G_Circ_A.new( & _ )
        x = _task.execute_as_front_task

        _em = el.gets

        _ev = _em.cached_event_value

        _expag = common_expression_agent_for_expect_emission_

        _s_a = _ev.express_into_under [], _expag

        build_my_state_via_ x, _s_a, :_task_not_applicable_
      end

      it "but fails to execute" do
        fails_
      end

      it "first line explains that we can't do the front node" do

        _lines.first.should eql "circular dependency detected while trying to 'x-g-circ-a':"
      end

      it "second and third line walk throug the \"normal\" arcs" do
        a = _lines
        a.fetch( 1 ).should _be_this( 'a', 'b' )
        a.fetch( 2 ).should _be_this( 'b', 'c' )
      end

      it "fourth line is like the other two but it says \"but\"" do
        _lines.fetch( 3 ).should _be_this( 'but ', 'c', 'a' )
      end

      def _lines
        state_.emission_x_a
      end

      def _be_this prefix=nil, c, c_
        eql "#{ prefix }to 'x-g-circ-#{ c }' we must 'x-g-circ-#{ c_ }'."
      end
    end
  end
end
