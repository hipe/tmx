require 'strscan'  # for ::StringScanner below

# -
  class Skylab_CodeMetrics_Operations_Mondrian_EarlyInterpreter

    # the least hacky way we can accomplish what we're after (as far as
    # we've found) is to use `TracePoint` ("[the] facility") which can
    # notify us when certain events of interest occur like when a module
    # (e.g class) is opened, or when the same module's scope again closes
    # (with an `end` keyword).
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

    # -

      def initialize argv, sin, sout, serr, pn_s_a
        @ARGV = argv ; @stdin = sin ; @stdout = sout ; @stderr = serr
        @program_name_string_array = pn_s_a
      end

      def execute

        remove_instance_variable :@stdin  # assert never used
        argv = remove_instance_variable :@ARGV
        'm' == argv[0][0] || fail  # ..

        listener = method :__receive_emission

        _scn = ArgumentScanner_for_CLI___.define do |o|
          o.default_primary_symbol = :path
          o.initial_ARGV_offset = 1
          o.ARGV = argv
          o.stderr = @stderr
          o.listener = listener
        end

        @exitstatus = 0

        o = Operation__.new( _scn ).execute
        if o
          st = o.release_line_stream
          while line = st.gets
            @stdout.puts line
          end
        end
        @exitstatus
      end

      def __receive_emission * chan, & msg_p

        refl = Express_for_CLI_via_Expression___.define do |o|
          o.channel = chan
          o.emission_proc = msg_p
          o.stdout = @stdout
          o.stderr = @stderr
        end.execute

        if refl.was_error
          if @exitstatus.zero?
            @exitstatus = 3092
              # (how many hundreths of a second the first topic testrun took)
          end
        end

        NIL
      end

      DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
        if x
          instance_variable_set ivar, x ; true
        else
          UNABLE_
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      attr_reader(
        :stderr,
      )
    # -

    # ==

    class SimpleModel_  # (necessarily repeated)

      class << self
        alias_method :define, :new
        private :new
      end  # >>

      def initialize
        yield self
        freeze
      end

      private :dup

      def redefine
        otr = dup
        yield otr
        otr.freeze
      end
    end

    # ==

    Lazy_ = -> & p do
      yes = true ; x = nil
      -> do
        if yes
          yes = false ; x = p[]
        end
        x
      end
    end

    # ==

    class Operation__

      def initialize scn
        @__scn = scn
      end

      def execute
        ok = true
        ok &&= __parse_arguments
        if ok
          if 'mock-path-1.code' == ::File.basename( @_request.paths.last )  # #[#007.H]
            return __result_for_mock_one
          end
        end
        ok &&= __resolve_recording
        ok &&= __resolve_node_for_treemap_via_recording
        ok && self._SOMETHING_VIA_RECORDING
      end

      def __result_for_mock_one
        _st = ::Skylab::CodeMetrics::Magnetics::AsciiMatrix_via_ShapesLayers.call(
          :_stub_of_shapes_layers_, NOTHING_ )
        LineStreamReleaser___.new _st
      end

      def __resolve_node_for_treemap_via_recording  # #testpoint (see #mon-spot-2)
        _rec = remove_instance_variable :@__recording
        _ = @_mags::Node_for_Treemap_via_Recording.call(
          _rec, @_request, & @_listener )
        _store :@__node_for_tremap, _
      end

      def __resolve_recording  # #testpoint (see #mon-spot-2 again)
        recorder = Recorder___.new @_request, @_listener
        recorder.enable
        @_mags = Code_metrics_[]::Magnetics_  # only after we are recording
        __load_all_assets_and_support
        recorder.disable
        _store :@__recording, recorder.flush_recording
      end

      def __load_all_assets_and_support
        la = @_mags::LoadAdapter_via_Request[ @_request, & @_listener ]
        la && la.load_all_assets_and_support
        NIL
      end

      def __parse_arguments
        scn = remove_instance_variable :@__scn
        @_listener = scn.listener
        _ = Request_via_Scanner___.new( scn ).execute
        _store :@_request, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class Request_via_Scanner___

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
      def initialize scn

        @_listener = scn.listener
        @_stderr = scn.stderr  # :#here-1

        @_args = scn
        @_be_verbose = false
        @_system_services = :__system_services_initially
        @_system_services_is_built = false

        @head_const = nil
        @head_path = nil
        @paths = nil
        @require_paths = nil
      end

      def execute
        if __process_arguments
          if __ensure_these :@paths, :@head_const
            __flush
          end
        end
      end

      def __flush
        _svcs = send @_system_services
        Request___.define do |o|
          o.be_verbose = remove_instance_variable :@_be_verbose
          o.debug_IO = remove_instance_variable :@_stderr
          o.head_const = remove_instance_variable :@head_const
          o.head_path = remove_instance_variable :@head_path
          o.paths = remove_instance_variable :@paths
          o.require_paths = remove_instance_variable :@require_paths
          o.system_services = _svcs
        end
      end

      def __ensure_these * ivars
        missing = nil
        ivars.each do |ivar|
          if ! instance_variable_get ivar
            _sym = ivar.id2name.gsub( %r(\A@|s\z), EMPTY_S_ ).intern # sneaky
            ( missing ||= [] ).push _sym
          end
        end
        if missing
          _whine_ do |y|
            _scn = Scanner_via_Array__.call missing  do |sym|
              prim sym
            end
            _and = oxford_and _scn
            y << "for now, required: #{ _and }"
          end
        else
          ACHIEVED_
        end
      end

      def __process_arguments
        ok = true
        @_current_primary = nil
        begin
          if @_args.no_unparsed_exists
            remove_instance_variable :@_args
            remove_instance_variable :@_current_primary
            break
          end
          ok = @_args.lookup_primary_symbol_against PRIMARIES___
          ok || break
          @_current_primary = ok
          ok = send ok.mixed_value
          ok || break
          redo
        end while above
        ok
      end

      PRIMARIES___ = {
        head_const: :_at_item,
        head_path: :_at_path_item,
        path: :_at_path_list_item,
        ping: :__at_ping,
        require_path: :_at_path_list_item,
        verbose: :__at_verbose,
      }

      def __at_verbose
        if @_system_services_is_built
          __whine_about_verbose
        else
          _advance_one
          if @_be_verbose
            @_listener.call :info, :expression do |y|
              y << "(for now there is only one level of versosity.)"
            end
          else
            @_be_verbose = true
          end
          ACHIEVED_
        end
      end

      def __whine_about_verbose
        _whine_ do |y|
          y << "for now, can't turn on #{ prim :verbose } after paths are processed."
          y << "try putting the flag earlier in the request."
        end
      end

      def _at_path_list_item
        x = _gets_path
        if x
          _push_to_list x
        end
      end

      def _at_path_item
        x = _gets_path
        if x
          _set_as_only_item x
        end
      end

      def _gets_path
        x = _gets_trueish
        if x
          x = send( @_system_services ).normalize_user_path x
          x  # hi.
        end
      end

      def _at_item
        x = _gets_trueish
        if x
          _set_as_only_item x
        end
      end

      def __at_ping
        _advance_one
        @_listener.call :info, :expression, :ping do |y|
          y << "hello from mondrian"
        end
        EARLY_END_
      end

      def __system_services_initially
        ss = SystemServices___.new @_be_verbose, @_stderr
        @_system_services_is_built = true
        @_system_services = :__system_services_subsequently
        @___system_services = ss
        ss
      end

      def __system_services_subsequently
        @___system_services
      end

      def _gets_trueish
        _advance_one
        @_args.gets_trueish
      end

      def _push_to_list x
        ivar = :"@#{ @_current_primary.name_symbol }s"
        a = instance_variable_get ivar
        if ! a
          a = []
          instance_variable_set ivar, a
        end
        a.push x ; true
      end

      def _set_as_only_item x
        ivar = :"@#{ @_current_primary.name_symbol }"
        prev = instance_variable_get ivar
        if prev
          __when_value_is_arleady_set
        else
          instance_variable_set ivar, x ; true
        end
      end

      def __when_value_is_arleady_set
        sym = @_current_primary.name_symbol
        _whine_ do |y|
          y << "ambiguous: #{ prim sym } specified multiple times #{
            }but takes only one value"
        end
      end

      def _advance_one
        if @_current_primary.do_advance
          @_args.advance_one
        end
      end

      def _whine_ & msg_p
        @_listener.call :error, :expression, :primary_parse_error do |y|
          calculate y, & msg_p
        end
        UNABLE_
      end
    end

    class Request___ < SimpleModel_  # #testpoint

      attr_accessor(
        :be_verbose,
        :debug_IO,
        :head_const,
        :head_path,
        :paths,
        :require_paths,
        :system_services,
      )

      def do_paginate
        false  # code sketch..
      end
    end

    # ==

    class SystemServices___  # #testpoint

      def initialize do_debug, debug_IO
        @__path_normalizer = PathNormalizer___.new do_debug, debug_IO
      end

      def normalize_user_path path
        # for now , we assume these paths do not contain symlinks
        # BUT WE WILL LIKELY MERGE THESE TWO METHODS
        ::File.expand_path path
      end

      def normalize_system_path path
        @__path_normalizer.__normalize_path_ path
      end

      def glob path
        ::Dir.glob path
      end

      def open_file_read_only path
        ::File.open path, ::File::RDONLY
      end
    end

    # ==

    Squareish_ratio__________ = Lazy_.call do

      # this is :#mon-spot-1.
      # how this ratio works is [#tm-003.2]
      # why it is this value (or near this value) is exactly [#008.A]

      # 6/11 (hi/w) is a "square" on screen.
      # we may stray from this value to achieve some amount of
      # "cheating" to some design end.

      Rational( 6 ) / Rational( 12 )
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
          }#{ tp.binding.receiver.name }#{ SPACE_
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

    CommonScannerMethods__ = ::Module.new

    class ArgumentScanner_for_CLI___ < SimpleModel_

      include CommonScannerMethods__

      def initialize
        yield self

        scn = Scanner_via_Array__.new(
          remove_instance_variable( :@initial_ARGV_offset ),
          remove_instance_variable( :@ARGV ),
        )

        if scn.no_unparsed_exists
          @no_unparsed_exists = true
          remove_instance_variable :@stderr
          freeze
        else
          @no_unparsed_exists = false
          @_real_scanner_ = scn
        end
      end

      attr_writer(
        :ARGV,
        :default_primary_symbol,
        :initial_ARGV_offset,
        :listener,
        :stderr,
      )

      def lookup_fuzzily k, h
        rx = /\A#{ ::Regexp.escape k.id2name }/
        a = []
        h.keys.each do |sym|
          rx =~ sym or next
          a.push Pair__.new( h.fetch( sym ), sym )
        end
        a
      end

      def lookup_primary_symbol_against h
        lu = LookupPrimarySymbol__.new( h, self ).execute
        if lu.ok
          lu  # as pair
        elsif :invalid == lu.category_symbol &&
            /\A--?h(?:e(?:l(?:p)?)?)?\z/ =~ @_real_scanner_.current_token
          __express_help_for h
        else
          lu.execute
        end
      end

      def __express_help_for h
        @stderr.puts "usage: help #open [#007.H]. for now just pass a nonsense arg: -xyzzy"
        EARLY_END_
      end

      def match_well_formed_primary_symbol  # assume some
        md = RX___.match @_real_scanner_.current_token
        if md
          md[ :slug ].gsub( DASH_, UNDERSCORE_ ).intern
        end
      end

      RX___ = /\A--*(?<slug>.+)\z/

      def surface_primary_scanner_of_under hash, expag
        expag.calculate do
          Scanner_via_Array__.call( hash.keys ) { |sym| prim sym }
        end
      end

      attr_reader(
        :default_primary_symbol,
        :stderr,  # #here-1
      )

      def can_fuzzy
        true
      end
    end

    class LookupPrimarySymbol__

      def initialize h, scn
        @hash = h
        @scanner = scn
      end

      def execute
        if __match_well_formed_primary_symbol
          if __find_well_formed_primary_symbol
            @_found
          elsif @scanner.can_fuzzy
            __attempt_fuzzy
          else
            _when_invalid
          end
        elsif __has_default_primary_symbol
          __use_default_primary_symbol
        else
          WhenNotWellFormed___.new @hash, @scanner
        end
      end

      def __attempt_fuzzy
        a = @scanner.lookup_fuzzily @_unsanitized_primary_symbol, @hash
        case 1 <=> a.length
        when 0
          pair = a.fetch 0
          WhenFound__.new pair.mixed_value, pair.name_symbol
        when 1
          _when_invalid
        else
          WhenAmbiguous___.new(
            @_unsanitized_primary_symbol, a, @hash, @scanner )
        end
      end

      def __find_well_formed_primary_symbol
        x = @hash[ @_unsanitized_primary_symbol ]
        if x
          _k = remove_instance_variable :@_unsanitized_primary_symbol
          @_found = WhenFound__.new x, _k ; true
        end
      end

      def __has_default_primary_symbol
        _store :@__default_primary_symbol, @scanner.default_primary_symbol
      end

      def __use_default_primary_symbol
        sym = remove_instance_variable :@__default_primary_symbol
        _x = @hash.fetch sym
        WhenFound__.new false, _x, sym
      end

      def __match_well_formed_primary_symbol
        _ = @scanner.match_well_formed_primary_symbol
        _store :@_unsanitized_primary_symbol, _
      end

      def _when_invalid
        WhenInvalid___.new @_unsanitized_primary_symbol, @hash, @scanner
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    When__ = ::Class.new

    class WhenAmbiguous___ < When__

      def initialize sym, pair_a, * a
        @__pairs = pair_a
        @__unsanitized_primary_symbol = sym
        super( * a )
      end

      def execute
        a = @__pairs
        sym = @__unsanitized_primary_symbol

        _whine_ do |y|

          _scn = Scanner_via_Array__.call a do |pair|
            prim pair.name_symbol
          end

          y << "ambiguous primary #{ ick_prim sym } - #{
            }did you mean #{ oxford_or _scn }?"
        end
      end

      def category_symbol
        :ambiguous
      end
    end

    class WhenInvalid___ < When__
      def initialize k, * a
        @__unsanitized_primary_symbol = k
        super( * a )
      end
      def execute
        k = @__unsanitized_primary_symbol
        me = self
        _whine_ do |y|
          _scn = me._surface_primary_scanner_under_ self
          y << "unknown primary: #{ ick_prim k }"
          y << "available primaries: #{ oxford_and _scn }"
        end
      end
      def category_symbol
        :invalid
      end
    end

    class WhenNotWellFormed___ < When__
      def execute
        s = @scanner.current_token
        _whine_ do |y|
          y << "does not look like primary: #{ s.inspect }"
        end
      end
      def category_symbol
        :not_well_formed
      end
    end

    class WhenFound__

      def initialize do_advance=true, x, sym
        @do_advance = do_advance
        @mixed_value = x
        @name_symbol = sym
      end

      attr_reader(
        :do_advance,
        :mixed_value,
        :name_symbol,
      )

      def ok
        true
      end
    end

    class When__

      def initialize h, scn
        @hash = h ; @scanner = scn
      end

      def _whine_ & msg_p
        __listener.call :error, :expression, :primary_parse_error do |y|
          calculate y, & msg_p
        end
        UNABLE_
      end

      def _surface_primary_scanner_under_ expag
        @scanner.surface_primary_scanner_of_under @hash, expag
      end

      def __listener
        @scanner.listener
      end

      def ok
        false
      end
    end

    class Express_for_CLI_via_Expression___ < SimpleModel_

      attr_writer(
        :channel,
        :emission_proc,
        :stderr,
        :stdout,
      )

      def initialize
        yield self
        # (but don't freeze)
      end

      def execute

        is_error = :error == @channel.fetch(0)
        if :expression == @channel.fetch(1)
          __when_expression
        else
          __when_event
        end
        Result___.new is_error
      end

      Result___ = ::Struct.new :was_error

      def __when_event
        _ev = remove_instance_variable( :@emission_proc ).call
        _y = _yielder_via_channel
        _ev.express_into_under _y, _expression_agent
        NIL
      end

      def __when_expression
        _y = _yielder_via_channel
        _msg_p = remove_instance_variable :@emission_proc
        _expression_agent.calculate _y, & _msg_p
        NIL
      end

      def _expression_agent
        Expression_agent_for_CLI___.instance
      end

      def _yielder_via_channel
        io = __IO_via_channel
        ::Enumerator::Yielder.new do |line|
          io.puts line
        end
      end

      def __IO_via_channel
        case remove_instance_variable( :@channel ).fetch(0)
        when :error, :info
          @stderr
        else fail
        end
      end
    end

    # ==

    Expression_Agent__ = ::Class.new

    class Expression_agent_for_CLI___ < Expression_Agent__

      def ick_prim sym
        prim( sym ).inspect
      end

      def prim sym
        "-#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end
    end

    class LineStreamReleaser___
      # (a stub for a possible future interface for a modality-agnostic response)
      def initialize line_st
        @__line_stream = line_st
      end

      def release_line_stream
        remove_instance_variable :@__line_stream
      end
    end

    # ==

    module CommonScannerMethods__

      def gets_trueish
        if @no_unparsed_exists
          self._COVER_ME__attempt_to_read_trueish_at_end_of_argument_stream__
        else
          x = @_real_scanner_.current_token
          if x
            @_real_scanner_.advance_one
            if @_real_scanner_.no_unparsed_exists
              @no_unparsed_exists = true
            end
            x
          else
            self._COVER_ME__attempt_to_read_trueish_but_had_falseish__
          end
        end
      end

      def advance_one
        @_real_scanner_.advance_one
        @no_unparsed_exists = @_real_scanner_.no_unparsed_exists ; nil
      end

      attr_reader(
        :no_unparsed_exists,
        :listener,
      )
    end

    # ==

    class Expression_Agent__

      class << self
        def instance
          @___instance ||= new
        end
      end

      alias_method :calculate, :instance_exec

      def oxford_or scn
        _oxford_join scn, ' or ', ', '
      end

      def oxford_and scn
        _oxford_join scn, ' and ', ', '
      end

      def _oxford_join scn, ult, nonult
        buff = scn.gets_one.dup
        if ! scn.no_unparsed_exists
          begin
            s = scn.gets_one
            scn.no_unparsed_exists && break
            buff << nonult << s
            redo
          end while above
          buff << ult << s
        end
        buff
      end
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

    class PathNormalizer___  # :[#017]

      # dereference all symbolic link nodes in an absolute path recursively.

      # (without this, paths passed in as arguments from the terminal don't
      # correspond to paths associated with asset nodes in our gems, and so
      # all events are filtered out during recording.)

      # (near [#tm-013.1])

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

      def __normalize_path_ path
        send @_normalize_path, path
      end

      def __normalize_path_expressively path
        path_ = _normalize_path path
        if path_ == path
          @_debug_IO.puts "same: #{ path_ }"
        else
          @_debug_IO.puts "normalized #{ path_ } from #{ path }"
        end
        path_
      end

      def _normalize_path path
        lu = _lookup_path_ path
        # ..
        lu.real_path
      end

      def _lookup_path_ path
        @_prototype.__lookup_path_ path
      end

      attr_reader(
        :_tree_cache_,
        :_referenced_real_directories_,
        :_symlink_node_via_offset_,
        :_symlink_offset_via_path_,
      )
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

      def __lookup_path_ path
        dup.__init( path ).execute
      end

      def __init path
        @path = path ; self
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
          node = _gets_node
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
          @_normal_path_buffer << ::File::SEPARATOR
          @_normal_path_buffer << @_current_part
        end
      end

      def _gets_node
        @_current_part = @_scn.gets_one
        @_current_path = nil
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
        lu = @_path_normalizer._lookup_path_ _mid_target_path
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
        x = remove_instance_variable :@current_token
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
        @current_token = s
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
        :current_token,
        :ended_with_separator,
        :is_absolute,
        :no_unparsed_exists,
      )
    end

    # ==

    class Mapped_Scanner___

      def initialize p, scn
        @_proc = p
        @_scn = scn
      end

      def gets_one
        @_proc[ @_scn.gets_one ]
      end

      def current_token  # ..
        @_proc[ @_scn.current_token ]
      end

      def advance_one
        @_scn.advance_one
      end

      def no_unparsed_exists
        @_scn.no_unparsed_exists
      end
    end

    # ==

    class Scanner_via_Array__

      class << self
        def call d=nil, a, & p
          scn = new d, a
          if block_given?
            Mapped_Scanner___.new p, scn
          else
            scn
          end
        end
        alias_method :[], :call
      end  # >>

      def initialize d=nil, a
        d ||= 0
        len = a.length
        if len == d
          @no_unparsed_exists = true ; freeze
        else
          @_array = a
          @_len = len
          @_pos = d
        end
      end

      def gets_one
        x = current_token
        advance_one
        x
      end

      def advance_one
        d = @_pos + 1
        if @_len == d
          @no_unparsed_exists = true
          remove_instance_variable :@_array
          remove_instance_variable :@_len
          remove_instance_variable :@_pos
          freeze
        else
          @_pos = d
        end
        NIL
      end

      def current_token
        @_array.fetch @_pos
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==

    Pair__ = ::Struct.new :mixed_value, :name_symbol

    # ==

    Code_metrics_ = Lazy_.call do
      # don't load normal-space until recording is enabled, otherwise you
      # won't be able to generate viz for any nodes loaded. see top of file.
      require 'skylab/code_metrics'
      ::Skylab::CodeMetrics
    end

    # ==

    ACHIEVED_ = true
    DASH_ = '-'
    EARLY_END_ = nil
    EMPTY_S_ = ''
    NOTHING_ = nil
    SPACE_ = ' '
    UNABLE_ = false
    UNDERSCORE_ = '_'

    # ==
  end
# -
# #born
