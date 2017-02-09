module Skylab::TestSupport

  module Quickie

    class Plugins::Cover  # :[#002]

      # ironically or not this is not covered as well as it could be
      # (at writing only the "find longest common base path" magnet is),
      # (but at least it is working again for the first time in years)

      def initialize
        o = yield
        @_listener = o.listener
        @_shared_datapoint_store = o
      end

      def description_proc
        method :__describe_into
      end

      def __describe_into y
        y << "run the coverage service for the"
        y << "subtree inferred by the test files"
      end

      def parse_argument_scanner_head
        ACHIEVED_  # it's a flag; nothing to do.
      end

      def release_agent_profile

        Eventpoint_::AgentProfile.define do |o|
          o.must_transition_from_to :files_stream, :files_stream
        end
      end

      def invoke _
        ok = true
        ok &&= __resolve_debug_IO_which_is_for_now_required
        ok &&= __resolve_longest_common_base_path_of_all_test_files
        ok &&= __find_test_directory_in_that_path
        ok &&= __find_offset_of_project_directory_element
        ok &&= __find_gem_path_via_those_things
        ok &&= __infer_root_path_via_gem_path
        ok &&= __resolve_caching_filter
        ok ? __MONEY : Responses_.the_stop_response
      end

      def __MONEY

        x = __response
        filter = remove_instance_variable :@__caching_filter
        coverage_root_path = @_coverage_root_path

        require 'simplecov'
        ::SimpleCov.start do

          command_name "(the skylab test-support simplecov plugin)"

          add_filter do |source_file|
            filter.filter source_file.filename
          end

          root coverage_root_path
        end

        x
      end

      def __response
        paths = remove_instance_variable :@__cached_test_files
        Responses_::Datapoint.new -> { Stream_[ paths ] }, :test_file_path_streamer
      end

      def __resolve_caching_filter

        rx = /\A(?:\d+-)?/

        _r = @_offset_of_project_directory_element + 1 .. -1
        _lemmatics = @_argument_path_object.elements[ _r ].map do |entry|
          rx.match( entry ).post_match.split( DASH_ ).map( & :intern )
        end

        @__caching_filter = CachingFilter___.new(
          _lemmatics, @_coverage_root_path, & @_listener )

        ACHIEVED_
      end

      def __infer_root_path_via_gem_path

        # (we could take the extra step of adding interceding guys but..)

        basename = ::File.basename @_gem_path
        these = basename.split DASH_
        # leap of faith hack: if the last part looks like a version ..

        if /\A\d+/ =~ these.last
          these.pop
        end

        path = ::File.join @_gem_path, 'lib', * these

        if _directory_exists path
          @_coverage_root_path = path ; true
        else
          self.__COVER_ME__whine_about_this__
        end
      end

      def __find_gem_path_via_those_things

        # this is where it gets weird - we're assuming our hacks ..

        _guy = @_project_path_object.elements.fetch(
          @_offset_of_project_directory_element )

        _glob = ::File.join Gem.dir, 'gems', "*#{ _guy }*"

        these = ::Dir.glob _glob

        case  1 <=> these.length
        when  1 ; self._COVER_ME__gem_not_found__
        when  0 ; @_gem_path = these.fetch 0 ; ACHIEVED_
        when -1 ; self._COVER_ME__multiple_gems_found__
        end
      end

      def __find_offset_of_project_directory_element

        d = remove_instance_variable :@__index_of_test_directory
        path_o = remove_instance_variable :@_longest_common_path_object
        proj_path_o = path_o.new_via_elements path_o.elements[ 0, d ]

        proj_path = proj_path_o.to_string
        if ! proj_path_o.is_absolute
          abs_proj_path = ::File.expand_path proj_path
          abs_proj_path_o = proj_path_o.class.via_path abs_proj_path
          _this_much_longer =
            abs_proj_path_o.elements.length - proj_path_o.elements.length
          d += _this_much_longer
          proj_path = abs_proj_path ; proj_path_o = abs_proj_path_o
        end

        if _directory_exists proj_path
          if d.zero?
            self._COVER_ME__cannot__
          else
            @_argument_path_object = path_o
            @_offset_of_project_directory_element = d - 1
            @_project_path_object = proj_path_o ; ACHIEVED_
          end
        else
          self._COVER_ME__directory_not_found__
        end
      end

      def __find_test_directory_in_that_path

        is_test_directory = Home_.lib_.match_test_dir_proc  # # => ["test", "spec", "features"].method :include?

        s_a = is_test_directory.receiver  # awful

        d = @_longest_common_path_object.elements.index( & is_test_directory )

        if d
          @__index_of_test_directory = d ; true
        else
          __whine_about_test_directory_not_found s_a
          UNABLE_
        end
      end

      def __whine_about_test_directory_not_found s_a

        _or_these = Common_::Oxford_or[ s_a.map( & :inspect ) ]

        _this = @_longest_common_path.to_string.inspect

        @_listener.call :error, :expression, :test_directory_not_found do |y|
          y << "needed to find but didn't find #{ _or_these } in #{ _this }"
        end
      end

      def __resolve_longest_common_base_path_of_all_test_files

        st = @_shared_datapoint_store.release_test_file_path_streamer_.call

        did_reach_finish = false
        paths_cache = []

        _use_this_stream = -> do
          path = st.gets
          if path
            paths_cache.push path
            path
          else
            did_reach_finish = true ; path
          end
        end

        o = LongestCommonBasePath_via_Stream___.new( _use_this_stream ).execute
        if o
          did_reach_finish || self._SANITY
          @__cached_test_files = paths_cache
          @_longest_common_path_object = o ; true
        else
          __whine_about_no_common_base_path did_reach_finish, paths_cache
          UNABLE_
        end
      end

      def __whine_about_no_common_base_path did_reach_finish, paths_cache
        @_listener.call :error, :expression, :no_LCBP_found do |y|
          _ = did_reach_finish ? " the" : " the first"
          y << "no common base path among#{ _ } #{ paths_cache.length } #{
            }test files in that collection"
        end
      end

      def _directory_exists path
        ::File.directory? path
      end

      def __resolve_debug_IO_which_is_for_now_required
        _ = @_listener.call :resource, :line_downstream_for_help  # eek/meh
        _store :@_debug_IO, _
      end

      def _store ivar, x
        if x ; instance_variable_set ivar, x ; ACHIEVED_ ; else x end
      end

      # ==

      class CachingFilter___

        # (for whatever reason, simplecov emits the same paths multiple times)

        # for a longest common base path of
        #
        #     test/80-frobits/90-fiz-buzulator
        #
        # (note the leading numbers in directory names,
        # which we often use for [#ts-001] regression name conventions),
        #
        # and a gem path of
        #
        #     /usr/me/.gem/my-great_gem-3.0.0/lib/my/great_gem
        #
        # this implies there is a directory something like
        #
        #     /usr/me/.gem/my-great_gem-3.0.0/lib/my/great_gem/frobits-/fiz-buzulator--
        #
        # (note the trailing dashes in some directory names, used pursuant
        # to [#bs-029] module naming conventions),
        #
        # the "lemmatics" of this path of interest is:
        #
        #     [ [:frobits], [:fiz, buzulator] ]
        #
        # we use the lemmatics to compare an asset path against a test
        # directory path to decide if the one is a associated with the other.

        def initialize lemmatics, coverage_root_path

          @_cache = {}
          @__head_string = ::File.join coverage_root_path, EMPTY_S_
          @__lemmatics_length = lemmatics.length
          @__range = @__head_string.length .. -1

          @lemmatics = lemmatics
        end

        def filter path
          @_cache.fetch path do
            yes = __decide path
            @_cache[ path ] = yes
            yes
          end
        end

        def __decide path
          d = path.index @__head_string
          if d && d.zero?
            __decide_further path
          else
            @_listener.call :error, :expression, :sanity do |y|
              y << "STRANGE: #{ path }"
            end
            FILTER_IT_OUT_
          end
        end

        def __decide_further path

          @_ENTRIES = path[ @__range ].split ::File::SEPARATOR
          if @_ENTRIES.length < @__lemmatics_length
            _filter_it_out
          else
            __decide_even_further
          end
        end

        def __decide_even_further

          yes = FILTER_IT_OUT_
          target_scn = Common_::Scanner.via_array @lemmatics
          actual_st = __actual_lemmatic_stream_via_entries

          begin
            actual_lemmatic = actual_st.gets
            actual_lemmatic || break  # any time you run out of actuals here, no match

            target_lemmatic = target_scn.gets_one

            if target_lemmatic != actual_lemmatic
              break
            end

            if target_scn.no_unparsed_exists
              # (if you reach the end of the target chain, it's a match)
              yes = THIS_ONE_STAYS_
              break
            end

            redo
          end while above

          if FILTER_IT_OUT_ == yes
            _filter_it_out
          else
            __filter_it_in
          end
        end

        def __actual_lemmatic_stream_via_entries

          # turn the interesting tail of a path into a stream of lemmatics

          entry_st = Stream_[ @_ENTRIES ]
          on_deck = entry_st.gets  # always one, right?
          p = -> do
            x = entry_st.gets
            if x
              now = on_deck
              on_deck = x
              Lemmatic_via_AssetEntryThatIsDirectory__[ now ]
            else
              p = EMPTY_P_
              d = ::File.extname( on_deck ).length
              d.zero? && fail
              _stem = on_deck[ 0 ... -d ]
              Lemmatic_via_AssetEntryThatIsDirectory__[ _stem ]
            end
          end

          Common_.stream do
            p[]
          end
        end

        def _filter_it_out
          @_debug_IO.puts "filtered out: #{ _pretty_entries }"
          FILTER_IT_OUT_
        end

        def __filter_it_in
          @_debug_IO.puts "filtered in:  #{ _pretty_entries }"
          THIS_ONE_STAYS_
        end

        def _pretty_entries
          ::File.join( * @_ENTRIES )
        end

        # --

        FILTER_IT_OUT_ = true
        THIS_ONE_STAYS_ = false

        # --
      end

      Lemmatic_via_AssetEntryThatIsDirectory__ = -> do

        disregard_trailing_dashes_rx = /-*\z/

        -> entry do
          _stem = disregard_trailing_dashes_rx.match( entry ).pre_match
          _stem.split( DASH_ ).map( & :intern )
        end
      end.call

      # ==

      class LongestCommonBasePath_via_Stream___

        def initialize st
          @_see_path = :__see_first_path
          @__stream = NormalPathStream_via_LineStream___[ st ]
        end

        def execute
          st = remove_instance_variable :@__stream
          path = st.call
          if path

            begin
              keep_going = send @_see_path, path
              keep_going || break
              path = st.call
            end while path

            if keep_going
              __finish
            end
          else
            NOTHING_
          end
        end

        def __see_first_path path
          @__first_path = path
          @_longest_common_elements = path.elements.dup
          @_longest_common_elements_length = @_longest_common_elements.length
          @_is_absolute = path.is_absolute
          @_see_path = :__see_nonfirst_path
          KEEP_GOING_
        end

        def __see_nonfirst_path path
          if @_is_absolute == path.is_absolute
            __when_same_category path
          else
            STOP_EARLY_
          end
        end

        def __when_same_category path

          these_elements = path.elements
          this_length = these_elements.length

          if this_length < @_longest_common_elements_length
            use_length = this_length
          else
            use_length = @_longest_common_elements_length
          end

          current_matching_length = 0
          begin
            use_length == current_matching_length && break
            @_longest_common_elements.fetch( current_matching_length ) ==
              these_elements.fetch( current_matching_length ) or break
            current_matching_length += 1
            redo
          end while above

          if current_matching_length < @_longest_common_elements_length
            if current_matching_length.zero?
              STOP_EARLY_
            else
              @_longest_common_elements[ current_matching_length..-1 ] = EMPTY_A_
              @_longest_common_elements_length = current_matching_length
              KEEP_GOING_
            end
          else
            KEEP_GOING_
          end
        end

        def __finish
          remove_instance_variable( :@__first_path ).new_via_elements(
            remove_instance_variable( :@_longest_common_elements ) )
        end
      end

      # ==

      NormalPathStream_via_LineStream___ = -> st do  # (see Path___)
        -> do
          path = st.call
          if path
            if path.length.zero?
              THE_EMPTY_PATH___  # not defined
            else
              Path___.via_path path
            end
          end
        end
      end

      # ==

      class Path___

        # (mainly this was created because a crude implementation using
        # `split` would lead you to believe things like that path "/A"
        # and path "/B" have a head element "" (the empty string) in common;
        # or that likewise the empty path ("") and that any absoslute path
        # similarly have such a head-anchored element common.)

        class << self
          def via_path path
            s_a = path.split ::File::SEPARATOR
            if s_a.first.length.zero?
              is_absolute = true
              s_a.shift
            end
            new is_absolute, s_a
          end
        end  # >>

        def initialize yes, s_a
          @elements = s_a
          @is_absolute = yes
        end

        def to_string
          s_a = @elements
          if @is_absolute
            s_a = [ EMPTY_S_, * s_a ]  # meh
          end
          s_a * ::File::SEPARATOR
        end

        def new_via_elements s_a
          self.class.new @is_absolute, s_a
        end

        attr_reader :is_absolute, :elements
      end

      # ==

      EMPTY_A_ = []
      KEEP_GOING_ = true
      NOTHING_ = nil
      STOP_EARLY_ = false

      # ==
    end
  end
end
# #tombstone-B: full rewrite from standalone executable to become quickie plugin
# :+#tombstone: rspec integration (ancient)
