require_relative 'test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] 1 - one leaf" do

    TS_[ self ]

    it "builds" do
      build_top_
    end

    context "when call it with nothing:" do

      shared_subject :state_ do
        call_
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "events" do
        only_emission.should be_emission( :error, :expression, :empty_arguments )
      end
    end

    context "when call it with something strange:" do

      shared_subject :state_ do
        call_ :something
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "message tail enumerates the available items (one)" do

        only_emission.should ( be_emission :error, :uninterpretable_token do | ev |

          _ = black_and_white ev

          _.should match %r(, expecting file_name\z)
        end )
      end
    end

    it "persist this ACS when empty - OK" do

      @oes_p_ = Future_Expect_[ :info, :wrote ]

      _ = build_top_
      _s_a = _.persist_into_ []
      _s_a.should eql EMPTY_JSON_LINES_

      @oes_p_.done_
    end

    it "persist this ACS when we hack a value into it - OK" do

      @oes_p_ = Future_Expect_[ :info, :wrote ]

      o = build_top_

      o._set_file_name :xx

      _s = o.persist_into_ "", :be_pretty, false

      _s.should eql "{\"file_name\":\"xx\"}\n"

      @oes_p_.done_
    end

    context "when payload looks wrong:" do

      shared_subject :state_ do

        _ = build_top_

        _x = _.unmarshal_from_ Callback_::Stream.via_nonsparse_array ['{"foo":"bar"}']

        @result = _x

        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "emits" do
        only_emission.should be_emission( :error, :extra_properties )
      end
    end

    it "when payload looks right - unmarshals OK" do

      @oes_p_ = Future_expect_nothing_[]

      _ = build_top_

      _json_lines = ['{"file_name":"bar"}']

      one = _.unmarshal_from_ Callback_::Stream.via_nonsparse_array _json_lines

      one._read_file_name.should eql 'bar'
    end

    context "when call it with good name but no value:" do

      shared_subject :state_ do
        call_ :file_name
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "emits" do

        only_emission.should ( be_emission(
          :error, :expression, :request_ended_prematurely
        ) do |y|
          y.should eql [ "expecting value for 'file-name'" ]
        end )
      end
    end

    context "when call it with good name and bad value:" do

      shared_subject :state_ do
        call_ :file_name, '/'
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "emits" do

        only_emission.should ( be_emission(
          :error, :expression, :invalid_value
        ) do |y|
          y.should eql [ "paths can't be absolute - '/'" ]
        end )
      end
    end

    context "when call it with good name and good value:" do

      shared_subject :state_ do
        call_plus_ :file_name, 'hi'
        flush_state_plus_
      end

      it "value is written" do

        _x = state_.top
        _x._read_file_name.should eql 'hi'
      end

      it "event message is suitable for outputting to UI" do

        only_emission.should ( be_emission(
          :info, :set_leaf_component,
        ) do |ev|
          black_and_white( ev ).should eql 'set file name to "hi"'
        end )
      end
    end

    shared_subject :top_ACS_class_ do

      class One_Thing

        def initialize & oes_p
          @oes_p_ = oes_p
        end

        include Unmarshal_and_Call_and_Marshal_

        def freeze
          remove_instance_variable :@oes_p_
          super
        end

        def __file_name__component_association

          File_Name_Model_
        end

        def _set_file_name x
          @file_name = x ; nil
        end

        def _read_file_name
          @file_name
        end

        self
      end
    end
  end
end
