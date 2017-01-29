module Skylab::TestSupport::TestSupport

  module Quickie

    def self.[] tcc
      tcc.include self
    end

    # -

      define_singleton_method :_dangerous_memoize, Home_::DANGEROUS_MEMOIZE

      # -- this thing

      def given_this_example_ & p
        @EXAMPLE_BODY = p
      end

      def expect_example_passes_with_message_ s
        exe = _execute_the_example
        :pass == exe.category_symbol or fail "expected pass, had fail"
        exe.message == s or fail _say_bad_message( exe, s )
      end

      def expect_example_fails_with_message_ s
        exe = _execute_the_example
        :fail == exe.category_symbol or fail "expected fail, had pass"
        exe.message == s or fail _say_bad_message( exe, s )
      end

      def _say_bad_message exe, s
        "for predicate message, expected #{ s.inspect }, had #{ exe.message.inspect }"
      end

      def _execute_the_example
        _p = remove_instance_variable :@EXAMPLE_BODY
        ExampleExecutionState_via_ExampleBody___[ _p ]
      end

      # -- that thing

      def build_runtime_
        subject_module_::Runtime___.define do |o|
          o.kernel_module = kernel_module_
          o.toplevel_module = toplevel_module_
        end
      end

      def hackishly_start_service_ rt
        o = :_no_see_ts_
        _serr = self.stderr_
        _svc = rt.start_quickie_service_ EMPTY_A_, o, o, _serr, o
        _svc  # hi. #todo
      end

      def stderr_
        :_no_see_ts_
      end

      _dangerous_memoize :kernel_module_with_rspec_not_loaded_ do
        Home_::MockModule.define do |o|
          o.have_method_not_defined :should
          o.expect_to_have_method_defined :should
        end
      end

      _dangerous_memoize :toplevel_module_with_rspec_not_loaded_ do
        Home_::MockModule.define do |o|
          o.have_const_not_defined :RSpec
        end
      end

      _dangerous_memoize :toplevel_module_with_rspec_already_loaded_ do
        Home_::MockModule.define do |o|
          o.have_const_defined :RSpec
        end
      end

      def hack_runtime_to_build_this_service_ rt, & p
        seen = false  # redundant with a test above but meh
        rt.send :define_singleton_method, :__start_quickie_service_autonomously do
          seen && fail
          seen = true
          svc = p[]
          send @_write_quickie_service, svc
          svc
        end
      end

      def begin_mock_module_
        Home_::MockModule.new
      end

      def build_new_sandbox_module_
        Sandbox_moduler___[]
      end

      def subject_module_
        Subject_module__[]
      end
    # -

    # ==

    ExampleExecutionState_via_ExampleBody___ = -> p do
      # -
        rec = RecordingClient___.new
        lib = Subject_module__[]
        _sa = lib::StatisticsAggregator___.new rec
        _ctx = lib::Context__.new _sa
        _result = _ctx.instance_exec( & p )
        rec.flush_via_result _result
      # -
    end

    class RecordingClient___

      def initialize
        @_receive_category_symbol = :__receive_category_symbol_initially
      end

      def receive_failure msg_p, failed_count
        send @_receive_category_symbol, :fail
        _receive_message msg_p
        NIL  # like the production collaborator
      end

      def receive_pass msg_p
        send @_receive_category_symbol, :pass
        _receive_message msg_p
        NIL  # ibid
      end

      def _receive_message msg_p
        @message = msg_p.call  # call it with its original context
        NIL
      end

      def __receive_category_symbol_initially sym
        @category_symbol = sym
        @_receive_category_symbol = :_CLOSED ; nil
      end

      def flush_via_result x
        remove_instance_variable :@_receive_category_symbol
        @result = x
        freeze
      end

      attr_reader(
        :category_symbol,
        :message,
      )
    end

    # ==

    Subject_module__ = Lazy_.call do

      # (normally we don't memoize these but here we hackishly do so that:)

      CoverageFunctions___.maybe_begin_coverage

      Home_::Quickie
    end

    # ==

    module CoverageFunctions___ ; class << self

      # (this is whipped together just to get coverage for the quickie
      # root file. see [#xxx] and [#yyy] for the "proper" way turn on
      # coverage #todo)

      def maybe_begin_coverage
        s = ::ENV[ 'COVER' ]
        if s
          if s =~ /\A(?:yes|true)\z/i
            _do_cover
          elsif s =~ /\A(?:no|false)\z/i
            NOTHING_  # hi.
          else
            fail "say 'true' or 'false' for COVER environment variable (had: #{ s.inspect })"
          end
        end
      end

      def _do_cover

        _gem_dir_path = Home_.dir_path

        require 'simplecov'

        decide = -> path do
          if 'quickie.rb' == ::File.basename( path )
            false
          else
            $stderr.puts "(STRANGE PATH: #{ path })"
            true
          end
        end

        cache = {}
        ::SimpleCov.start do
          add_filter do |source_file|
            path = source_file.filename
            cache.fetch path do
              do_filter_out = decide[ path ]
              cache[ path ] = do_filter_out
            end
          end
          root _gem_dir_path
        end

        NIL
      end
    end ; end

    # ==

    Sandbox_moduler___ = -> do  # exists elsewhere
      box_mod = nil ; last_d = nil
      main = -> do
        mod = ::Module.new
        box_mod.const_set "Module#{ last_d += 1 }", mod
        mod
      end
      p = -> do
        last_d = -1
        box_mod = module SandboxModules___
          self
        end
        ( p = main )[]
      end
      -> do
        p[]
      end
    end.call

    # ==
  end
end
# #born years later
