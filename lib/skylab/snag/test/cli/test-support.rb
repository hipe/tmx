require_relative '../test-support'

module Skylab::Snag::TestSupport::CLI

  ::Skylab::Snag::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  TestLib_ = TestLib_


  # ~ invocation

  module InstanceMethods

    def invoke * argv_tail_s_a
      argv = [ * invocation_prefix_s_a, * argv_tail_s_a ]
      output.lines.clear
      clnt = client
      p = -> _ do
        @result = clnt.invoke argv
      end
      if has_tmpdir
        setup_tmpdir_if_necessary
        from_tmpdir( & p )
      else
        p[ nil ]
      end
      nil
    end

    attr_reader :result

    def invocation_prefix_s_a
    end

    def has_tmpdir
    end
  end


  # ~ invocation prefix write & read

  module ModuleMethods

    def with_invocation * s_a
      s_a.freeze
      define_method :invocation_prefix_s_a do
        s_a
      end ; nil
    end
  end


  # ~ ordinary client & output

  module InstanceMethods

    let :client do
      Client__[ output ]
    end

    let :output do
      output = Output__[]
      output.do_debug_proc = -> { do_debug }
      output
    end
  end


  # ~ sketchy memoized client & output

  module ModuleMethods

    def use_memoized_client
      method_defined? :memo_frame or dfn_memoized_readers
    end

    def dfn_memoized_readers

      def client
        o = memo_frame
        if do_debug
          o.output.debug or o.output.do_debug_proc = -> { do_debug }
        end
        o.client
      end

      def output
        memo_frame.output
      end

      define_method :memo_frame, TestLib_::Memoize[ -> do
        Memo_Frame__.new _ = Output__[], Client__[ _ ]
      end ]
    end
  end

  Memo_Frame__ = ::Struct.new :output, :client


  # ~ tmpdir setup writing & reading

  module ModuleMethods

    def with_manifest s
      with_tmpdir do |o|
        pn = o.clear.write manifest_file, s
        memoize_last_pn pn
        @pn = pn ; nil
      end ; nil
    end

    def with_tmpdir_patch & p
      with_tmpdir do |o|
        _patch_s = instance_exec( & p )
        o.clear.patch _patch_s ; nil
      end
    end

    def with_tmpdir &p

      define_method :has_tmpdir do true end

      -> x do
        define_method :tmpdir_setup_identifier do x end
      end[ Produce_tmpdir_setup_identifier__[] ]

      define_method :__execute_the_tmpdir_setup__ do
        _td = tmpdir
        instance_exec _td, & p
        nil
      end ; nil
    end
  end

  Produce_tmpdir_setup_identifier__ = -> do
    d = 0 ; -> { d += 1 }
  end.call

  module InstanceMethods

    def setup_tmpdir_if_necessary
      is_setup_as = MUTEX__.setup_identifier
      if is_setup_as && is_setup_as == tmpdir_setup_identifier
        @pn = MUTEX__.pn
        if ! this_instance_wants_read_only  # taint setup so next one renews it
          MUTEX__.setup_identifier = nil
        end
      else
        do_setup_tmpdir
      end ; nil
    end

    def setup_tmpdir_read_only
      @this_instance_wants_read_only = true
      did_setup_tmpdir_read_only or do_setup_tmpdir_read_only ; nil
    end

    attr_reader :this_instance_wants_read_only

    def do_not_setup_tmpdir  # big hack
      MUTEX__.setup_identifier = tmpdir_setup_identifier
      @this_instance_wants_read_only = false ; nil
    end

    def did_setup_tmpdir_read_only
      tmpdir_setup_identifier == MUTEX__.setup_identifier
    end

    def do_setup_tmpdir_read_only
      MUTEX__.setup_identifier = tmpdir_setup_identifier
      do_setup_tmpdir ; nil
    end

    def memoize_last_pn pn
      MUTEX__.pn = pn
    end

    Mutex__ = ::Struct.new :setup_identifier, :pn
    MUTEX__ = Mutex__.new

    def do_setup_tmpdir
      __execute_the_tmpdir_setup__ ; nil
    end
  end


  # ~ expectations

  module InstanceMethods

    def expect * x_a
      if x_a.length.zero?
        output.lines.length.should be_zero
      else
        expct_via_nonzero_length_x_a x_a
      end
    end

    alias_method :o, :expect  # legacy

    def expct_via_nonzero_length_x_a x_a
      case x_a.length
      when 1 ; chan_i = :info ; x = x_a.first
      when 2 ; chan_i, x = x_a
      else   ; raise ::ArgumentError, "[channel] { rx | string }"
      end
      emission = output.lines.shift
      emission or fail "had no more events in queue, expecting #{
        }#{ [ chan_i, x ].inspect }"
      emission.stream_name.should eql chan_i
      emission.string.chomp!  # meh
      if x.respond_to? :ascii_only?
        emission.string.should eql x
      else
        emission.string.should match x
      end ; nil
    end

    def expect_failed
      expect_no_more_output_lines
      expect_failure_result
    end

    def expect_succeeded
      expect_no_more_output_lines
      expect_success_result
    end

    def expect_no_more_output_lines
      output.lines.length.should be_zero
    end

    def expect_failure_result
      @result.should eql LEGACY_ERROR_CODE__
    end

    def expect_success_result
      @result.should eql SUCCESS_EXITSTATUS__
    end

    def weirdly_expect_success_result
      @result.should eql LEGACY_SUCCESS_CODE__
    end
  end

  Client__ = -> output do
    client = Snag_::CLI.new nil, output.for( :pay ), output.for( :info )
    client.send :program_name=, 'sn0g'
    client
  end

  LEGACY_ERROR_CODE__ = 1

  LEGACY_SUCCESS_CODE__ = 0

  Output__ = -> do
    output = TestSupport_::IO::Spy::Group.new
    output.line_filter! -> s do
      Snag_::Lib_::CLI[]::PEN::FUN.unstyle[ s ]
    end
    output
  end

  SUCCESS_EXITSTATUS__ = 0
end
