require_relative 'test-support'

module Skylab::Task::TestSupport  # [#ts-010]

  describe "[ta] task" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    context "parameters - as [fi]-style hash.." do

      shared_subject :task_class_ do

        class X_Intro_1_Sandwich < Subject_class_[]

          depends_on_parameters(
            bread: nil,
            topping: :optional,
            inside: nil,
          )

          def execute

            @_oes_p_.call :payload, :data do
              [ @topping, @inside, @bread ]
            end

            ACHIEVED_
          end

          self
        end
      end

      context "essential" do

        it "loads" do
          task_class_
        end

        it "knows own name symbol" do

          _build_empty_task.name_symbol.should eql :X_Intro_1_Sandwich
        end

        it "knows own name" do

          _build_empty_task.name.as_variegated_symbol.should eql :X_intro_1_sandwich
        end

        def _build_empty_task
          task_class_.new
        end
      end

      context "with no parameters provided and with handler" do

        shared_subject :state_ do
          build_state_
        end

        def handler_
          common_handler_
        end

        def add_parameters_into_ _
          NOTHING_
        end

        it "fails" do
          fails_
        end

        it "emits" do

          _message = _same_message_around '(par bread)'

          _be_this = be_emission :error, :expression do |y|
            y.first.should eql _message
          end

          only_emission.should _be_this
        end
      end

      context "with no parameters and without handler" do

        shared_subject :state_ do
          build_exception_throwing_state_
        end

        def handler_
          NOTHING_
        end

        def add_parameters_into_ _
          NOTHING_
        end

        it "throws" do
          threw_
        end

        it "emits same message" do
          _msg = _same_message_around "'bread'"
          exception_message_.should eql _msg
        end
      end

      context "with required parameters" do

        shared_subject :state_ do
          build_state_
        end

        def add_parameters_into_ o
          o.add_parameter :bread, :x
          o.add_parameter :inside, :y
          NIL_
        end

        def handler_
          common_handler_
        end

        it "succeeds" do
          succeeds_
        end

        it "emitted data" do

          _be_this = be_emission :payload, :data do |x|
            x.should eql [ nil, :y, :x ]
          end

          only_emission.should _be_this
        end
      end
    end

if false

  describe "has different ways of describing its actions:" do

    describe "When it overrides the execute() method of rake parent" do

      class SomeTask < Home_::LegacyTask
        def execute args
          @touched = true
        end
        attr_accessor :touched
      end

      it "it will run that badboy when it is invoked" do
        t = SomeTask.new
        t.touched.should eql(nil)
        t.invoke
        t.touched.should eql(true)
      end
    end
    describe "When you call enhance() (per rake)" do
      it "it works" do
        touched = false
        t = Home_::LegacyTask.new.enhance{ touched = true }
        t.invoke
        touched.should eql(true)
      end
    end
    describe "When you set the action attribute to a lambda" do
      it "it works (provided you have the right arity)" do
        touched = false
        Home_::LegacyTask.new(:action => ->(t) { touched = true }).invoke
        touched.should eql(true)
      end
    end
  end

  describe "can define attributes as being interpolated" do
    it "and can then make references to other attributes" do
      klass = ::Class.new( Home_::LegacyTask ).class_eval do
        attribute :foo, :interpolated => true
        attribute :bar
        self
      end
      t = klass.new(
        :foo => 'ABC{bar}GHI',
        :bar => 'DEF'
      )
      t.foo.should eql('ABCDEFGHI')
    end
  end
end  # if false

    def _same_message_around s
      "missing required parameter #{ s } (had no parameters at all)"
    end
  end
end
