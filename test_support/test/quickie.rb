module Skylab::TestSupport::TestSupport

  module Quickie

    def self.[] tcc
      tcc.include self
    end

    # -

      define_singleton_method :_dangerous_memoize, Home_::DANGEROUS_MEMOIZE

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

      define_method :subject_module_, ( Lazy_.call do

        # (normally we don't memoize these but here we hackishly do so that:)

        CoverageFunctions___.maybe_begin_coverage

        Home_::Quickie
      end )
    # -

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
