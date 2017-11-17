require_relative '../test-support'

module Skylab::Task::TestSupport  # [#ts-010]

  describe "[ta] magnetics - execution via [..]" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

    context "parameters - as [fi]-style hash.." do

      shared_subject :task_class_ do

        class X_Intro_1_Sandwich < Subject_class_[]

          depends_on_parameters(
            bread: nil,
            topping: :optional,
            inside: nil,
          )

          def execute

            @_listener_.call :payload, :data do
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
          # #lends-coverage to [#fi-008.7]
          fails_
        end

        it "emits" do

          _be_this = be_emission :error, :missing_required_attributes do |ev|

            black_and_white( ev ).should eql _message_expected_for_emit
          end

          only_emission.should _be_this
        end
      end

      context "with no parameters and without handler" do

        shared_subject :state_ do

          build_exception_throwing_state_() { ::Skylab::Fields::MissingRequiredAttributes }
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

          s = _message_expected_for_emit
          s.chop!
          exception_message_.should eql s
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
end  # if false

    def _message_expected_for_emit
      "missing required parameters 'bread' and 'inside'\n"
    end
  end
end
