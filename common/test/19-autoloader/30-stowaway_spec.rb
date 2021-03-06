require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] autoloader - stowaway" do

    define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

    context "proc-based" do

      shared_subject :_jimmy do

        module X_a_s_Jimmy

          Autoloader_[ self ]

          lazily :Ja_Blonk do
            mod = ::Module.new
            def mod.hello_ja_blonk ; end
            mod
          end

          lazily :JaBronie do
            module JaBronie
              def self.hello_ja_bronie
              end
              :_no_see_
            end
          end

          self
        end
      end

      it "if the const does NOT become defined, result value is used" do
        mod = _jimmy::Ja_Blonk
        mod.hello_ja_blonk
        mod.name =~ /Jimmy::Ja_Blonk\z/ || fail
      end

      it "if the const DOES become defined, that is used" do
        mod = _jimmy::JaBronie
        mod.hello_ja_bronie
        mod.name =~ /Jimmy::JaBronie\z/ || fail
      end
    end

    context "the simplest case - guest in sibling eponymous host" do

      shared_subject :ad_hoc_state_ do
        build_ad_hoc_state_
      end

      it "guest asset loads" do
        guest_asset_loads_
      end

      it "guest asset is not autoloaderized" do
        guest_asset_is_not_autoloaderized_
      end

      it "host asset node path is not autoloaderized" do
        host_asset_is_not_autoloaderized_
      end

      def guest_asset_const_
        :TheGuest1
      end

      def host_asset_const_
        :Host1AsEponymousFile
      end
    end

    context "almost the same - guest in sibling-esque corefile" do

      shared_subject :ad_hoc_state_ do
        build_ad_hoc_state_
      end

      it "guest asset loads" do
        guest_asset_loads_
      end

      it "guest asset is not autoloaderized" do
        guest_asset_is_not_autoloaderized_
      end

      it "host asset node path is right" do
        host_asset_node_path_ends_in_ 'host-2-as-corefile'
      end

      def guest_asset_const_
        :TheGuest2
      end

      def host_asset_const_
        :Host_2_As_Corefile
      end
    end

    context "when host has hard to find name" do

      shared_subject :ad_hoc_state_ do
        build_ad_hoc_state_
      end

      it "guest asset loads" do
        guest_asset_loads_
      end

      it "guest asset is not autoloaderized" do
        guest_asset_is_not_autoloaderized_
      end

      it "host asset node path is right" do
        host_asset_is_not_autoloaderized_
      end

      def guest_asset_const_
        :TheGuest3
      end

      def host_asset_const_
        :Host_3_as_Hard_to_Find_NSA_Spy
      end
    end

    context "challenge mode - when host is child of guest" do

      shared_subject :ad_hoc_state_ do
        build_ad_hoc_state_
      end

      it "guest asset loads" do
        guest_asset_value_ || fail
      end

      it "guest asset IS autoloaderized" do

        _hi = guest_asset_value_
        asset_node_path_ends_in_ _hi, 'left-leg'
      end

      it "host asset node path is right" do

        host_asset_node_path_ends_in_ 'left-leg/marsupial-foot--'
      end

      def lookup_host_asset_value_
        ad_hoc_state_
        mod = lookup_guest_asset_value_
        c = :MarsupialFoot__
        if mod.const_defined? c, false
          mod.const_get c, false
        else
          fail
        end
      end

      def lookup_guest_asset_value_
        _top = the_would_be_sidesystem_
        _eek = _top::LEFT_LEG
        _eek
      end

      def the_would_be_sidesystem_
        fixture_directories_::Fftn_TS
      end
    end

    def guest_asset_loads_
      _x = guest_asset_value_
      _x == :_yes_ || fail
    end

    def guest_asset_is_not_autoloaderized_
      _x = guest_asset_value_
      _x.respond_to? Autoloader_::NODE_PATH_METHOD_ and fail
    end

    def host_asset_is_not_autoloaderized_
      _x = host_asset_value_
      _x.respond_to? Autoloader_::NODE_PATH_METHOD_ and fail
    end

    def host_asset_value_
      ad_hoc_state_  # #touch
      lookup_host_asset_value_
    end

    def guest_asset_value_
      _hi = ad_hoc_state_
      _hi.guest_asset
    end

    def host_asset_node_path_ends_in_ tail

      _host_asset = host_asset_value_

      asset_node_path_ends_in_ _host_asset, tail
    end

    def lookup_host_asset_value_

      top = the_would_be_sidesystem_
      _const = host_asset_const_

      if ! top.const_defined? _const, false
        fail
      end

      top.const_get  _const, false
    end

    def lookup_guest_asset_value_

      _top = the_would_be_sidesystem_
      _const = guest_asset_const_
      _top.const_get _const, false
    end

    def asset_node_path_ends_in_ asset, tail

      _head = the_would_be_sidesystem_.send Autoloader_::NODE_PATH_METHOD_
      expected_node_path = ::File.join _head, tail
      tail = nil

      # --

      if ! asset.respond_to? Autoloader_::NODE_PATH_METHOD_
        fail
      end

      _actual = asset.send Autoloader_::NODE_PATH_METHOD_

      _actual == expected_node_path || fail
    end

    def build_ad_hoc_state_

      _xx = lookup_guest_asset_value_

      X_a_ss_Struct.new _xx
    end

    X_a_ss_Struct = ::Struct.new :guest_asset

    def the_would_be_sidesystem_
      fixture_directories_::Elvn_Ferce
    end

    def fixture_directories_
      TS_::FixtureDirectories
    end
  end
end
