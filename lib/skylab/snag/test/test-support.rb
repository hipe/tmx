require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  Snag_ = ::Skylab::Snag
  TestLib_ = ::Module.new
  TestSupport_ = ::Skylab::TestSupport

  module Constants
    Callback_ = ::Skylab::Callback
    Snag_ = Snag_
    TestSupport_ = TestSupport_
    TestLib_ = TestLib_
  end

  include Constants # in the body of child modules

  module TestLib_

    sidesys = Snag_::Autoloader_.build_require_sidesystem_proc

    HL__ = sidesys[ :Headless ]

    MH__ = sidesys[ :MetaHell ]

    System = -> do
      HL__[].system
    end

    Tmpdir_pathname = -> do
      System[].filesystem.tmpdir_pathname
    end
  end

  module InstanceMethods

    include Constants

    def debug!
      if ! tmpdir.be_verbose
        @tmpdir = @tmpdir.with :be_verbose, true
      end
      @do_debug = true
    end

    attr_accessor :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def from_tmpdir & p
      Snag_::Library_::FileUtils.cd tmpdir, verbose: do_debug, & p
    end

    def tmpdir
      @tmpdir ||= Memoized_tmpdir__[] || Memoize_tmpdir__[ do_debug, debug_IO ]
    end

    -> do
      x = nil
      Memoized_tmpdir__ = -> { x }
      Memoize_tmpdir__ = -> do_debug, debug_IO do
        x = TestSupport_.tmpdir.new(
          :path, TestLib_::Tmpdir_pathname[].join( 'snaggle' ),
          :be_verbose, do_debug,
          :debug_IO, debug_IO )
        x
      end
    end.call

    -> x do
      define_method :manifest_file do x end
    end[ Snag_::API.manifest_file ]

  end

  # ~ business

  module InstanceMethods
    def with_API_max_num_dirs d
      Skylab::Snag::API::Client.setup -> o do
        o.max_num_dirs_to_search_for_manifest_file = d  # #open [#050]
      end ; nil
    end
  end

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


    # ~ actor expectation

    def listener_spy
      @listener_spy ||= bld_listener_spy
    end

    def bld_listener_spy
      @reception_a = a = []
      Listener_Spy__.new a, -> { do_debug }, -> { debug_IO }
    end

    def expect * x_a, & p
      Actor_Expectation__.new( @reception_a.shift, x_a, p, self ).execute
    end

    def expect_failed
      expect_no_more_events && expect_failure_result
    end

    def expect_succeeded
      expect_no_more_events && expect_success_result
    end

    def expect_no_more_events
      @reception_a.length.zero? or begin
        _msg = "expected no more events, had #{ @reception_a.length } #{
          }(#{ @reception_a.first.to_inspection_string })"
        fail _msg
        STOP_EARLY__
      end
    end

    def expect_success_result
      @result.should eql true
    end

    def expect_failure_result
      @result.should eql false
    end

    # ~ called by expectation agent

    def render_terminal_event ev
      while ev.respond_to? :ev
        ev = ev.ev
      end
      EXPAG__.calculate y=[], ev, & ev.message_proc
      y * Snag_::SPACE_
    end
  end

  # ~

  class Listener_Spy__

    def initialize a, do_debug_p, debug_IO_p
      @do_debug_p = do_debug_p ; @debug_IO_p = debug_IO_p
      @reception_a = a
    end

    def receive_error_event ev
      rcv :error_event, ev
    end

    def receive_info_event ev
      rcv :info_event, ev
    end

    def rcv i, ev
      reception = Reception__.new i, ev
      if @do_debug_p[]
        @debug_IO_p[].puts reception.to_inspection_string
      end
      @reception_a.push reception ; nil
    end

    Reception__ = ::Struct.new :chan_i, :ev
    class Reception__
      def to_inspection_string
        [ chan_i, ev.class ].inspect
      end
    end
  end

  # ~

  class Actor_Expectation__
    def initialize * a
      @reception, x_a, p, @context = a
      @chan_i = x_a.shift
      a = [ :chan ]
      if x_a.first.respond_to? :id2name
        @term_chan_i = x_a.shift
        a.push :term
      end
      if x_a.length.nonzero?
        @expected_x = x_a.shift
        a.push :str
      end
      if p
        @p = p
        a.push :ev_p
      end
      x_a.length.nonzero? and raise ::ArgumentError, "? #{ x_a.first }"
      @assertion_method_i_a = a
    end
    def execute
      if @reception
        flush_assertions
      else
        @context.send :fail, "expected one more event, had none."
      end
    end
  private
    def flush_assertions
      d = -1 ; last = @assertion_method_i_a.length - 1
      while d < last
        d += 1
        send @assertion_method_i_a.fetch( d ) or break
      end ; nil
    end
    def chan
      if @reception.chan_i == @chan_i
        PROCEDE__
      else
        @reception.chan_i.should @context.send( :eql, @chan_i )
        STOP_EARLY__
      end
    end
    def term
      tci = @reception.ev.terminal_channel_i
      if tci == @term_chan_i
        PROCEDE__
      else
        tci.should @context.send( :eql, @term_chan_i )
        STOP_EARLY__
      end
    end
    def str
      str = @context.render_terminal_event @reception.ev
      if str == @expected_x
        PROCEDE__
      else
        str.should @context.send( :eql, @expected_x )
        STOP_EARLY__
      end
    end
    def ev_p
      @p[ @reception.ev ]
      PROCEDE__
    end
  end

  PROCEDE__ = true ; STOP_EARLY__ = false

  EXPAG__ = class Expression_Agent__
    alias_method :calculate, :instance_exec
    def ick x
      "(ick #{ x })"
    end
    def pth x
      "(pth #{ x })"
    end
    def val x
      "(val #{ x })"
    end
    self
  end.new
end
