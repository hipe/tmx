require_relative '../test-support'

module Skylab::Plugin::TestSupport

  describe "[pl] magnetics - [..] one deeper" do

    TS_[ self ]
    use :memoizer_methods

    # three laws.

    # (the main objective of this test was to test the wacky caching state)

    it "loads" do
      _subject_module || fail
    end

    it "build with any module and any path" do
      _via_entry_and_branch_module( 'zzimmy.rb', _mods::AnyModule ) || fail
    end

    it "get the stream once, get one item, don't complete the stream" do
      _o = _build_this_one
      st = _o.to_asset_reference_stream
      _lt = st.gets
      _lt.normal_symbol == :foo || fail
    end

    it "repeat exactly the above, but get the stream again and get 3 items" do

      o = _build_this_one
      st = o.to_asset_reference_stream
      _lt = st.gets
      _lt.normal_symbol == :foo || fail

      st = o.to_asset_reference_stream
      _st = st.gets
      _lt.normal_symbol == :foo || fail

      _lt = st.gets
      _lt.normal_symbol == :bar || fail
      _lt = st.gets
      _lt.normal_symbol == :baz_qux || fail

      st.gets && fail
    end

    def _build_this_one
      _sys = _this_one_mock_system
      _subject_module.define do |o|
        o.entry = 'shinola.kode'
        o.branch_module = _mods::ThisOneModule
        o.system = _sys
      end
    end

    shared_subject :_this_one_mock_system do

      _mods::MockSystem.define do |o|

        o.add_glob '/fake/dir-path-one/*/shinola.kode' do
          Home_::Stream_[ %w( foo bar baz-qux ) ]
        end
      end
    end

    memoize :_mods do

      module X_fsb_modules

        class MockSystem < Home_::SimpleModel_

          def initialize
            @_globs = {}
            super
          end

          def add_glob k, & p
            @_globs[ k ] = p ; nil
          end

          # -- read

          def glob glob  # <- great value. name brand: `::Dir.glob`
            head, tail = GLOB_RX___.match( glob ).captures
            @_globs.fetch( glob ).call.map_by do |mid|
              "#{ head }#{ mid}#{ tail }"
            end.to_a
          end

          GLOB_RX___ = /\A(?<head>[^*]+)\*(?<tail>[^*]+)\z/
        end

        module ThisOneModule

          def self.dir_path
            '/fake/dir-path-one'
          end

        end

        AnyModule = ::Module.new
        self
      end
    end

    def _via_entry_and_branch_module entry, mod
      _subject_module.define do |o|
        o.entry = entry
        o.branch_module = mod
      end
    end

    def _subject_module
      Home_::Magnetics::OperatorBranch_via_DirectoryOneDeeper
    end
  end
end
