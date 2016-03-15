module Skylab::TaskExamples::TestSupport

  module Task_Types

    class << self

      def [] tcc

        tcc.send :define_singleton_method, :shared_state_ do  # #todo
          NIL_
        end

        tcc.include Instance_Methods__
        NIL_
      end
    end  # >>

    module Instance_Methods__

      # -- general emission assertion

      def state_where_emission_is_expected_ * x_a

        _cls = subject_class_

        _ = event_log.handle_event_selectively

        task = _cls.new( & _ )

        x_a.each_slice( 2 ) do |k, x|
          task.add_parameter k, x
        end

        _x = task.execute_as_front_task

        flush_event_log_and_result_to_state _x
      end

      def error_expression_message_

        y = nil
        _be_this = be_emission :error, :expression do |y_|
          y = y_
        end

        only_emission.should _be_this

        y.fetch 0
      end

      def success_expression_message_

        y = nil
        _be_this = be_emission :info, :expression do |y_|
          y = y_
        end

        only_emission.should _be_this

        y.fetch 0
      end

      def fails_
        _x = state_.result
        false == _x or fail
      end

      def succeeds_
        _x = state_.result
        true == _x or fail
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
        TestLib_::Development_tmpdir_path[]
      end
    end

    tdr = nil
    Tmpdirer___ = -> do
      tdr
    end

    Memoize_tmpdirer_and_etc_for___ = -> tc do

      _ = Home_.lib_.system.filesystem.tmpdir
      tdr = _.memoizer_for tc, '[te]'
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
  end
end
