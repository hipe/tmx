require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - token stream stream via directory object" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics

    context "(context)" do

      it "builds" do
        _h || fail
      end

      it "skips over leading dots" do
        _has '.' and fail
        _has '..' and fail
      end

      it "skips over leading underscores" do
        _has '_not-me' and fail
      end

      it "includes directory-looking entries" do
        _has 'yes-me' or fail
      end

      it "includes unassociated-looking entries" do
        _has 'jiggernaut' or fail
      end

      it "includes the rest" do
        _has 'shomply-domply-via-plomply' or fail
        _has 'joopie-via-proopie-and-soopie' or fail
      end

      def _has s
        _h.key? s
      end

      shared_subject :_h do

        __hash_via_entries_array %w(
          .
          ..
          shomply-domply-via-plomply.rb
          joopie-via-proopie-and-soopie.rb
          _not-me.rb
          yes-me
          jiggernaut.rb
        ).freeze
      end
    end

    def __hash_via_entries_array a

      _DASH = '-'

      _dir = TS_::Magnetics::MockDirectory.via_all_entries_array a

      tss = magnetics_module_::TokenStreamStream_via_DirectoryObject[ _dir ]

      h = {}
      begin
        ts = tss.gets
        ts || break
        buffer = ts.gets  # be a jerk
        begin
          s = ts.gets
          s or break
          buffer << _DASH << s
          redo
        end while nil
        h[ buffer ] = true
        redo
      end while nil
      h
    end
  end
end
