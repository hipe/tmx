module NoDependenciesZerk

  # freshly abtracted from [cm], officially this is [#060]

  # when you need to make a client that doesn't load a lot of files
  # (like one that turns on coverage testing or similar), this is a
  # single-file implementation of the basics needed to make API & CLI

  # on parse failures it allows itself to load arbitrary other files..

  # -

    Lazy = -> & p do
      yes = true ; x = nil
      -> do
        if yes
          yes = false ; x = p[]
        end
        x
      end
    end

    SimpleModel = ::Class.new  # forward declaration

    # = CLI life

    class CLI_Express_via_Emission < SimpleModel

      class << self

        def call p, a, cli
          call_by do |o|
            o.emission_proc = p
            o.channel = a
            o.client = cli
          end
        end
        alias_method :[], :call

        def call_by & p
          new( & p ).execute
        end
      end  # >>

      attr_writer(
        :client,  # only for `data`
        :channel,
        :emission_handler_methods,
        :emission_proc,
        :expression_agent_by,
        :signal_by,
        :stderr,
      )

      def initialize
        @emission_handler_methods = nil
        @expression_agent_by = nil
        @stderr = nil
        yield self
        @emission_handler_methods ||= -> _ { nil }  # MONADIC_EMPTINESS_
        # (but don't freeze)
      end

      def execute
        m = @emission_handler_methods[ @channel.last ]
        if m
          @client.send m  # no args - client should have an ivar holding self
        else
          express_normally
        end
      end

      def express_normally
        method_name = nil
        FIRST_CHANNEL___.fetch( @channel.fetch 0 )[ binding ]
        if method_name
          send method_name
        elsif :expression == @channel.fetch(1)
          __express_expression
        else
          __express_event
        end
        Result___.new @_was_error
      end

      Result___ = ::Struct.new :was_error

      FIRST_CHANNEL___ = {
        data: -> bnd do
          bnd.local_variable_set :method_name, :__when_data
        end,
        error: -> bnd do
          bnd.receiver.instance_variable_set :@_was_error, true
        end,
        info: -> bnd do
          bnd.receiver.instance_variable_set :@_was_error, false
        end,
        signal: -> bnd do
          bnd.local_variable_set :method_name, :__when_signal
        end,
      }

      def __express_event
        _ev = remove_instance_variable( :@emission_proc ).call
        _y = _yielder_via_channel
        _ev.express_into_under _y, _expression_agent
        NIL
      end

      def __express_expression
        _y = _yielder_via_channel
        _msg_p = remove_instance_variable :@emission_proc
        _expression_agent.calculate _y, & _msg_p
        NIL
      end

      def __when_signal
        _ok = @signal_by[ @emission_proc, @channel ]
        @_was_error = ! _ok
        NIL  # EARLY_END
      end

      def __when_data
        @client.receive_data_emission @emission_proc, @chanel
        NIL  # EARLY_END
      end

      def _expression_agent
        p = @expression_agent_by
        if p
          p.call
        elsif @client.respond_to? :expression_agent
          @client.expression_agent
        else
          CLI_ExpressionAgent.instance
        end
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
          ( @stderr || @client.stderr )
        else fail
        end
      end
    end

    # ==

    ArgumentScannerMethods__ = ::Module.new  # forward declaration

    class CLI_ArgumentScanner < SimpleModel

      include ArgumentScannerMethods__

      class << self
        def new argv, & l
          define do |o|
            o.ARGV = argv
            o.listener = l
          end
        end
      end  # >>

      def initialize

        @_read_CPS = :__read_CPS_initially
        @_write_CPS = :__write_CPS_initially

        @initial_ARGV_offset = 0
        @default_primary_symbol = nil
        @listener = nil
        yield self
        s_a = remove_instance_variable :@ARGV
        len = s_a.length
        d = remove_instance_variable :@initial_ARGV_offset
        if len == d
          @no_unparsed_exists = true
          freeze
        else
          @_array = s_a
          @_current_index = d
          @_last_index = s_a.length - 1
        end
      end

      attr_writer(
        :ARGV,
        :default_primary_symbol,
        :initial_ARGV_offset,
        :listener,
      )

      # --

      def _parse_operator_softly_
        s = head_as_is
        if OPERATOR_RX___ =~ s
          _ = s.gsub( DASH_, UNDERSCORE_ ).intern
          @_read_COS = :__read_COS_normally  # usu. 1x
          @__current_operator_symbol = _
          advance_one
          ACHIEVED_
        else
          self._COVER_just_dont_result_in_anything
        end
      end

      OPERATOR_RX___ = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/i

      def current_operator_as_matcher
        %r(\A#{ ::Regexp.escape current_operator_symbol.id2name })i
      end

      def current_operator_symbol
        send @_read_COS
      end

      def __read_COS_normally
        @__current_operator_symbol
      end

      def parse_primary  # exactly as [#ze-052.1] canon
        s = head_as_is
        md = PRIMARY_RX___.match s
        if md
          _ = md[ 1 ].gsub( DASH_, UNDERSCORE_ ).intern
          send @_write_CPS, _
          advance_one
          ACHIEVED_
        elsif @default_primary_symbol
          # #not-covered - blind faith
          send @_write_CPS, @default_primary_symbol
          ACHIEVED_
        else
          __when_malformed_primary s
        end
      end

      PRIMARY_RX___ = /\A--?([a-z0-9]+(?:-[a-z0-9]+)*)\z/i

      def __write_CPS_initially sym
        @_read_CPS = :__read_CPS_normally
        @_write_CPS = :__write_CPS_normally
        send @_write_CPS, sym
      end

      def __write_CPS_normally sym
        @_current_primary_symbol = sym ; nil
      end

      def __read_CPS_initially
        raise ScannerIsNotInThatState,
          "cannot read `current_primary_symbol` from beginning state"
      end

      def __read_CPS_normally
        @_current_primary_symbol
      end

      # --

      def fuzzy_lookup_primary_or_fail h  # assume CPS

        rx = /\A#{ ::Regexp.escape current_primary_symbol.id2name }/
        a = []
        h.keys.each do |k|
          rx =~ k or next
          a.push k
        end
        case 1 <=> a.length
        when 0
          k = a.fetch 0
          @_current_primary_symbol = k
          h.fetch k
        when 1
          When_primary_not_found__[ h, self ]
        else
          __when_ambiguous a
        end
      end

      def parse_positive_nonzero_integer
        d = __integer_that { |d_| 0 < d_ }
        d && advance_one
        d
      end

      def parse_non_negative_integer
        d = __integer_that { |d_| -1 < d_ }
        d && advance_one
        d
      end

      def __integer_that & p
        d = __head_as_integer
        if d
          if yield d
            d
          else
            __when_integer_is_not d, caller_locations( 1, 1 )[ 0 ]
          end
        end
      end

      def __when_integer_is_not d, loc
        _s = %r(\Aparse_(.+)_integer\z).match( loc.base_label )[ 1 ]
        _human = _s.gsub UNDERSCORE_, SPACE_
        no_because { "{{ prim }} must be #{ _human } (had #{ d })" }
      end

      def __head_as_integer
        map_value_by do |s|
          if %r(\A-?\d+\z) =~ s
            s.to_i
          else
            no_because { "{{ prim }} must be an integer (had #{ s.inspect })" }
          end
        end
      end

      # --

      def __when_ambiguous a
        k = current_primary_symbol
        no_because do |y|
          _scn = Scanner_via_Array.call( a ) { |sym| prim sym }
          y << "ambiguous primary #{ ick_prim k } - #{
            }did you mean #{ oxford_or _scn }?"
        end
      end

      def __when_malformed_primary s
        no_because do |y|
          y << "does not look like primary: #{ s.inspect }"
        end
      end

      # --

      def advance_one
        if @_last_index == @_current_index
          remove_instance_variable :@_array
          remove_instance_variable :@_current_index
          remove_instance_variable :@_last_index
          @no_unparsed_exists = true
          # can't freeze because the current primary may be set
        else
          @_current_index += 1
        end
        NIL
      end

      # --

      def current_primary_symbol
        send @_read_CPS
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )

      def can_fuzzy
        true
      end

      ScannerIsNotInThatState = ::Class.new ::RuntimeError
    end

    # ==

    ExpressionAgent__ = ::Class.new  # forward declaration

    class CLI_ExpressionAgent < ExpressionAgent__

      def ick_prim sym
        prim( sym ).inspect
      end

      def prim sym
        "-#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end
    end

    # = API life

    class API_ArgumentScanner

      include ArgumentScannerMethods__

      def initialize a, & l
        @_current_primary = :__current_primary_invalid
        @_receive_current_primary = :__receive_first_ever_current_primary
        @listener = l  # not used here presently, just a courtesy
        if a.length.zero?
          @no_unparsed_exists = true
          freeze
        else
          @_array = a
          @_current_index = 0
          @_last_index = a.length - 1
        end
      end

      def _parse_operator_softly_
        # (we don't check if it's a symbol but we could)
        @current_operator_symbol = head_as_is
        advance_one
        ACHIEVED_
      end

      def parse_primary
        # (we don't check if it's a symbol but we could)
        send @_receive_current_primary, head_as_is
        advance_one
        ACHIEVED_
      end

      def __receive_first_ever_current_primary sym
        @_current_primary = :__current_primary_normally
        @_receive_current_primary = :__receive_current_primary_normally
        send @_receive_current_primary, sym
      end

      def __receive_current_primary_normally sym
        @__current_primary_value = sym ; nil
      end

      def fuzzy_lookup_primary_or_fail h
        When_primary_not_found__[ h, self ]
      end

      def current_primary_symbol
        send @_current_primary
      end

      def __current_primary_invalid
        raise ScannerIsNotInThatState,
          "cannot read `current_primary_symbol` from beginning state"
      end

      def __current_primary_normally
        @__current_primary_value
      end

      def advance_one
        if @_last_index == @_current_index
          remove_instance_variable :@_array
          remove_instance_variable :@_current_index
          remove_instance_variable :@_last_index
          @no_unparsed_exists = true
          freeze
        else
          @_current_index += 1
        end
        NIL
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :listener,
        :no_unparsed_exists,
      )

      def can_fuzzy
        false
      end

      # ===

      ScannerIsNotInThatState = ::Class.new ::RuntimeError

      # ===
    end

    # ==

    class API_ExpressionAgent < ExpressionAgent__

      def ick_prim sym
        prim sym
      end

      def prim sym
        "'#{ sym.id2name }'"
      end
    end

    # = modality-agnostic life

    Check_requireds = -> o, ivars, & p do
      when_missing = nil
      missing = nil
      main = -> do
        ivars.each do |ivar|
          if o.instance_variable_defined? ivar
            x = o.instance_variable_get ivar
          end
          if x.nil?
            _sym = ivar.id2name.gsub( %r(\A@|s\z), EMPTY_S_ ).intern  # sneaky
            ( missing ||= [] ).push _sym
          end
        end
        if missing
          when_missing[]
        else
          ACHIEVED_
        end
      end

      when_missing = -> do
        p.call :error, :expression, :primary_parse_error do |y|
          _scn = Scanner_via_Array.call missing do |sym|
            prim sym
          end
          _and = oxford_and _scn
          y << "required: #{ _and }"
        end
        UNABLE_
      end

      main[]
    end

    class ParseArguments_via_FeaturesInjections < SimpleModel

      class << self
        def call scn, prim_h, client
          define do |o|
            o.argument_scanner scn
            o.add_primaries_injection prim_h, client
          end.flush_to_parse_primaries
        end
        alias_method :[], :call
      end  # >>

      def initialize
        @_add_operators_injection = :__add_first_operators_injection
        @_add_primaries_injection = :__add_first_primaries_injection
        yield self
      end

      attr_writer(
        :argument_scanner,
      )

      def add_hash_based_operators_injection h, injector
        _add_operators_injection HashBasedOperatorsInjection___.new( h, injector )
      end

      def add_lazy_operators_injection_by & p
        _add_operators_injection LazyOperatorsInjection___.new p
      end

      def _add_operators_injection ada
        send @_add_operators_injection, ada
      end

      def __add_first_operators_injection ada
        @has_operators = true
        @_operators_injections = []
        @_add_operators_injection = :__add_operators_injection_normally
        send @_add_operators_injection, ada
      end

      def __add_operators_injection_normally ada
        @_operators_injections.push ada ; nil
      end

      def add_primaries_injection h, injector
        send @_add_primaries_injection, h, injector
      end

      def __add_first_primaries_injection h, injector
        @has_primaries = true
        @_primaries = {}
        @_primary_injectors = []
        @_add_primaries_injection = :__add_primaries_injection_normally
        send @_add_primaries_injection, h, injector
      end

      def __add_primaries_injection_normally h, injector
        index_h = @_primaries
        inj_d = @_primary_injectors.length
        h.each_pair do |k, m|
          index_h[ k ] = [ inj_d, m ]  # meh for now just overwrite
        end
        @_primary_injectors[ inj_d ] = injector ; nil
      end

      # -- NOTE the below might break out

      def parse_operator_softly  # see next method
        @argument_scanner._parse_operator_softly_
      end

      def flush_to_lookup_operator  # assume:

        #  - assume above method succeeded
        #  - assume there are some operators injections
        #
        #  result is a FOO NANI if found, and a POO NANI if failed

        sym = @argument_scanner.current_operator_symbol
        scn = _to_operations_injections_scanner

        begin
          ijn = scn.gets_one
          ijn = ijn.injection
          x = ijn.lookup_softly sym
          x && break
        end until scn.no_unparsed_exists
        if x
          Found__[ ijn.injector, x ]
        elsif @argument_scanner.can_fuzzy
          __fuzzy_lookup_operator
        else
          self._COVER_ME__easy_probably__
        end
      end

      def __fuzzy_lookup_operator

        # rather than map-expand we loop inside loop but this might change
        a = []
        rx = @argument_scanner.current_operator_as_matcher
        scn = _to_operations_injections_scanner
        begin
          ijn = scn.gets_one
          ijn = ijn.injection
          scn_ = ijn.to_normal_symbol_scanner
          begin
            if rx =~ scn_.current_token
              a.push Found__[ ijn.injector, scn_.current_token ]
            end
            scn_.advance_one
          end until scn_.no_unparsed_exists
        end until scn.no_unparsed_exists
        case 1 <=> a.length
        when 0  # when found
          a.fetch 0
        when 1  # when not found
          __when_primary_not_found
        else  # when ambiguous
          self._COVER_ME__when_ambiguous__  # rejoin with legacy
        end
      end

      def __when_primary_not_found
        _scn = to_operation_symbol_scanner
        self._WORKED_ONCE
      end

      def to_operation_symbol_scanner
        _to_operations_injections_scanner.expand_by do |ijn|
          ijn.to_normal_symbol_scanner
        end
      end

      def _to_operations_injections_scanner
        Scanner_via_Array.new @_operators_injections
      end

      Found__ = ::Struct.new :injector, :mixed_business_value

      def flush_to_parse_primaries

        # if there are any tokens remaining on the scanner,
        # parse them as primaries or whine appropriately

        args = remove_instance_variable :@argument_scanner
        a = remove_instance_variable :@_primary_injectors
        h = remove_instance_variable :@_primaries
        ok = true
        until args.no_unparsed_exists
          ok = args.parse_primary
          ok || break
          tuple = h[ args.current_primary_symbol ]
          if ! tuple
            tuple = args.fuzzy_lookup_primary_or_fail h
          end
          if ! tuple
            ok = tuple ; break
          end
          ok = a.fetch( tuple[0] ).send tuple[1]
          ok || break
        end
        ok
      end

      def to_primary_symbol_scanner  # assume
        Scanner_via_Array[ @_primaries.keys ]
      end

      attr_reader(
        :argument_scanner,
        :has_operators,
        :has_primaries,
      )
    end

    # --

    class LazyOperatorsInjection___
      def initialize p
        @_injection = :__injection_initially
        @__proc = p
      end
      def injection
        send @_injection
      end
      def __injection_initially
        remove_instance_variable( :@__proc )[ self ]  # meh
        @_injection = :__injection_normally
        freeze
      end
      attr_writer :operators
      attr_accessor :injector
      def __injection_normally
        self
      end
      def lookup_softly k
        @operators.lookup_softly k
      end
      def to_normal_symbol_scanner
        Scanner_via_Stream__.new @operators.to_normal_symbol_stream
      end
    end

    class HashBasedOperatorsInjection___
      def initialize h, inj
        @_hash = h
        @injector = inj
      end
      def injection
        self
      end
      def lookup_softly k
        @_hash[ k ]
      end
      def to_normal_symbol_scanner
        Scanner_via_Array[ @_hash.keys ]
      end
      attr_reader(
        :injector,
      )
    end

    # ==

    module ArgumentScannerMethods__

      def current_primary_as_ivar
        :"@#{ current_primary_symbol }"
      end

      def map_value_by
        if no_unparsed_exists
          no_because { "{{ prim }} requires an argument" }
        else
          yield head_as_is
        end
      end

      def no_because reason_symbol=:primary_parse_error, & msg_p

        scn = self
        @listener.call :error, :expression, reason_symbol do |y|

          map = -> sym do
            case sym
            when :prim
              prim scn.current_primary_symbol
            end
          end

          _y = ::Enumerator::Yielder.new do |line|
            y << ( line.gsub %r(\{\{[ ]*([a-z_]+)[ ]*\}\}) do
              map[ $~[1].intern ]
            end )
          end

          if msg_p.arity.zero?
            _y << calculate( & msg_p )
          else
            calculate _y, & msg_p
          end
          y
        end

        UNABLE_
      end
    end

    When_primary_not_found__ = -> h, scn do
      k = scn.current_primary_symbol
      scn.no_because do |y|
        _scn = Scanner_via_Array.call( h.keys ) { |sym| prim sym }
        y << "unknown primary: #{ ick_prim k }"
        y << "available primaries: #{ oxford_and _scn }"
      end
    end

    class ExpressionAgent__

      class << self
        def instance
          @___instance ||= new
        end
      end

      alias_method :calculate, :instance_exec

      def oxford_or scn
        scn.oxford_join '', ' or ', ', '
      end

      def oxford_and scn
        scn.oxford_join '', ' and ', ', '
      end
    end

    # = support

    Scanner__ = ::Class.new

    class Scanner_via_Array < Scanner__

      class << self
        def call d=nil, a, & p
          scn = new d, a
          if block_given?
            Mapped_Scanner__.new p, scn
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

    class Mapped_Scanner__ < Scanner__

      def initialize p, scn
        @_proc = p
        @_scn = scn
      end

      def no_unparsed_exists
        @_scn.no_unparsed_exists
      end

      def current_token  # ..
        @_proc[ @_scn.current_token ]
      end

      def advance_one
        @_scn.advance_one
      end
    end

    class Scanner_via_Stream__ < Scanner__
      def initialize st
        x = st.call  # same as `.gets`
        if x
          @__current_token = x
          @_current_token = :__current_token_normally
          @_stream = st
        else
          @no_unparsed_exists = true
        end
      end
      def advance_one
        x = @_stream.call
        if x
          @__current_token = x
        else
          remove_instance_variable :@__current_token
          remove_instance_variable :@_current_token
          remove_instance_variable :@_stream
          @no_unparsed_exists = true
        end
        NIL
      end
      def current_token
        send @_current_token
      end
      def __current_token_normally
        @__current_token
      end
      attr_reader(
        :no_unparsed_exists,
      )
    end

    class Scanner__

      def oxford_join buff, ult, sep  # assume some
        buff << gets_one
        unless no_unparsed_exists
          begin
            s = gets_one
            no_unparsed_exists && break
            buff << sep << s
            redo
          end while above
          buff << ult << s
        end
        buff
      end

      def expand_by & expand_by
        main = nil ; p = nil ; scn = nil
        advance = -> do
          if no_unparsed_exists
            p = nil ; nil
          else
            scn = expand_by[ gets_one ]
            ( p = main )[]
          end
        end
        main = -> do
          if scn.no_unparsed_exists
            ( p = advance )[]
          else
            _wahoo = scn.gets_one
            _wahoo
          end
        end
        p = advance
        Scanner_via_Stream__.new( -> do
          p[]
        end )
      end

      def map_by & p
        Mapped_Scanner__.new p, self
      end

      def gets_one
        x = current_token
        advance_one
        x
      end
    end


    # ==

    class SimpleModel

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

    ACHIEVED_ = true
    DASH_ = '-'
    EMPTY_S_ = ''
    SPACE_ = ' '
    UNABLE_ = false
    UNDERSCORE_ = '_'

    # ==
  # -
end
