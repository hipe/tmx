# -
  class Skylab_CodeMetrics_Operations_Mondrian_EarlyInterpreter

    # the least hacky way we can accomplish what we're after (as far as
    # we've found) is to use `TracePoint` ("[the] facility") which can
    # notify us when certain events of interest occur like when a module
    # (e.g class) is opened, or when the same module's scope again closes
    # (with an `end` keyword).
    #
    # (#open [#007.G] EDIT the above calculus has changed now with [bs])
    #
    # (this facility is usable to us because it tells us line numbers
    # (otherwise we'd have to go much darker); however we can't get
    # notified of the blocks used when defining procs yet. we might hack
    # something awful for that.)
    #
    # the caveat to using the facility for this objective is that the
    # facility communicates events of interest *while* the files of interest
    # are loaded (parsed), so you cannot (straightforwardly) apply this
    # technique to files that have already been loaded into your runtime
    # before you begin "recording".
    #
    # (a workaround might be to load the files of interest twice, but we
    # anticipate this as carrying significant hidden future costs, as we
    # can imagine some files that are difficult or impossible to load twice.
    # also what we attempt here accords more cleanly with our next wish,
    # which is file globs.)
    #
    # so the above described dynamic becomes *the* central mechanic of
    # the whole implementation of this visualization. it is a familiar
    # bootstrapping challenge, similar to trying to produce code coverage
    # over files that are involved in processing the request for coverage.
    #
    # since there are no code nodes we have ever written that we cannot
    # imagine wanting this visualization for, we cut the gordian knot
    # with this grand workaround:
    #
    # this selfsame code node ("the subject") (and the one code node that
    # loads it) will be the only nodes in our universe that we cannot
    # (easily) generate this visualiztion for. in exchange, this file's
    # scope of responsibility is pretty huge:
    #
    #   1. parse the request (e.g ARGV)
    #
    #   2. set up the listeners and begins listening
    #
    #   3. load the files(s) of interest while:
    #
    #   4. represent the relevant "recording" of same in some way that
    #      can be "played back" to the rest of the implementation.
    #
    # EDIT: the lightweight "framework" we made for the above ended
    # up becoming [#ze-060] the "no dependencies zerk" file

    # local abbreviations:
    #   `ff` - feature found

    # -

      def initialize argv, sin, sout, serr, pn_s_a
        @ARGV = argv ; @stdin = sin ; @stdout = sout ; @stderr = serr
        @program_name_string_array = pn_s_a
      end

      def execute
        @exitstatus = 0
        ok = __parse_arguments
        ok &&= __resolve_line_stream_via_operation
        if ok
          st = remove_instance_variable :@_line_stream
          while line=st.gets
            @stdout.puts line
          end
        end
        @exitstatus
      end

      def __resolve_line_stream_via_operation

        if @_operation.do_list_etc
          _ = _operation.execute
          _store :@_line_stream, _
        else
          _ok = _store :@__node_plus, _operation.execute
          _ok && __resolve_line_stream_via_node_plus
        end
      end

      def __resolve_line_stream_via_node_plus
        require 'skylab/code_metrics/cli/line-stream-via-node-plus'
          # the above while open [#010] brazen

        _ = ::Skylab::CodeMetrics::CLI__LineStream_via_NodePlus.call_by do |o|
          o.node_plus = remove_instance_variable :@__node_plus
          o.width_and_height @width, @height
        end
        _store :@_line_stream, _
      end

      def __parse_arguments

        @height = HEIGHT
        @width = WIDTH

        remove_instance_variable :@stdin  # assert never used
        argv = remove_instance_variable :@ARGV
        'm' == argv[0][0] || fail  # ..

        listener = method :__receive_emission

        nar = Interface__::CLI_ArgumentScanner.narrator_for argv, & listener

        nar.token_scanner.advance_one  # (as confirmed above (ish), we already
        # parsed thef first token of the ARGV (our own name), so skip it.

        # frontier an experimental pattern - aggregate
        # primary sets of different stakeholders here

        op = Operation__.new nar, @stderr
        @argument_scanner_narrator = nar

        @_operation = op

        _o = Interface__::ArgumentParsingIdioms_via_FeaturesInjections.define do |o|

          o.add_primaries_injection Operation__::PRIMARIES, :__inj1_cm
          o.add_injector op, :__inj1_cm

          o.add_primaries_injection CLI_PRIMARIES___, :__inj2_cm
          o.add_injector self, :__inj2_cm

          o.default_primary_symbol = :path
          o.argument_scanner_narrator = nar
        end

        _ok = _o.flush_to_parse_primaries
        _ok  # #todo
      end

      def _operation
        remove_instance_variable :@_operation
      end

      def __receive_signal p, chan
        _ok = send :"__receive__#{ chan.fetch 1 }__signal", * chan[ 2..-1 ], & p
        _ok  # #todo
      end

      # -- process primaries

      def __when_help _ff

        Code_metrics_[]

        # -- begin ridiculous loading only while #open [#010]
        const = :CLI__ExpressMondrianHelp_via_
        if ! Here_.const_defined? const, false
          # (if this check is ever necessary, it is only because testing)
          Home_.ridiculous_ = true
          require 'skylab/code_metrics/cli/core'
          Home_.const_defined? const, false or self._FIXME__load_not_require_but_how__
        end
        _lib = Home_.const_get const, false
        # -- end

        _lib.call_by do |o|
          o.expression_agent = _expression_agent
          o.program_name_string_array = @program_name_string_array
          o.stderr = @stderr
        end
        EARLY_END_  # always stop
      end

      def _parse_positive_nonzero_integer ff

        vm = @argument_scanner_narrator.procure_positive_nonzero_integer_after_feature_match ff.feature_match
        if vm
          _my_store vm
        end
      end

      def __receive_emission * chan, & msg_p

        refl = Interface__::CLI_Express_via_Emission.call_by do |o|
          o.emission_proc_and_channel msg_p, chan
          o.expression_agent_by = method :_expression_agent
          o.signal_by = method :__receive_signal
          o.stderr = @stderr
        end

        if refl.was_error
          if @exitstatus.zero?
            @exitstatus = 3092
              # (how many hundreths of a second the first topic testrun took)
          end
        end

        NIL
      end

      def _expression_agent
        Interface__::CLI_InterfaceExpressionAgent.instance
      end

      def _my_store vm
        @argument_scanner_narrator.advance_past_match vm
        instance_variable_set vm.feature_match.TO_IVAR, vm.mixed
        ACHIEVED_
      end

      DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
        if x
          instance_variable_set ivar, x ; true
        else
          x
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      attr_reader(
        :stderr,
      )
    # -

    # ==

    CLI_PRIMARIES___ = {
      help: :__when_help,
      height: :_parse_positive_nonzero_integer,
      width: :_parse_positive_nonzero_integer,
    }

    HEIGHT = 20
    WIDTH = 52

    # ==

    require 'no-dependencies-zerk'
    lib = ::NoDependenciesZerk
    Interface__ = lib  # #testpoint

    SimpleModel_ = lib::SimpleModel

    # ==

      # the only weird thing about this is the dependency of
      # system services ("topic") on request parsing:
      #
      #   - to normalize filesystem paths we need topic
      #   - we try to keep things immutable generally so
      #   - to build topic we need to know if debugging is on
      #
      # as such, we can't allow that debugging mode gets turned on
      # after topic has been built because the topic would then
      # "miss" this configuration. possible "fixes":
      #
      #   - if topic is already built when debugging gets turned on,
      #     just build a new one over it (A)
      #
      #   - change topic to be mutable (B)
      #
      #   - topic could emit emissions instead of writing to IO
      #     (but how does the expresser know when debugging is on?
      #     not until all primaries are parsed, right?)
      #
      #   - don't use topic to normalize paths as they are encountered
      #     during input parsing; rather break out a second pass
      #
      #   - manage state so that we whine and exit if debugging mode is
      #     turned on after topic is built.
      #
      # for now we're going with the final option so the user begins to
      # think about whether they would want debugging on or off for each
      # particular primary expression. this way we have an upgrade path
      # to (A) or (B) without an abrubt change in behavior.
      #

    # ==

    class Operation__  # #testpoint

      def initialize scn, debug_IO

        @_debug_IO = debug_IO
        @_is_mock_run = false
        @_listener = scn.listener
        @argument_scanner_narrator = scn

        @_system_services = :__system_services_initially
        @_system_services_is_built = false

        @be_verbose = nil
        @do_list_etc = nil
        @head_const = nil
        @head_path = nil
        @paths = nil
        @require_paths = nil
      end

      PRIMARIES = {
        head_const: :__parse_item,
        head_path: :_parse_path_item,
        list_nodes_to_load: :__when_list_etc,
        path: :_parse_path_list_item,
        ping: :__when_ping,
        require_path: :__parse_list_item,
        verbose: :__when_verbose,
      }

      def execute  # assume normal
        ok = __normalize
        ok &&= __resolve_request
        if ok
          if @_is_mock_run
            return NodePlus___.new :_stub_of_node_for_treemap_, @_request
          end
        end
        ok && __via_request
      end

      def __via_request
        if @do_list_etc
          ok = _resolve_load_adapter
          ok and _store :@__normal_paths, _load_adapter.to_normal_paths
          ok && __flush_file_list
        else
          __the_rest_normally
        end
      end

      def __flush_file_list
        o = remove_instance_variable :@__normal_paths
        head = o.head_path
        o.to_normal_path_stream_by.call.map_by do |s_a|
          ::File.join head, * s_a
        end
      end

      def __the_rest_normally
        ok = true
        ok &&= __resolve_recording
        ok &&= __resolve_node_for_treemap_via_recording
        ok && __flush_node_plus
      end

      def __normalize
        these = %i( @paths )
          these.push :@head_const
        Interface__::Check_requireds.call self, these, & @_listener
      end

      def __flush_node_plus
        _ = remove_instance_variable :@__node_for_treemap
        NodePlus___.new _, @_request
      end

      NodePlus___ = ::Struct.new :node, :request

      def __resolve_node_for_treemap_via_recording  # #testpoint (see #mon-spot-2)
        _rec = remove_instance_variable :@__recording
        _ = @_mags::Node_for_Treemap_via_Recording.call(
          _rec, @_request, & @_listener )
        _store :@__node_for_treemap, _
      end

      def __resolve_recording  # #testpoint (see #mon-spot-2 again)
        recorder = Recorder___.new @_request, @_listener
        recorder.enable
        ok = _resolve_load_adapter
        ok &&= _load_adapter.load_all_assets_and_support
        recorder.disable
        ok and _store :@__recording, recorder.flush_recording
      end

      def _resolve_load_adapter  # only after we are recording (as applicable)
        @_mags = Code_metrics_[]::Magnetics_
        _ = @_mags::LoadAdapter_via_Request[ @_request, & @_listener ]
        _store :@__load_adapter, _
      end

      def _load_adapter
        remove_instance_variable :@__load_adapter
      end

      def __resolve_request

        _sy_svcs = send @_system_services

        _ = Request___.define do |o|
          o.be_verbose = remove_instance_variable :@be_verbose
          o.do_paginate = false  # on day soon-ish..
          o.debug_IO = @_debug_IO
          o.head_const = remove_instance_variable :@head_const
          o.head_path = remove_instance_variable :@head_path
          o.paths = remove_instance_variable :@paths
          o.require_paths = remove_instance_variable :@require_paths
          o.system_services = _sy_svcs
        end

        _store :@_request, _
      end

      # -- processing primaries

      def __when_ping _ff
        @_listener.call :info, :expression, :ping do |y|
          y << "hello from mondrian"
        end
        EARLY_END_
      end

      def __when_verbose ff
        if @_system_services_is_built
          __whine_about_verbose ff
        else
          @argument_scanner_narrator.advance_past_match ff.feature_match
          if @be_verbose
            _info_about_verb_levels
          else
            @be_verbose = true
          end
          ACHIEVED_
        end
      end

      def __whine_about_verbose ff
        @argument_scanner_narrator.no_because_by do |o|
          o.message_proc = -> y do
            y << "for now, can't turn on {{ feature }} after paths are processed."
          y << "try putting the flag earlier in the request."
          end
          o.feature_match = ff.feature_match
        end
      end

      def __info_about_verb_levels
        @_listener.call :info, :expression do |y|
          y << "(for now there is only one level of versosity.)"
        end
      end

      def _parse_path_list_item ff

        vm = @argument_scanner_narrator.procure_trueish_match_after_feature_match ff.feature_match
        if vm
          s = vm.mixed
          if MOCK_PATH_ONE___ == s
            @_is_mock_run = true
            _accept_list_item :_mock_path_1_, vm
          else
            path = send( @_system_services ).normalize_user_path s
            if path
              _accept_list_item path, vm
            end
          end
        end
      end

      MOCK_PATH_ONE___ = 'mock-path-1.code'  # #[#007.H]

      def __system_services_initially
        ss = SystemServices___.new @be_verbose, @_debug_IO
        @_system_services_is_built = true
        @_system_services = :__system_services_subsequently
        @___system_services = ss
        ss
      end

      def __system_services_subsequently
        @___system_services
      end

      # ~ candidates to push up to [ze] somehow

      def __parse_list_item ff

        #  - curate that the argument scanner is non-empty
        #  - if not initialized, create a mutable array in the ivar
        #  - acccept the head argument into the array (even if the
        #    head argument is a blank string (e.g the empty string)).

        vm = _procure_any_match ff
        if vm
          _accept_list_item vm.mixed, vm
        end
      end

      def __parse_item ff

        #  - curate that the argument scanner is non-empty
        #  - curate there is not already a non-nil value in the ivar "slot"
        #  - acccept the head argument into the slot (even if the
        #    head argument is a blank string (e.g the empty string)).

        vm = _procure_any_match ff
        if vm
          ivar = vm.feature_match.TO_IVAR
          if instance_variable_defined? ivar
            x = instance_variable_get ivar
          end
          if x.nil?
            @argument_scanner_narrator.advance_past_match vm
            instance_variable_set ivar, vm.mixed
            ACHIEVED_
          else
            __when_value_is_already_set vm
          end
        end
      end

      def __when_value_is_already_set vm

        @argument_scanner_narrator.no_because_by do |o|

          o.message_proc = -> do
            "ambiguous: {{ feature }} specified multiple times but only #{
              }takes one value"
          end

          o.value_match = vm  # (could be etc instead)
        end
      end

      def _accept_list_item x, vm  # track #[#ze-023.3] native..
        # implementations of list/globs. note that we pluralize the name here
        @argument_scanner_narrator.advance_past_match vm
        ivar = :"#{ vm.feature_match.TO_IVAR }s"
        if instance_variable_defined? ivar
          a = instance_variable_get ivar
        end
        if ! a
          instance_variable_set ivar, ( a=[] )
        end
        a.push x
        ACHIEVED_
      end

      def __when_list_etc ff
        @argument_scanner_narrator.advance_past_match ff.feature_match
        @do_list_etc = true
        ACHIEVED_
      end

      def _procure_any_match ff
        @argument_scanner_narrator.procure_any_match_after_feature_match ff.feature_match
      end

      attr_reader(
        :do_list_etc,
      )

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class SystemServices___  # #testpoint

      def initialize do_debug, debug_IO
        @_path_normalizer = PathNormalizer.new do_debug, debug_IO
      end

      def normalize_user_path path

        # in real life, if this path is coming from a user on a terminal
        # it probaly does *not* employ symlinks; however if the path was
        # derived programmatically for a test then it probably does.

        @_path_normalizer.__normalize_path_softly_ ::File.expand_path path
      end

      def normalize_system_path path
        @_path_normalizer.normalize_absolute_path path
      end

      def glob path
        ::Dir.glob path
      end

      def open_file_read_only path
        ::File.open path, ::File::RDONLY
      end
    end

    # ==

    class Recorder___

      # do as little as possible while your tracepoint listening is enabled:
      # it's really easy to get hopelessly twisted into yourself if your
      # event handling routines cause more events to be triggered.
      #
      # load the target files (and whatever files they load, and whatever
      # files are loaded in suppport of this effort) while ignoring all the
      # events triggered for files outside the files of interest.
      #
      # for those events originating from inside one of your files of
      # interest, note the event type, path, line number and particpating
      # module (thru `tracepoint.binding.receiver`).) we call these four
      # points an "event tuple" and represent them as simple lines:
      #
      #     "  123  class Wing::Ding::Fing  /my/code/wing/ding/fing.rb\n"
      #
      #      lineno event fully-qualified-const absolute-path newline
      #
      # these lines are then written to an array for subsequent "playback"
      # after we end the "recording session", at which point we can be
      # reckless again.
      #
      # also this format avails itself well to testing.

      def initialize req, l

        be_verbose = req.be_verbose
        debug_IO = req.debug_IO

        @_path_matcher = CachingPathMatcher___.define do |o|
          o.do_debug = be_verbose
          o.debug_IO = debug_IO
          o.paths = req.paths
          o.system_services = req.system_services
        end

        @_tracepoint = TracePoint.new :class, :end do
          @_path = @_tracepoint.path
          send ON_CLASS_OR_END___.fetch @_tracepoint.event
        end

        @_recording = LeftShiftBasedRecording___.new [], be_verbose, debug_IO
      end

      ON_CLASS_OR_END___ = {
        class: :__on_class,
        end: :__on_end,
      }

      def enable
        _old_val = @_tracepoint.enable
        _old_val && self._SANITY__was_already_enabled__
        # (the recording stays as-is)
        NIL
      end

      def disable
        _old_val = @_tracepoint.disable
        _old_val || self._SANITY__was_already_disabled__
        # (the recording stays as-is)
        NIL
      end

      def __on_class
        path = @_path_matcher.normalize_and_match @_path
        if path
          @_recording.receive_class_event path, @_tracepoint
        end
        NIL
      end

      def __on_end
        path = @_path_matcher.normalize_and_match @_path
        if path
          @_recording.receive_end_event path, @_tracepoint
        end
        NIL
      end

      def flush_recording
        _rec = remove_instance_variable :@_recording
        remove_instance_variable :@_path_matcher
        remove_instance_variable :@_tracepoint
        _rec.finish
      end
    end

    # ==

    class LeftShiftBasedRecording___

      # during record time the "recording medium" is written to using only
      # the "left shift" (`<<`) medium, which receives tuples-as-strings.

      # then hackily but aptly, only at the end as a sort of lazily-
      # evaluated factory pattern, we determine if this recording is:
      #
      #   - memory-based (array)
      #   - IO-based (IO of open filehandle (file on filesystem))
      #   - could be $stdout or $stderr too (code sketch)
      #
      # and produce an appropriate (frozen) "recording" object (or not)
      # based solely on the shape of the medium argument #here-2

      def initialize medium, do_debug, debug_IO

        if do_debug
          @_via_line = :__via_line_expressively
          @__debug_IO = debug_IO
        else
          @_via_line = :_via_line_normally
        end

        @__event_format = EVENT_FORMAT___
        @__lineno_format = LINENO_FORMAT___

        @_medium = medium
      end

      def receive_class_event path, tp
        _receive_event :class, path, tp
      end

      def receive_end_event path, tp
        _receive_event :end, path, tp
      end

      def _receive_event ev_sym, path, tp

        send @_via_line, "#{
          }#{ @__lineno_format % tp.lineno }#{ SPACE_
          }#{ @__event_format % ev_sym }#{ SPACE_
          }#{ tp.binding.receiver.name || SING_PROB___ }#{ SPACE_
          }#{ path }\n"
        NIL
      end

      def __via_line_expressively line
        @__debug_IO.write "YAY: #{ line }"
        _via_line_normally line
      end

      def _via_line_normally line
        @_medium << line ; nil
      end

      eek_h = {
        class: "class",
        end:   "  end",
      }
      class << eek_h
        alias_method :%, :fetch
      end  # >>
      EVENT_FORMAT___ = eek_h

      LINENO_FORMAT___ = '%4d'

      # --

      def finish  # :#here-2
        _CM = Code_metrics_[]
        x = remove_instance_variable :@_medium
        if x.respond_to? :tty?
          if x.tty?
            # (don't close stdout/stderr. you can but you don't want to.)
            NOTHING_
          else
            x.close
            _CM::Models_::Recording::ByFile.new x.path
          end
        else
          _CM::Models_::Recording::ByArray.new x.freeze
        end
      end
    end

    # ==

    class Request___ < SimpleModel_  # #testpoint

      attr_accessor(
        :be_verbose,
        :do_paginate,
        :debug_IO,
        :head_const,
        :head_path,
        :paths,
        :require_paths,
        :system_services,
      )
    end

    # ==

    class CachingPathMatcher___ < SimpleModel_

      # never does work for the same path twice

      def initialize

        yield self

        _do_debug = remove_instance_variable :@do_debug

        if _do_debug
          @_normalize_and_match = :__normalize_and_match_expressively
        else
          remove_instance_variable :@debug_IO
          @_normalize_and_match = :_normalize_and_match_normally
        end

        @_path_cache = {}
      end

      attr_writer(
        :do_debug,
        :debug_IO,
        :paths,
        :system_services,
      )

      def normalize_and_match path
        @_path_cache.fetch path do
          x = send @_normalize_and_match, path
          @_path_cache[ path ] = x
          x
        end
      end

      def __normalize_and_match_expressively path
        yes = _normalize_and_match_normally path
        if yes
          @debug_IO.puts "MATCHED: #{ path }"
        else
          @debug_IO.puts "skip: #{ path }"
        end
        yes
      end

      def _normalize_and_match_normally path

        did_match = false

        real_path = @system_services.normalize_system_path path

        @paths.each do |formal_path|

          if ::File.fnmatch formal_path, real_path
            did_match = true
            break
          end
        end

        did_match && real_path
      end
    end

    # ==

    class PathNormalizer  # :[#017]

      # dereference all symbolic link nodes in an absolute path recursively.

      # (without this, paths passed in as arguments from the terminal don't
      # correspond to paths associated with asset nodes in our gems, and so
      # all events are filtered out during recording.)

      # ([#tm-013.1] explains more fully but solves more hackily (inline comment))

      def initialize do_debug, debug_IO

        if do_debug
          @_normalize_path = :__normalize_path_expressively
          @_debug_IO = debug_IO
        else
          @_normalize_path = :_normalize_path
        end

        @_prototype = LookupPath___.new self, debug_IO
        @_referenced_real_directories_ = {}
        @_symlink_offset_via_path_ = {}
        @_symlink_node_via_offset_ = []
        @_tree_cache_ = {}
      end

      def __normalize_path_softly_ path
        send @_normalize_path, Request__[ path, true ]
      end

      def normalize_absolute_path path  # [tmx]
        send @_normalize_path, Request__[ path ]
      end

      def __normalize_path_expressively req
        path = req.original_path
        path_ = _normalize_path req
        if path_ == path
          @_debug_IO.puts "same: #{ path_ }"
        else
          @_debug_IO.puts "normalized #{ path_ } from #{ path }"
        end
        path_
      end

      def _normalize_path req
        lu = @_prototype.lookup_via_request req
        # ..
        lu and lu.real_path
      end

      def __lookup_path_ path
        @_prototype.lookup_via_request Request__[ path ]
      end

      attr_reader(
        :_tree_cache_,
        :_referenced_real_directories_,
        :_symlink_node_via_offset_,
        :_symlink_offset_via_path_,
      )

      Request__ = ::Struct.new :original_path, :is_softly
    end

    # ==

    class LookupPath___

      # (private to its only client)

      def initialize mother, debug_IO
        @_debug_IO = debug_IO
        @_path_normalizer = mother
        freeze
      end

      private :dup

      def lookup_via_request req
        dup.__init( req ).execute
      end

      def __init req
        @path = req.original_path
        @is_softly = req.is_softly  # NOTE - not implemented
        self
      end

      def execute
        scn = PathScanner.via @path
        if scn.is_absolute
          if scn.no_unparsed_exists
            __when_root
          else
            @_scn = scn
            __work
          end
        else
          __when_not_absolute
        end
      end

      def __work  # assume at least one

        @_normal_path_buffer = ""
        @_current_tree = @_path_normalizer._tree_cache_

        begin
          @_current_path = nil
          @_current_part = @_scn.gets_one

          if FNMATCH_PATTERN_PROBABLY_RX =~ @_current_part
            __flush_the_rest  # see
            break
          end

          node = __gets_node_via_current_part
          @_current_node = node
          if node.is_real_directory
            __update_path_and_tree_via_real_directory
          elsif node.is_file
            __update_path_and_tree_via_file
          else
            __update_path_and_tree_via_symlink
          end
        end until @_scn.no_unparsed_exists

        _final = remove_instance_variable( :@_normal_path_buffer ).freeze
        Lookup___.new _final, node
      end

      Lookup___ = ::Struct.new :real_path, :node

      def __flush_the_rest

        # the general premise for this path-normalizing utility is that
        # for the argument path and every parent directory of it, we ask
        # the filesystem (efficiently) if that path is a symlink.
        #
        # as such, this facility assumes that the argument path is a
        # plain-old path (containing symlinks or not) that points to an
        # existent resource.
        #
        # if any of these paths were to contain wildcard/glob elements
        # (near #mon-spot-3), this would (as it should) cause a no-ent
        # to be thrown under `lstat`;
        #
        # yet we (now) want this facility to be robust enough to accomodate
        # a path that contains these meta-characters. for such paths we
        # want to normalize the head of the path up to the part that contains
        # the meta-characters.

        _add_part remove_instance_variable :@_current_part

        until @_scn.no_unparsed_exists
          _add_part @_scn.gets_one
        end
        NIL
      end

      def __update_path_and_tree_via_real_directory
        _update_normal_path_buffer
        @_current_tree = @_current_node.tree ; nil
      end

      def __update_path_and_tree_via_symlink
        real_path = @_current_node.final_target_path
        @_normal_path_buffer = real_path.dup
        _real_node = @_path_normalizer._referenced_real_directories_.
          fetch( real_path )
        @_current_tree = _real_node.tree ; nil
      end

      def __update_path_and_tree_via_file
        _update_normal_path_buffer
        NIL
      end

      def _update_normal_path_buffer
        path = remove_instance_variable :@_current_path
        if path
          @_normal_path_buffer = path
        else
          _add_part remove_instance_variable :@_current_part
        end
        NIL
      end

      def _add_part part
        @_normal_path_buffer << ::File::SEPARATOR
        @_normal_path_buffer << part
        NIL
      end

      def __gets_node_via_current_part
        node = @_current_tree[ @_current_part ]
        node ||= __lookup_and_cache_node
        remove_instance_variable :@_current_tree
        node
      end

      def __lookup_and_cache_node
        path = @_normal_path_buffer.dup
        path << ::File::SEPARATOR
        path << @_current_part
        @_current_path = path
        node = __build_node
        @_current_tree[ @_current_part ] = node
        node
      end

      def __build_node
        stat = ::File.lstat @_current_path
        if stat.symlink?
          __produce_symlink_node
        elsif stat.directory?
          __build_real_directory_node
        else
          __produce_file_node
        end
      end

      def __produce_symlink_node
        path = remove_instance_variable :@_current_path
        d = @_path_normalizer._symlink_offset_via_path_[ path ]
        if d
          @_path_normalizer._symlink_node_via_offset_.fetch d
        else
          __recurse path
        end
      end

      def __recurse new_sym_path

        cache = @_path_normalizer
        a = cache._symlink_node_via_offset_
        h = cache._symlink_offset_via_path_
        h_ = cache._referenced_real_directories_
        cache = nil

        h[ new_sym_path ] = :_LOCKED_
        _mid_target_path = ::File.readlink new_sym_path
        lu = @_path_normalizer.__lookup_path_ _mid_target_path
        real_path = lu.real_path
        h_[ real_path ] ||= lu.node
        node = Symlink___.new real_path
        d = a.length
        a[ d ] = node
        h[ new_sym_path ] = d
        a.fetch d
      end

      def __build_real_directory_node
        RealDirectory___.new
      end

      def __produce_file_node
        FILE___
      end

      def __when_root
        @_debug_IO.puts "STRANGE2: argument path is root - #{ @path }"
        NOTHING_
      end

      def __when_not_absolute
        @_debug_IO.puts "STRANGE1: not absolute - #{ @path }"
        NOTHING_
      end
    end

    class Symlink___
      def initialize path
        @final_target_path = path
      end
      attr_reader(
        :final_target_path,
      )
      def is_real_directory
        false
      end
      def is_file
        false
      end
    end

    class RealDirectory___
      def initialize
        @tree = {}
      end
      attr_reader(
        :tree,
      )
      def is_real_directory
        true
      end
    end

    module FILE___ ; class << self
      def is_real_directory
        false
      end
      def is_file
        true
      end
    end ; end

    # ==

    class PathScanner

      # process each part of a path with a familiar interface

      # (compare the more general [#ta-010] "token stream")

      class << self
        def via path
          require 'strscan'
          scn = ::StringScanner.new path
          if scn.skip SEP__
            NOTHING_ while scn.skip SEP__
            new true, scn
          else
            new false, scn
          end
        end
        private :new
      end  # >>

      def initialize yes, scn
        @is_absolute = yes

        if scn.eos?
          @no_unparsed_exists = true
          freeze
        else
          @_scn = scn
          @_open = true
          _reinit_current_token
        end
      end

      def gets_one
        x = remove_instance_variable :@head_as_is
        if @_open
          _reinit_current_token
        else
          remove_instance_variable :@_open
          @no_unparsed_exists = true
          @ended_with_separator = remove_instance_variable :@_will_have_ended_with_sep
          freeze
        end
        x
      end

      def _reinit_current_token
        s = @_scn.scan PART__
        if ! s
          self._REGEX_SANITY
        end
        @head_as_is = s
        if @_scn.eos?
          _pre_close false
        elsif @_scn.skip SEP__
          if @_scn.skip SEP__
            # ..
            NOTHING_ while @_scn.skip SEP__
          end
          if @_scn.eos?
            _pre_close true
          end
        else
          self._REGEX_SANITY
        end
        NIL
      end

      def _pre_close yes
        @_will_have_ended_with_sep = yes
        remove_instance_variable :@_scn
        @_open = false ; nil
      end

      esc = ::Regexp.escape ::File::SEPARATOR
      PART__ = /(?:(?!#{ esc }).)+/m
      SEP__ = /#{ esc }/

      attr_reader(
        :head_as_is,
        :ended_with_separator,
        :is_absolute,
        :no_unparsed_exists,
      )
    end

    # ==

    Code_metrics_ = lib::Lazy.call do
      # don't load normal-space until recording is enabled, otherwise you
      # won't be able to generate viz for any nodes loaded. see top of file.
      require 'skylab/code_metrics'
      x = ::Skylab::CodeMetrics
      Here_.const_set :Home_, x
      x
    end

    # ==

    ACHIEVED_ = true
    EARLY_END_ = nil
    FNMATCH_PATTERN_PROBABLY_RX = /[\\*?\[]/  # long comment at #mon-spot-3
    Here_ = self
    NIL = nil  # open [#sli-016.C]
    NOTHING_ = nil
    SING_PROB___ = "«singleton probably»"
    SPACE_ = ' '

    # ==
  end
# -
# #born
