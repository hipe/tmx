require 'strscan'  # for ::StringScanner below

# -
  class Skylab_CodeMetrics_Operations_Mondrian_EarlyInterpreter

    # the central implementation mechanic of this visualization is that
    # TracePoint ("[the] facility") is used to determine the lines-of-code
    # size for module elements (e.g classes).
    #
    # the caveat to using the facility for this objective is that the
    # facility communicates events of interest *while* the files of interest
    # are loaded (parsed), so you cannot (straightforwardly) apply this
    # technique to files that have already been loaded into your runtime
    # once you begin "listening".
    #
    # (a workaround might be to load the files of interest twice, but we
    # anticipate this as carrying significant hidden future costs, as we
    # can imagine some files that are difficult or impossible to load twice.
    # also what we attempt here accords more cleanly with our next wish,
    # which is file globs.)
    #
    # so this becomes a bootstrapping challenge, similar to trying to
    # produce code coverage over files that are involved in processing
    # a request:
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
        'mondrian' == argv[0] || fail  # ..

        listener = method :__receive_emission

        _scn = ArgumentScanner_for_CLI___.define do |o|
          o.default_primary_symbol = :path
          o.initial_ARGV_offset = 1
          o.ARGV = argv
          o.stderr = @stderr
          o.listener = listener
        end

        @exitstatus = 0

        _ss = SystemServices___.new

        o = Operation__.new( _scn, _ss ).execute
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
      end

      private :dup
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

      def initialize scn, ss
        @__scn = scn
        @_system_services = ss
      end

      def execute
        if __parse_arguments

          if 'mock-path-1.code' == ::File.basename( @__request.paths.last )  # #[#007.H]
            return __result_for_mock_one
          end

          __produce_recording
        end
      end

      def __result_for_mock_one
        _st = ::Skylab::CodeMetrics::Magnetics::AsciiMatrix_via_ShapesLayers.call(
          :_stub_of_shapes_layers_, NOTHING_ )
        LineStreamReleaser___.new _st
      end

      def __produce_recording
        _request = remove_instance_variable :@__request
        recorder = Recorder___.new _request, @_system_services, @_listener
        $stderr.puts "SCOTT BAYO" ; if false
        recorder.enable
        recorder.disable
        end
        NOTHING_
      end

      def __parse_arguments
        scn = remove_instance_variable :@__scn
        @_listener = scn.listener
        _ = Request_via_Scanner___.new( scn, @_system_services ).execute
        _store :@__request, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    class Request_via_Scanner___

      def initialize scn, ss
        @_args = scn
        @_listener = scn.listener
        @_system_services = ss

        @DO_TRACE = true
        @head_const = nil
        @head_path = nil
        @paths = nil
        @require_paths = nil
      end

      def execute
        if __process_arguments
          if __ensure_these :@paths, :@head_const
            Request___.define do |o|
              o.debug_IO = $stderr  # ..
              o.do_debug = remove_instance_variable :@DO_TRACE
              o.head_const = remove_instance_variable :@head_const
              o.head_path = remove_instance_variable :@head_path
              o.paths = remove_instance_variable :@paths
              o.require_paths = remove_instance_variable :@require_paths
            end
          end
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
      }

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
          x = @_system_services.normalize_user_path x
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
        _maybe_advance
        @_listener.call :info, :expression, :ping do |y|
          y << "hello from mondrian"
        end
        EARLY_END_
      end

      def _gets_trueish
        _maybe_advance
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

      def _maybe_advance
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

    class Request___ < SimpleModel_  # (should be) #testpoint
      attr_accessor(
        :debug_IO,
        :do_debug,
        :head_const,
        :head_path,
        :paths,
        :require_paths,
      )
    end

    # ==

    class SystemServices___

      def normalize_user_path path
        # for now , we assume these paths do not contain symblinks
        ::File.expand_path path
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

      def initialize req, svcs, l

        do_debug = req.do_debug; debug_IO = req.debug_IO

        @_tracepoint = TracePoint.new :class, :end do
          @_path = @_tracepoint.path
          case @_tracepoint.event
          when :class
            send @_on_class
          when :end
            send @_on_end
          else never
          end
        end

        @_path_matcher = CachingPathMatcher___.define do |o|
          o.do_debug = do_debug
          o.debug_IO = debug_IO
          o.paths = req.paths
          o.system_services = svcs
        end

        @_on_class = :__on_class_ALWAYS
        @_on_end = :__on_end_ALWAYS

        @_CAN_HAVE_SYSTEM_SERVICES = true
        @_debug_IO = debug_IO
      end

      def enable
        @_tracepoint.enable
      end

      def disable
        @_tracepoint.disable
      end

      def __on_class_ALWAYS
        if @_path_matcher =~ @_path
          @_debug_IO.puts "WAHOO matched class on line #{ @_tracepoint.lineno }"
        end
      end

      def __on_end_ALWAYS
        if @_path_matcher =~ @_path
          @_debug_IO.puts "WAHOO matched end on line #{ @_tracepoint.lineno }"
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

        do_debug = remove_instance_variable :@do_debug

        @__path_normalizer = PathNormalizer___.new do_debug, @debug_IO

        if do_debug
          @_work_method_name = :__work_expressively
        else
          remove_instance_variable :@debug_IO
          @_work_method_name = :_work
        end

        remove_instance_variable :@system_services  # NOT_USED_YET

        @_path_cache = {}
      end

      attr_writer(
        :do_debug,
        :debug_IO,
        :paths,
        :system_services,
      )

      def =~ path
        m = @_work_method_name
        @_path_cache.fetch path do
          x = send m, path
          @_path_cache[ path ] = x
          x
        end
      end

      def __work_expressively path
        yes = _work path
        if yes
          @debug_IO.puts "MATCHED: #{ path }"
        else
          @debug_IO.puts "skip: #{ path }"
        end
        yes
      end

      def _work path

        real_path = @__path_normalizer.normalize_path path

        did_match = false
        @paths.each do |formal_path|

          if ::File.fnmatch formal_path, real_path
            did_match = true
            break
          end
        end
        did_match
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

      def normalize_path path
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
        scn = PathScanner__.via @path
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

    class PathScanner__

      # process each part of a path with a familiar interface

      class << self
        def via path
          scn = ::StringScanner.new path
          if scn.skip SEP__
            NOTHING_ while scn.skip SEP__
            new scn
          else
            IS_NOT_ABSOLUTE___
          end
        end
        private :new
      end  # >>

      def initialize scn
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
        :ended_with_separator,
        :no_unparsed_exists,
      )

      def is_absolute
        true
      end
    end

    module IS_NOT_ABSOLUTE___ ; class << self
      def is_absolute
        false
      end
    end ; end

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
