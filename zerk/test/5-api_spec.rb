require_relative 'test-support'

module Skylab::Zerk::TestSupport

  module Zerk_Namespace_1____  # <-

  TS_.describe "[ze] zerk API" do

    TS_[ self ]

    context "the minimal branch" do

      before :all do

        class Mezo_Branch < Home_::Branch_Node

          def initialize x
            @children = Home_::EMPTY_A_
            super
          end
        end
      end

      def branch_class
        Mezo_Branch
      end

      it "with no args fails talking bout ended prematurely" do
        @result = call
        expect_not_OK_event_ :request_ended_prematurely
        expect_failed
      end

      it "with any args fails talking bout expecting nothing" do
        @result = call :foo
        expect_not_OK_event_ :child_not_found
        expect_failed
      end
    end

    context "the hello world branch" do

      before :all do

        module M2

          class Free_Branch_Node < Home_::Branch_Node

            def initialize * cls_a, x
              super x
              @children = cls_a.map do |cls|
                cls.new self
              end
            end

            attr_reader :children
          end

          class Field_Field < Home_::Field

            def against_nonempty_polymorphic_stream stream
              @s = stream.gets_one
              true
            end

            attr_reader :s
          end

          Quit_Button = Home_::Quit_Button

          Up_Button = Home_::Up_Button

          class Be_Excited_Boolean < Home_::Boolean
          end

          class Go_Agent < Home_::Common_Node

            def is_terminal_node
              true
            end

            def receive_polymorphic_stream _

              be = @parent[ :be_excited ].is_activated
              s = @parent[ :field ].s

              _ev = build_OK_event_with :yep do |y, o|
                s_ = "hello #{ s }"
                be and s_.upcase!
                y << s_
              end

              @parent.handle_event_selectively_via_channel.call nil do
                _ev
              end

              true
            end
          end

          class Integral_Branch_Node < Home_::Branch_Node

            def initialize x
              super
              @children = [
                Field_Field.new( self ),
                Quit_Button.new( self ),
                Up_Button.new( self ),
                Be_Excited_Boolean.new( self ),
                Go_Agent.new( self ) ]
            end

            def set_name_symbol name_i
              @name = Home_::Callback_::Name.via_variegated_symbol name_i
              nil
            end
          end
        end
      end

      def branch_class
        M2::Integral_Branch_Node
      end

      it "a 'quit' button is unreachable" do
        with_branch_with M2::Quit_Button
        @result = call :quit
        expect_not_OK_event_ :child_not_found
        expect_failed
      end

      it "an 'up' button is unreachable" do
        with_branch_with M2::Up_Button
        @result = call :up
        expect_not_OK_event_ :child_not_found
        expect_failed
      end

      it "with just the field and nothing else" do
        with_branch_with M2::Field_Field
        @result = call :field
        expect_not_OK_event_ :request_ended_prematurely,
          "field error: request ended prematurely - expecting value for 'field'"
        expect_failed
      end

      it "when you do provide a value for the field" do
        with_branch_with M2::Field_Field
        @result = call :field, :x
        expect_not_OK_event_ :request_ended_prematurely
        expect_failed
      end

      it "ok let's see the money" do
        @result = call :field, :x, :be_excited, :go
        expect_OK_event_ :yep, "HELLO X"
        unwrap_result
        expect_succeeded
      end

      it "reach nested branch nodes" do
        x = M2::Free_Branch_Node.new build_mock_parent
        x_ = M2::Integral_Branch_Node.new( x )
        x_.set_name_symbol :foofie
        x.children.push x_
        @branch = x
        @result = call :foofie, :field, :y, :go
        expect_OK_event_ :yep, "hello y"
        unwrap_result
        expect_succeeded
      end

      def unwrap_result
        @result = @result.receiver.send @result.method_name, * @result.args
        nil
      end

      def with_branch_with * cls_a
        @branch = M2::Free_Branch_Node.new( * cls_a, build_mock_parent )
        nil
      end
    end
  end
# ->
  end
end
