require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - directory (feature branch via directory)" do

    TS_[ self ]
    use :memoizer_methods

    it "splay over empty directory" do

      _given_stubbed_empty_directory
      _want_no_items
    end

    it "splay over noent directory" do

      _given_real_no_ent_directory
      _want_no_items
    end

    it "splay over non empty directory" do

      _given_stubbed_NON_empty_directory

      _want_names(
        :red_time,
        :orange_pal,
        :yellow_friend,
        :blue_buddy,
      )
    end

    it "splay over non empty directory, filter using glob" do

      _given_stubbed_NON_empty_directory

      _given do |o|
        o.glob_entry = '*.yes'
      end

      _want_names(
        :orange_pal,
        :blue_buddy,
      )
    end

    it "splay over non empty directory, filter using regex" do

      _given_stubbed_NON_empty_directory

      _given do |o|
        o.filename_pattern = /\A(re|bl)/
      end

      _want_names(
        :red_time,
        :blue_buddy,
      )
    end

    context "splay over noent directory, add warning" do

      it "results in no guys" do

        _tuple.last.length.zero? || fail
      end

      it "emission says.." do

        _ev = _tuple.first

        _actual = _ev.express_into_under [], expression_agent_of_API_classic_

        want_these_lines_in_array_ _actual do |y|
          y << /\ANo such file or directory - «.+no-ent»\z/
        end
      end

      shared_subject :_tuple do

        _given_real_no_ent_directory

        _given do |o|
          o.directory_is_assumed_to_exist = false
        end

        a = []
        want :error, :enoent do |ev|
          a.push ev
        end

        execute_by do
          _st = _flush_to_stream
          a.push _st.to_a
        end

        a
      end
    end

    it "dererference from empty directory" do

      _e_class = _subject_module::KeyError

      _given_stubbed_empty_directory
      ob = _flush_to_OB
      begin
        ob.dereference :guy
      rescue _e_class => e
      end

      e.message == "no file corresponding to 'guy' in directory - shibboleth-empty-dir" || fail
    end

    it "soft lookup from empty directory" do

      _given_stubbed_empty_directory
      ob = _flush_to_OB
      _x = ob.lookup_softly :guy
      _x.nil? || fail
    end

    it "dereference ordinary" do

      _given_stubbed_NON_empty_directory
      ob = _flush_to_OB
      _item = ob.dereference :orange_pal
      _item.normal_symbol == :orange_pal || fail
    end

    it "one stream straddles another stream" do

      _given_stubbed_NON_empty_directory_TWO
      ob = _flush_to_OB

      o = -> st, sym=nil do
        if sym
          _item = st.gets
          _item.normal_symbol == sym || fail
        else
          _item = st.gets
          _item && fail
        end
      end

      st1 = ob.to_loadable_reference_stream

      o[ st1, :billy ]
      o[ st1, :bob ]

      st2 = ob.to_loadable_reference_stream
      o[ st2, :billy ]
      o[ st1, :thornton ]
      o[ st1 ]
      o[ st2, :bob ]
      o[ st2, :thornton ]
      o[ st2 ]
    end

    context "gets one, gets another, dereference one 2 hops forward, gets, gets .." do

      it "the external stream is self-consistent with its order, independent of The One scanner" do
        _binding
      end

      it "an item that you dereference before it was reached in the stream is same item both times" do
        _want_same_item :fourth_dereffed, :fourth
      end

      it "mid stream, dereference an item that was streamed over before your first dereferece. same" do
        _want_same_item :first, :first_dereffed
      end

      it "after stream closes, dereference an item you streamed over. same" do
        _want_same_item :fifth, :fifth_dereffed
      end

      shared_subject :_binding do

        _given_stubbed_NON_empty_directory_THREE
        ob = _flush_to_OB
        st = ob.to_loadable_reference_stream

        first = st.gets
        first.normal_symbol == :one || fail
        second = st.gets
        second.normal_symbol == :two || fail

        fourth_dereffed = ob.dereference :four
          # (this dereference pushes The One scanner forward)
        fourth_dereffed || fail

        third = st.gets
        third.normal_symbol == :three || fail
          # (but note this detached stream is consistent with itself)

        fourth = st.gets
        fourth.normal_symbol == :four || fail

        fifth = st.gets
        fifth.normal_symbol == :five || fail

        first_dereffed = ob.dereference :one
          # (dereference an item from before we started dereferencing)
        first_dereffed || fail

        _wat = st.gets
        _wat && fail

        fifth_dereffed = ob.dereference :five
          # (dereference an item from after our first dereference)
        fifth_dereffed || fail

        binding  # wahoo
      end
    end

    # -- want (née "expect")

    def _want_same_item var_one, var_two

      bnd = _binding
      item_one = bnd.local_variable_get var_one
      item_two = bnd.local_variable_get var_two

      # (we have already checked for the trueishness of those items that
      # were dereferenced, and so we're doing it here redundantly, but
      # since we provide the two ivar arguments in an order corresponding
      # to their assignment, we just check it redundantly again.)

      item_one || fail
      item_two || fail

      # (since we are asserting same object ID it's not necessary to check
      # for trueishness of both (we could just check one or the other); but
      # this way we get a more dedicated failure than we would below.)

      if item_one.object_id != item_two.object_id
        if item_one.normal_symbol == item_two.normal_symbol
          fail "`#{ var_one }` and `#{ var_two }` were two different instances"
        else
          fail "had #{ item_one.normal_symbol } for `#{ var_one }` and #{
            }#{ item_two.normal_symbol } for `#{ var_two }`"
        end
      end
    end

    def _want_no_items
      _st = _flush_to_stream
      _one = _st.gets
      _one && fail
    end

    def _want_names * sym_a
      _fb = _flush_to_OB
      st = _fb.to_loadable_reference_stream
      actual_sym_a = []
      while item=st.gets
        actual_sym_a.push item.normal_symbol
      end
      expect( actual_sym_a ).to eql sym_a
    end

    def _flush_to_stream
      _fb = _flush_to_OB
      _st = _fb.to_loadable_reference_stream
      _st
    end

    def _flush_to_OB

      p_a = remove_instance_variable :@PREPARATIONS

      _fb = _subject_module.define do |o|

        p_a.each do |p|
          p[ o ]
        end

        o.loadable_reference_via_path_by = X_fs_dir_Item_via_Path

        # yikes:
        if instance_variable_defined? :@EMISSION_SPY
          o.listener = @EMISSION_SPY.listener
        end
      end

      _fb  # hi.
    end

    # -- setup

    def execute_by & p
      spy = @EMISSION_SPY  # leave it set - listener of it is used below
      spy.call_by( & p )
      spy.execute_under self
    end

    def _given_real_no_ent_directory

      _given do |o|
        o.startingpoint_path = the_no_ent_directory_
      end
    end

    def _given_stubbed_NON_empty_directory_THREE

      _given do |o|
        o.startingpoint_path = 'severalz'
        o.filesystem_for_globbing = X_fs_dir_STUBBED_FS
      end
    end

    def _given_stubbed_NON_empty_directory_TWO

      _given do |o|
        o.startingpoint_path = 'b.b.t'
        o.filesystem_for_globbing = X_fs_dir_STUBBED_FS
      end
    end

    def _given_stubbed_NON_empty_directory

      _given do |o|
        o.startingpoint_path = 'shibboleth-NON-empty-dir'
        o.filesystem_for_globbing = X_fs_dir_STUBBED_FS
      end
    end

    def _given_stubbed_empty_directory

      _given do |o|
        o.startingpoint_path = 'shibboleth-empty-dir'
        o.filesystem_for_globbing = X_fs_dir_STUBBED_FS
      end
    end

    def want * chan, & recv
      _spy.want_emission recv, chan
      NIL
    end

    def _spy
      @EMISSION_SPY ||= Common_.test_support::Want_Emission_Fail_Early::Spy.new
    end

    # -- support

    def _given & p
      ( @PREPARATIONS ||= [] ).push p ; nil
    end

    def _subject_module
      Home_::Filesystem::Directory::FeatureBranch_via_Directory
    end

    X_fs_dir_Item_via_Path = -> path do
      X_fs_dir_Item.new path
    end

    class X_fs_dir_Item

      def initialize path
        bn = ::File.basename path
        d = ::File.extname( bn ).length
        stem = d.zero? ? bn : bn[ 0 ... -d ]
        @normal_symbol = stem.gsub( Home_::DASH_, Home_::UNDERSCORE_ ).intern
      end

      attr_reader(
        :normal_symbol,
      )
    end

    module X_fs_dir_STUBBED_FS ; class << self

      def glob glob
        X_fs_dir_THIS_HASH.fetch( glob ).call
      end
    end ; end

    X_fs_dir_THIS_HASH = {

      'b.b.t/*' => -> do
        %w(
          /xx/yy/billy.qq
          /xx/yy/bob
          /xx/yy/thornton.pp
        )
      end,

      'severalz/*' => -> do
        %w( one two three four five )
      end,

      'shibboleth-empty-dir/*' => -> { EMPTY_A_ },

      'shibboleth-NON-empty-dir/*' => -> { X_fs_dir_THESE },

      'shibboleth-NON-empty-dir/*.yes' => -> do
        a = X_fs_dir_THESE
        [ a[1], a[3] ]
      end,
    }

    # ==

    X_fs_dir_THESE = %w(
      /blim/blam/red-time
      /blim/blam/orange-pal.yes
      /blim/blam/yellow-friend.no
      /blim/blam/blue-buddy.yes
    )

    # ==
    # ==
  end
end
# #history-A: full rewrite during assimilation two nodes into one.
