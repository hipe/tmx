require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] file tree (public API)" do

    define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

    shared_subject :_top_subject do
      _path = TestSupport_.dir_path  # this is the only one that is already loaded for sure
      _ftc = Autoloader_::File_tree_cache___[]
      _ftc[ _path ]
    end

    this_method = :to_asset_ticket_stream

    context "essentials, `#{ this_method }`" do

      it "builds (or already exists)" do
        _top_subject || fail
      end

      it "`#{ this_method }` produces stream ; produces one item" do
        _asset_ticket || fail
      end
    end

    context "edges" do

      it "if no directory on the filesystem.." do

        _mod = TS_::FixtureDirectories::Twlv_DLI::Agtion
        _mod.respond_to? :entry_tree and fail
      end
    end

    shared_subject :_asset_ticket do
      st = _top_subject.send this_method
      _at = st.gets
      _at  # #todo
    end

    context "state machine" do

      it "entry group head" do
        _asset_ticket.entry_group_head || fail
      end

      it "get node path" do
        _asset_ticket.get_node_path || fail
      end
    end
  end
end
# #born: during rewrite of autoloader
