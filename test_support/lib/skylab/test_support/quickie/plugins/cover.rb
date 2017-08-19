module Skylab::TestSupport

  module Quickie

    class Plugins::Cover  # see [#002]. (full algorithm)

      # ironically or not this is not covered as well as it could be
      # (at writing only the "find longest common base path" magnet is),
      # (but at least it is working again for the first time in years)

      # but see [#doc] for extensive explanation of behavior and API.

      def initialize
        o = yield

        @filesystem = ::File

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
        ok &&= __SHIM_DIM_MC_NIM
        ok &&= __find_test_directory_in_that_path
        ok &&= __find_offset_of_project_directory_element
        ok &&= __find_gem_path_via_those_things
        ok &&= __infer_root_path_via_gem_path
        ok &&= __resolve_caching_filter
        ok ? __MONEY : Responses_.the_stop_response
      end

      def __MONEY

        x = __response
        filter = remove_instance_variable :@_caching_filter
        coverage_root_path = @_coverage_root_path

        require 'simplecov'
        ::SimpleCov.start do

          command_name "(the skylab test-support simplecov plugin)"

          add_filter do |source_file|
            filter.filter source_file.filename
          end

          root coverage_root_path  # :#here2
        end

        x
      end

      def __response
        paths = remove_instance_variable :@_cached_test_files
        Responses_::Datapoint.new -> { Stream_[ paths ] }, :test_file_path_streamer
      end

      def __resolve_caching_filter

        rx = /\A(?:\d+-)?/  # :#here1

        d = @_offset_of_project_directory_element_for_argument_path_MIGHT_BE_NEGATIVE

        # `d` points to the imagined offset of the project component in the
        # argument path. why this is typcally `-1` is explained here:
        #
        # what is typical (but not mandatory) is that you are in the root
        # directory of your project (so, the toplevel directory).
        #
        # what is furthermore typical is that you will have supplied a path
        # or paths on the command line that are relative and downwards-only
        # from where you stand (so plain old paths "like/this").
        #
        # (if one or a few "." or ".." is in your path, this is both
        # undefined and terrifying to imagine.)
        #
        # as such, if you are at the root of your project and all these
        # other "typical" provisions hold, the project component of your
        # path corresponds to the directory you are in, and that directory
        # is not reflected directly in your argument path but is instead
        # sort of floating off to the left side from it.
        #
        # this is why `d` is `-1` is because it's the imaginary slot to
        # the left of offset `0` (the first component in your path).
        # it is CRUCIAL that we don't accidentally use a negative integer
        # as a real index into an array, because etc.

        d += 1  # after this line, `d` points to `test`

        d += 1  # after this line, `d` points to the first element after `test`

        0 <= d or self._COVER_ME__youre_in_too_deep__

        _r = d .. -1

        @_lemmatics = @_argument_path_object.elements[ _r ].map do |entry|
          rx.match( entry ).post_match.split( DASH_ ).map( & :intern )
        end

        if @_lemmatics.length.zero?
          if @_these_hash.length.zero?
            _when_all_pass
          else
            __when_all_pass_and_some_specified
          end
        else
          _init_caching_filter_normally
        end
      end

      def __when_all_pass_and_some_specified
        d = @_these_hash.length
        _info do |y|
          y << "(all files pass given the arguments, #{
            }regardless of #{ d } magic lines.)"
        end
        _when_all_pass
      end

      def _when_all_pass
        _info() { "(all files pass given these arguments.)" }
        _init_caching_filter_normally
      end

      def _init_caching_filter_normally

        @_caching_filter = CachingFilter___.new(
          remove_instance_variable( :@_lemmatics ),
          remove_instance_variable( :@_these_hash ),
          @_coverage_root_path,
          @_debug_IO,
          & @_listener )

        ACHIEVED_  # convenience
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

        _guy = @_absolute_project_path_object.elements.fetch(
          @_offset_of_project_directory_element_for_absolute_path )

        _glob = ::File.join Gem.dir, 'gems', "*#{ _guy }*"

        these = ::Dir.glob _glob

        case  1 <=> these.length
        when  1 ; self._COVER_ME__gem_not_found__
        when  0 ; @_gem_path = these.fetch 0 ; ACHIEVED_
        when -1 ; self._COVER_ME__multiple_gems_found__
        end
      end

      def __find_offset_of_project_directory_element

        itd_d = remove_instance_variable :@__index_of_test_directory

        arg_path_o = remove_instance_variable :@_longest_common_path_object

        _shorter_elements = arg_path_o.elements[ 0, itd_d ]

        # (the above is zero length if we are inside the project (which is typical))

        proj_path_o = arg_path_o.new_via_elements _shorter_elements

        proj_path = proj_path_o.to_string

        if proj_path_o.is_absolute

          abs_proj_path_o = proj_path_o ; proj_path_o = nil

          abs_proj_path = proj_path ; proj_path = nil

          abs_d = itd_d - 1

          arg_d = abs_d
        else

          abs_proj_path = ::File.expand_path proj_path ; proj_path = nil

          abs_proj_path_o = proj_path_o.class.via_path abs_proj_path

          _this_much_longer = abs_proj_path_o.elements.length -
            proj_path_o.elements.length ; proj_path_o = nil

          arg_d = itd_d - 1

          abs_d = arg_d + _this_much_longer
        end

        if ! _directory_exists abs_proj_path
          self._COVER_ME__project_directory_not_found
        elsif 1 > abs_d
          self._COVER_ME__cannot__
        else
          @_argument_path_object = arg_path_o
          @_offset_of_project_directory_element_for_argument_path_MIGHT_BE_NEGATIVE = arg_d
          @_offset_of_project_directory_element_for_absolute_path = abs_d
          @_absolute_project_path_object = abs_proj_path_o
          ACHIEVED_
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

        _this = @_longest_common_path_object.to_string.inspect

        @_listener.call :error, :expression, :resource_not_found do |y|
          y << "needed to find but didn't find #{ _or_these } in #{ _this }"
        end
      end

      def __SHIM_DIM_MC_NIM

        # TOTALLY EXPERIMENT: tired of making things line up? wonderhack:
        #
        # you can now broaden the set of files that will be matched for
        # coverage by specifying them explicitly at the top of your test
        # file with contiguous, first-line-anchored lines like this:
        #
        #     # covers: foo-/bar-baz--/wazooza.rb
        #     # covers: some/other/file.rb

        seen = {}

        count_of_magic_lines = 0
        count_of_participating_files = 0
        count_of_total_files = @_cached_test_files.length

        path_st = Stream_[ @_cached_test_files ]

        #   - a non-participating file does not break the indexing.
        #     (with long lists of files this could cause noticeable latency.)
        #
        #   - for a file to be recognized as participating, its magic lines
        #     must be head-anchored and contigous (i.e line 1, 2 & 3 not
        #     line 5, 7 & 9.)

        begin
          path = path_st.gets
          path || break
          md_st = __matchdata_stream_via_path path
          md = md_st.call
          md || redo
          count_of_participating_files += 1
          begin
            count_of_magic_lines += 1
            seen[ md[ :this ] ] = true
            md = md_st.call
          end while md
          redo
        end while above

        __express_these_statistics(
          count_of_magic_lines,
          count_of_participating_files,
          count_of_total_files,
        )

        @_these_hash = seen
        ACHIEVED_
      end

      def __express_these_statistics(
        count_of_magic_lines,
        count_of_participating_files,
        count_of_total_files
      )

        if count_of_participating_files.zero?
          _info(){ "(searched #{ count_of_total_files } #{
            }file(s) for magic lines, found none.)" }
        else
          _info do |y|
            if count_of_participating_files == count_of_total_files
              if 1 == count_of_total_files
                y << "(we see you, #{ count_of_magic_lines } magic line(s))"
              else
                y << "(saw #{ count_of_magic_lines } magic line(s) #{
                  }in all #{ count_of_total_files } files.)"
              end
            else
              y << "(saw magic lines in #{ count_of_participating_files } #{
                }of #{ count_of_total_files } files.)"
            end
          end
        end
        NIL
      end

      def __matchdata_stream_via_path test_path
        io = @filesystem.open test_path
        -> do
          line = io.gets  # we're gonna assume every test file has at least one line
          md = /\A[ \t]*#[ \t]*covers:[ \t]*(?<this>.+)/.match line
          if md
            md
          else
            io.close ; NOTHING_  # hope the user discards this proc now
          end
        end
      end

      # --

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
          @_cached_test_files = paths_cache
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
        @filesystem.directory? path
      end

      def __resolve_debug_IO_which_is_for_now_required
        _ = @_listener.call :resource, :line_downstream_for_help  # eek/meh
        _store :@_debug_IO, _
      end

      def _store ivar, x
        if x ; instance_variable_set ivar, x ; ACHIEVED_ ; else x end
      end

      # --

      def _info & msg_p
        if 1 == msg_p.arity
          @_listener.call :info, :expression, & msg_p
        else
          @_listener.call :info, :expression do |y|
            y << calculate( & msg_p )
          end
        end
        NIL
      end

      # ==

      class CachingFilter___

        def initialize lemmatics, explicits, coverage_root_path, debug_IO, & p

          if lemmatics.length.zero?
            # if you have no lemmatics it is IFF there was no longest common
            # base path of your test files. this means cover every file that
            # is loaded that is under your #here2 `root`. it is then a waste
            # to check explicits. this was expressed already.

            @_decide_contained_path = :__pass_all_paths

          elsif explicits.length.zero?

            # you have only lemmatics

            _receive_lemmatics lemmatics
            @_decide_contained_path = :__decide_using_lemmatics_only

          else
            # you have both. we'll check the one before the other because
            # the one (a hash lookup of a path) is faster than the other.

            _receive_lemmatics lemmatics
            _receive_explicits explicits
            @_decide_contained_path = :__decide_using_both
          end

          @_cache = {}
          @__head_string = ::File.join coverage_root_path, EMPTY_S_
          @__range = @__head_string.length .. -1

          @_debug_IO = debug_IO
          @lemmatics = lemmatics
          @_listener = p
        end

        def _receive_lemmatics a
          @__lemmatics_length = a.length
          @_lemmatics = a ; nil
        end

        def _receive_explicits x
          @__explicits = x ; nil
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
            send @_decide_contained_path, path
          else
            # @_listener.call :error, :expression, :sanity do |y|
            @_debug_IO.puts "STRANGE: #{ path }"
            # end
            FILTER_IT_OUT_
          end
        end

        def __decide_using_both path
          tail = _localize_path path
          if _match_against_explicits tail
            _filter_it_in
          elsif _match_against_lemmatics tail
            _filter_it_in
          else
            _filter_it_out
          end
        end

        def __decide_using_lemmatics_only path
          _tail = _localize_path path
          _yes = _match_against_lemmatics _tail
          _yes ? _filter_it_in : _filter_it_out
        end

        def __decide_using_explicits_only path
          _tail = _localize_path path
          _yes = _match_against_explicits _tail
          _yes ? _filter_it_in : _filter_it_out
        end

        def _localize_path path
          path[ @__range ]
        end

        def __pass_all_paths _path
          THIS_ONE_STAYS_
        end

        def _match_against_lemmatics tail

          @_ENTRIES = tail.split ::File::SEPARATOR
          if @_ENTRIES.length < @__lemmatics_length
            DOES_NOT_MATCH_
          else
            __work_via_entries
          end
        end

        def __work_via_entries

          target_scn = Common_::Scanner.via_array @lemmatics
          actual_st = __actual_lemmatic_stream_via_entries

          begin

            actual_lemmatic = actual_st.gets

            if ! actual_lemmatic
              # any time you run out of actuals here, no match
              does_or_does_not_match = DOES_NOT_MATCH_
              break
            end

            target_lemmatic = target_scn.gets_one

            if target_lemmatic != actual_lemmatic
              does_or_does_not_match = DOES_NOT_MATCH_
              break
            end

            if target_scn.no_unparsed_exists
              # (if you reach the end of the target chain, it's a match)
              does_or_does_not_match = DOES_MATCH_
              break
            end

            redo
          end while above

          does_or_does_not_match
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

        def _match_against_explicits tail
          @__explicits[ tail ]
        end

        def _filter_it_out
          @_debug_IO.puts "filtered out: #{ _pretty_entries }"
          FILTER_IT_OUT_
        end

        def _filter_it_in
          @_debug_IO.puts "filtered in:  #{ _pretty_entries }"
          THIS_ONE_STAYS_
        end

        def _pretty_entries
          ::File.join( * @_ENTRIES )
        end

        # --

        DOES_MATCH_ = true
        DOES_NOT_MATCH_ = false
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

          @_seen_more_than_zero = false
          @_seen_more_than_one = false

          keep_going = KEEP_GOING_
          st = remove_instance_variable :@__stream

          begin
            path = st.call
            path || break
            keep_going = send @_see_path, path
            keep_going || break
            redo
          end while above

          if @_seen_more_than_zero && keep_going
            __finish
          end
        end

        def __see_first_path path
          @_first_path = path
          @_longest_common_elements = path.elements.dup
          @_longest_common_elements_length = @_longest_common_elements.length
          @_is_absolute = path.is_absolute
          @_see_path = :__see_second_path
          @_seen_more_than_zero = true
          KEEP_GOING_
        end

        def __see_second_path path
          @_seen_more_than_one = true
          @_see_path = :__see_third_or_later_path
          send @_see_path, path
        end

        def __see_third_or_later_path path
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

          if @_seen_more_than_one
            _thing_via_elements _release_longest_common_elements
          else
            __when_seen_exactly_one
          end
        end

        def __when_seen_exactly_one

          # consider the characteristics of a list of multiple paths:
          #
          # for one, assume that every path in the list is a unique path in
          # that list, making the list also a set. (we'll leave as undefined
          # what happens if the list has duplicates.)
          #
          # for two, assume that every path in the set is only ever of a
          # file, and not of a directory. this means that no path in the set
          # is ever a "base path" of any other path in the set.
          #
          # now we can't prove it, but we hope it holds as empirically
          # evident that for such sets, the longest common base path will
          # never be equal to one of the paths (i.e it will always be
          # unequal to each of the paths).
          #
          # and conversely (and more obviously), whenever your set is of
          # size one, the longest common base path *is* *always* equal to
          # that selfsame path.

          # now a corollary of the above two axioms: the only way we end up
          # with a "basename" from a test file *in* the longest common base
          # path is when our list is size one (assuming name conventions).
          # furthermore our LCBP *always* has this characteristic in these
          # cases.

          _basename_tail = Home_.spec_rb

          _rx = /\A
            (?<stemmish>
              (?:\d+-)?
              [a-z].*
            )
            #{ ::Regexp.escape _basename_tail }
          #\z/x
          # (we could do the removal of the any leading digits here,
          #  but it should happen #here1)

          s_a = _release_longest_common_elements
          md = _rx.match s_a.last
          md || self._COVER_ME__xx__

          s_a[ -1 ] = md[ :stemmish ]  # ick mutate original

          _thing_via_elements s_a.freeze
        end

        def _thing_via_elements s_a
          remove_instance_variable( :@_first_path ).new_via_elements s_a
        end

        def _release_longest_common_elements
          remove_instance_variable :@_longest_common_elements
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
# #tombstone-C.1: (can be temporary) add a feature that we don't cover
# #tombstone-B: full rewrite from standalone executable to become quickie plugin
# :+#tombstone: rspec integration (ancient)
