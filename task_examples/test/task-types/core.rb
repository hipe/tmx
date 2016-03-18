module Skylab::TaskExamples::TestSupport

  module Task_Types

    class << self

      def [] tcc

        tcc.send :define_singleton_method, :shared_state_ do
          Establish_shared_state_scope___[ self ]
        end

        tcc.include Instance_Methods__
        NIL_
      end
    end  # >>

    Establish_shared_state_scope___ = -> tcc do

      tcc.shared_subject :state_ do
        _x_a = build_arguments_
        _state_where_emission_is_expected_via_even_iambic _x_a
      end
    end

    module Instance_Methods__

      # -- general emission assertion

      def state_where_emission_is_expected_ * x_a
        _state_where_emission_is_expected_via_even_iambic x_a
      end

      def _state_where_emission_is_expected_via_even_iambic x_a

        _cls = subject_class_

        _ = event_log.handle_event_selectively

        task = _cls.new( & _ )

        x_a.each_slice( 2 ) do |k, x|
          task.add_parameter k, x
        end

        _x = task.execute_as_front_task

        _a = remove_instance_variable( :@event_log ).flush_to_array

        build_common_state_ _x, _a, task
      end

      def error_expression_message_
        _expression_message ERROR_EXPRESSION_CHANNEL___
      end

      def info_expression_message_
        _expression_message INFO_EXPRESSION_CHANNEL___
      end

      def payload_expression_message_
        _expression_message PAYLOAD_EXPRESSION_CHANNEL___
      end

      def _expression_message chan

        y = nil
        _be_this = be_emission_via_array chan do |y_|
          y = y_
        end

        only_emission.should _be_this

        y.fetch 0
      end

      ERROR_EXPRESSION_CHANNEL___ = [ :error, :expression ]
      INFO_EXPRESSION_CHANNEL___ = [ :info, :expression ]
      PAYLOAD_EXPRESSION_CHANNEL___ = [ :payload, :expression ]

      def succeeds_
        _x = state_.result
        true == _x or fail
      end

      # -- parametrically structural assertion

      def expect_missing_required_attributes_are_ * sym_a

        o = state_
        false == o.result or fail
        a = o.emission_array
        1 == a.length or fail
        _em = a.fetch 0

        actual_sym_a = nil
        _be_this = be_emission :error, :missing_required_attributes do |ev|
          actual_sym_a = ev.miss_a.map( & :name_symbol )
        end

        _em.should _be_this

        actual_sym_a.should eql sym_a
      end
    end

    # -- static fileserver

    module Instance_Methods__

      def run_file_server_if_not_running_

        Run_static_file_server_if_necessary_.call do
          [ do_debug, debug_IO ]
        end
      end
    end

    # -- tmpdir

    module Instance_Methods__

      def empty_tmpdir_
        ___tmpdir.clear
      end

      def ___tmpdir
        tdr = Tmpdirer___[]
        if tdr
          tdr.for self
        else
          Memoize_tmpdirer_and_etc_for___[ self ]
        end
      end

      def tmpdir_path_for_memoized_tmpdir
        ::File.dirname BUILD_DIR
      end
    end

    tdr = nil
    Tmpdirer___ = -> do
      tdr
    end

    Memoize_tmpdirer_and_etc_for___ = -> tc do

      _ = Home_.lib_.system.filesystem.tmpdir
      __ = ::File.basename TS_::BUILD_DIR

      tdr = _.memoizer_for tc, __
      tdr.instance
    end

    # -- filesystem

    module Instance_Methods__

      # -- setup

      x = nil
      define_method :other_non_existent_file_path_ do
        x ||= "#{ non_existent_file_path_ }2"
      end

      def non_existent_file_path_
        TestSupport_::Fixtures.file :not_here
      end

      def one_existent_file_path_
        TestSupport_::Fixtures.file :one_line
      end

      def other_existent_file_path_
        TestSupport_::Fixtures.file :three_lines
      end

      def the_empty_directory_
        TestSupport_::Fixtures.dir :empty_esque_directory
      end

      def real_filesystem_
        ::File
      end

      # -- assertion

      def file_exists_ path
        ::File.exist? path
      end

      def read_file_ path
        ::File.read path
      end
    end

    # -- other

    module Instance_Methods__

      def common_expression_agent_for_expect_event_
        Home_.lib_.brazen::API.expression_agent_instance
      end
    end
  end
end
