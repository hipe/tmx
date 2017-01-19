module NoDependenciesZerk

  # freshly abtracted from [cm], officially this is [#060]

  # when you need to make a client that doesn't load a lot of files
  # (like one that turns on coverage testing or similar), this is a
  # single-file implementation of the basics needed to make API & CLI
  #
  # but NOTE [ze] may be loaded to handle the follwing circumstances:
  #
  #   - to express a parse failure

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
    MagneticBySimpleModel = ::Class.new SimpleModel

    # = CLI life

    class CLI_Express_via_Emission < MagneticBySimpleModel

      class << self

        def call p, a, cli
          call_by do |o|
            o.emission_proc_and_channel p, a
            o.client = cli
          end
        end
        alias_method :[], :call
      end  # >>

      def emission_proc_and_channel p, chan
        @channel = chan ; @emission_proc = p ; nil
      end

      attr_writer(
        :client,  # only for `data`
        :emission_handler_methods,
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
          _flush_result
        else
          __express_event
          _flush_result
        end
      end

      def _flush_result
        Result___.new remove_instance_variable :@_was_error
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
        @client.receive_data_emission @emission_proc, @channel
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

      attr_reader :channel
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
          @_current_index = d  # name is #testpoint
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

      def parse_operator_softly
        s = head_as_is
        if OPERATOR_RX___ =~ s
          _ = s.gsub( DASH_, UNDERSCORE_ ).intern
          @_read_COS = :__read_COS_normally  # usu. 1x
          @__current_operator_symbol = _
          advance_one
          ACHIEVED_
        else
          NIL  # #nodeps-coverpoint-1
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
        if parse_primary_softly
          ACHIEVED_
        else
          __when_malformed_primary
        end
      end

      def parse_primary_softly
        md = PRIMARY_RX___.match head_as_is
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
          NIL  # #nodeps-coverpoint-2
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

      def _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_  scn  # #here-1
        # assume: a `current_primary_symbol` with no exact match
        rx = /\A#{ ::Regexp.escape current_primary_symbol.id2name }/
        a = []
        until scn.no_unparsed_exists
          twople = scn.gets_one
          rx =~ twople.last.intern or next
          a.push twople
        end
        a
      end

      def parse_positive_nonzero_integer
        _integer_that { |d_| 0 < d_ }
      end

      def parse_non_negative_integer
        _integer_that { |d_| -1 < d_ }
      end

      def _integer_that & p
        d = __head_as_integer
        if d
          if yield d
            advance_one
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

      def when_malformed_primary_or_operator  # courtesy, for proximity to below
        s = head_as_is
        no_because do |y|
          if s.include? UNDERSCORE_ and %r(\A[a-z0-9_]+\z) =~ s
            _hint = " (did you mean #{ s.gsub UNDERSCORE_, DASH_ }?)"
          end
          y << "unknown primary or operator: #{ s.inspect }#{ _hint }"
        end
      end

      def __when_malformed_primary
        s = head_as_is
        no_because do |y|
          y << "does not look like primary: #{ s.inspect }"
        end
      end

      # --

      def retreat_one  # we don't clear current_primary_symbol !
        if no_unparsed_exists
          @no_unparsed_exists = false
          @_current_index = @_last_index
        else
          @_current_index.zero? && self._SANITY
          @_current_index -= 1 ; nil
        end
        NIL
      end

      def advance_one
        if @_last_index == @_current_index
          @_current_index += 1  # #nodeps-coverpoint-4
          @no_unparsed_exists = true
          # can't freeze because the current primary may be set
        else
          @_current_index += 1
        end
        NIL
      end

      def close_and_release  # #experiment  1x here 1x [tmx]
        @is_closed = true
        remove_instance_variable :@_last_index
        a = [ remove_instance_variable( :@_current_index ),
          remove_instance_variable( :@_array ) ]
        freeze
        a
      end

      # --

      def current_primary_symbol
        send @_read_CPS
      end

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :is_closed,
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

      def ick_oper sym
        oper( sym ).inspect
      end

      def ick_prim sym
        prim( sym ).inspect
      end

      def oper sym
        sym.id2name.gsub UNDERSCORE_, DASH_
      end

      def prim sym
        "-#{ oper sym }"
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

      def _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_
        # assume: a `current_primary_symbol` with no exact match
        LENGTH_ZERO___
      end

      module LENGTH_ZERO___ ; class << self ; def length ; 0 end end end

      def _fuzzy_lookup_primary_or_fail h
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

      def ick_oper sym
        _same sym
      end

      def ick_prim sym
        _same sym
      end

      def oper sym
        _same sym
      end

      def prim sym
        _same sym
      end

      def _same sym
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
            o.argument_scanner = scn
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
        _add_operators_injection HashBasedFeaturesInjection__.new( h, injector )
      end

      def add_primaries_injection h, injector  # (is the counterpart to above)
        _add_primaries_injection HashBasedFeaturesInjection__.new( h, injector )
      end

      def add_lazy_operators_injection_by & p
        _add_operators_injection LazyOperatorsInjectionTicket___.new p
      end

      def add_lazy_primaries_injection_by & p
        _add_primaries_injection LazyPrimariesInjectionTicket___.new p
      end

      def _add_operators_injection ada
        send @_add_operators_injection, ada
      end

      def _add_primaries_injection ada
        send @_add_primaries_injection, ada
      end

      def __add_first_operators_injection ada
        @has_operators = true
        @_operators_injections = []
        @_add_operators_injection = :__add_operators_injection_normally
        send @_add_operators_injection, ada
      end

      def __add_first_primaries_injection ada
        @has_primaries = true
        @_offset_of_last_primary_injection = -1
        @_primaries_injections = []
        @_add_primaries_injection = :__add_primaries_injection_normally
        send @_add_primaries_injection, ada
      end

      def __add_operators_injection_normally ada
        @_operators_injections.push ada ; nil
      end

      def __add_primaries_injection_normally ada
        @_offset_of_last_primary_injection += 1
        @_primaries_injections.push ada ; nil
      end

      # -- NOTE the below might break out

      def parse_primary_softly
        @argument_scanner.parse_primary_softly
      end

      def parse_operator_softly  # see next method
        @argument_scanner.parse_operator_softly
      end

      def flush_to_lookup_operator  # assume:

        #  - assume above method succeeded
        #  - assume there are some operators injections
        #
        #  result is a "found tuple" if found, and FOR NOW
        #  on failure we emit here and resutt in false.

        sym = @argument_scanner.current_operator_symbol
        scn = to_operators_injections_scanner

        begin
          inj = scn.gets_one
          inj = inj.injection
          x = inj.lookup_softly sym
          x && break
        end until scn.no_unparsed_exists
        if x
          OperatorFound__[ inj.injector, x, sym ]
        elsif @argument_scanner.can_fuzzy
          __fuzzy_lookup_operator
        else
          self._COVER_ME__easy_probably__
        end
      end

      def __fuzzy_lookup_operator
        a = __all_fuzzily_matching_operators_found
        case 1 <=> a.length
        when 0  # when found
          a.fetch 0
        when 1  # when not found
          Zerk_lib_[]::ArgumentScanner::When::Unknown_operator[ self ]
        else  # when ambiguous
          _scn = Scanner_via_Array.call a do |of|
            of.load_ticket.intern  # [#ze-062]
          end
          Ambiguous__[ _scn, :_operator_, @argument_scanner ]
        end
      end

      def __all_fuzzily_matching_operators_found
        a = []
        rx = @argument_scanner.current_operator_as_matcher
        scn = to_operator_load_ticket_scanner
        until scn.no_unparsed_exists
          if rx =~ scn.head_as_is.intern  # honor [#062]
            a.push scn.to_found
          end
          scn.advance_one
        end
        a
      end

      def dereference_operator sym
        ::Symbol === sym or raise ::TypeError
        # (because we never make an index of all operators across all injections)
        scn = to_operators_injections_scanner
        begin
          injn = scn.gets_one.injection
          user_x = injn.lookup_softly sym
          user_x && break
          redo
        end while above
        OperatorFound__[ injn.injector, user_x, sym ]
      end

      def to_operator_load_ticket_scanner
        OperatorLoadTicketScanner___.define do |o|
          yield o if block_given?
          o.injections = to_operators_injections_scanner
        end
      end

      def to_operator_symbol_scanner
        to_operators_injections_scanner.expand_by do |injt|
          injt.injection.to_load_ticket_scanner
        end
      end

      def to_operators_injections_scanner
        Scanner_via_Array.new @_operators_injections
      end

      def flush_to_parse_primaries

        # if there are any tokens remaining on the scanner,
        # parse them as primaries or whine appropriately

        args = @argument_scanner
        if args.no_unparsed_exists
          ACHIEVED_
        else
          ok = args.parse_primary
          if ok
            flush_to_lookup_current_and_parse_remaining_primaries
          else
            ok
          end
        end
      end

      def flush_to_lookup_current_and_parse_remaining_primaries

        # assume grammar has primaries, and one primary is parsed and on deck
        ok = false
        begin
          o = lookup_current_primary_symbol_semi_softly
          o.had_unrecoverable_error_which_was_expressed && break
          if ! o.was_found
            __whine_about_primary_not_found
            break
          end
          _injn = @_primaries_injections.fetch( o._inj_d_ ).injection
          parsed_OK = _injn._parse_found_feature_ o  # EXPERIMENT
          if ! parsed_OK
            ok = parsed_OK ; break
          end
          if @argument_scanner.no_unparsed_exists
            ok = true
            break
          end
          @argument_scanner.parse_primary ? redo : break
        end while above
        ok
      end

      # some of the below for #nodeps-coverpoint-3

      def lookup_current_primary_symbol_semi_softly  # #here-1

        # assume grammar has primaries and one primary is parsed and on deck
        # result is always of a tuple strain:
        #   `had_unrecoverable_error_which_was_expressed` t/f (currently for ambiguous only)
        #   if above,
        #     this is the only case where something is expressed (not soft, hence semi-soft)
        #   otherwise
        #     `was_found` t/f
        #     if found,
        #       `trueish_mixed_user_value`, `primary_symbol`

        k = @argument_scanner.current_primary_symbol
        tuple = __THREEPLE_via_lookup_primary_softly_via_symbol k
        if tuple
          _primary_found_via_THREEPLE tuple
        else
          __when_primary_not_found_by_exact_match
        end
      end

      def __when_primary_not_found_by_exact_match  # #here-1
        a = @argument_scanner.
          _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_(
            __to_primary_TWOPLE_scanner )
        case 1 <=> a.length
        when 0  # when exactly one found
          inj_offset, load_ticket = a.fetch 0
          _x = @_primaries_injections.fetch( inj_offset ).
            injection.dereference load_ticket
          _three = [ inj_offset, load_ticket.intern, _x ]
          _primary_found_via_THREEPLE _three
        when 1  # when none found
          NOT_FOUND___
        when -1  # when ambiguous
          _scn = Scanner_via_Array.new( a ).map_by() { |two| two.last.intern }
          Ambiguous__[ _scn, :_primary_, @argument_scanner ]
          UNRECOVERABLE___
        end
      end

      module NOT_FOUND___ ; class << self
        def was_found ; false end
        def had_unrecoverable_error_which_was_expressed ; false end
      end ; end

      module UNRECOVERABLE___ ; class << self
        def had_unrecoverable_error_which_was_expressed ; true end
      end end

      def _primary_found_via_THREEPLE three  # #here-1
        # convert our nasty internal tuple to something external-friendly
        PrimaryFound___.new( * three )
      end

      def injector_via_primary_found found  # see [#060.A.2]
        @_primaries_injections.fetch( found._inj_d_ ).injection.injector
      end

      class PrimaryFound___
        def initialize d, k, x
          @_inj_d_ = d ; @trueish_mixed_user_value = x ; @primary_symbol = k
        end
        attr_reader :_inj_d_, :trueish_mixed_user_value, :primary_symbol
        def was_found ; true end
        def had_unrecoverable_error_which_was_expressed ; false end
      end

      def __whine_about_primary_not_found
        _avail_prim_scn = to_primary_symbol_scanner
        When_primary_not_found___[ _avail_prim_scn, @argument_scanner ]
      end

      # -- read primaries

      # :#here-1: [#here.A] full justification of the "THREEPLE"

      def __THREEPLE_via_lookup_primary_softly_via_symbol k

        scn = _to_primaries_injections_offset_scanner
        until scn.no_unparsed_exists
          offset = scn.gets_one
          _inj = @_primaries_injections.fetch( offset ).injection
          user_x = _inj.lookup_softly k
          if user_x
            x = [ offset, k, user_x ]
            break
          end
        end
        x
      end

      def to_primary_symbol_scanner  # assume
        _to_primaries_injections_offset_scanner.expand_by do |d|
          @_primaries_injections.fetch( d ).injection.to_load_ticket_scanner
        end
      end

      def __to_primary_TWOPLE_scanner

        _to_primaries_injections_offset_scanner.expand_by do |d|

          _inj = @_primaries_injections.fetch( d ).injection

          _inj.to_load_ticket_scanner.map_by do |load_ticket|

            [ d, load_ticket.intern ]  # :#here-1
          end
        end
      end

      def _to_primaries_injections_offset_scanner

        # give priority to those primaries injected most recently, so that
        # this still behaves the way it did when we indexed every primary
        # into a single hash.
        countdown = @_offset_of_last_primary_injection + 1
        Scanner_by.new do
          if countdown.nonzero?
            countdown -= 1
          end
        end
      end

      # --

      attr_reader(
        :argument_scanner,
        :has_operators,
        :has_primaries,
      )
    end

    Ambiguous__ = -> sym_scn, which, argument_scanner do
      case which
      when :_operator_
        ick_m, good_m, curr_m = :ick_oper, :oper, :current_operator_symbol
      when :_primary_
        ick_m, good_m, curr_m = :ick_prim, :prim, :current_primary_symbol
      end
      k = argument_scanner.send curr_m
      # (or load [ze] for this instead:)
      argument_scanner.no_because do |y|
        _scn = sym_scn.map_by { |sym| send good_m, sym }
        y << "ambiguous primary #{ send ick_m, k } - #{
          }did you mean #{ oxford_or _scn }?"
      end
    end

    ScannerMethods__ = ::Module.new

    class OperatorLoadTicketScanner___ < SimpleModel
      include ScannerMethods__

      # a custom scanner that traverses over all operators of all
      # injections, exposing the current injection at any point

      def initialize
        @big_step_pass_filter = nil
        yield self
        @current_injection = @head_as_is = nil
        advance_big
      end

      attr_writer(
        :injections,
        :big_step_pass_filter,
      )

      def advance_one
        send @_advance
      end

      def advance_big
        if @injections.no_unparsed_exists
          remove_instance_variable :@injections
          remove_instance_variable :@_advance
          @no_unparsed_exists = true
          remove_instance_variable :@head_as_is
          remove_instance_variable :@current_injection
          freeze ; nil
        else
          injection = @injections.gets_one.injection
          load_tickets = injection.to_load_ticket_scanner
          if load_tickets.no_unparsed_exists
            advance_big
          else
            @current_injection = injection
            if ( ! @big_step_pass_filter ) || @big_step_pass_filter[ self ]
              @_load_tickets = load_tickets
              @_advance = :_advance_small
              _advance_small
            else
              @_advance = nil
              advance_big
            end
          end
        end
      end

      def _advance_small
        @head_as_is = @_load_tickets.gets_one
        if @_load_tickets.no_unparsed_exists
          remove_instance_variable :@_load_tickets
          @_advance = :advance_big ; nil
        end
      end

      def to_found
        _mixed_business_value = @current_injection.dereference @head_as_is
        OperatorFound__[ @current_injection.injector, _mixed_business_value, @head_as_is ]
      end

      attr_reader(
        :current_injection,
        :head_as_is,
        :no_unparsed_exists,
      )
    end

    OperatorFound__ = ::Struct.new :injector, :mixed_business_value, :load_ticket

    # --

    LazyFeaturesInjectionTicket__ = ::Class.new
    class LazyOperatorsInjectionTicket___ < LazyFeaturesInjectionTicket__
      def _realization_class_
        LazyOperatorsInjectionRealized___
      end
    end
    class LazyPrimariesInjectionTicket___ < LazyFeaturesInjectionTicket__
      def _realization_class_
        LazyPrimariesInjectionRealized___
      end
    end
    class LazyFeaturesInjectionTicket__
      def initialize p
        @_injection = :__injection_initially
        @__proc = p
      end
      def injection
        send @_injection
      end
      def __injection_initially
        _p = remove_instance_variable :@__proc
        @__injection = _realization_class_.define( & _p )
        @_injection = :__injection_normally
        freeze
        send @_injection
      end
      def __injection_normally
        @__injection
      end
    end
    LazyFeaturesInjectionRealized__ = ::Class.new SimpleModel
    class LazyOperatorsInjectionRealized___ < LazyFeaturesInjectionRealized__
      def operators= fz
        @_substrate_adapter_ = fz
      end
    end
    class LazyPrimariesInjectionRealized___ < LazyFeaturesInjectionRealized__
      def primaries= fz
        @_substrate_adapter_ = fz
      end
    end
    class LazyFeaturesInjectionRealized__
      attr_writer :parse_by
      attr_accessor :injector

      def _parse_found_feature_ o
        @parse_by[ o ]
      end

      def lookup_softly k
        @_substrate_adapter_.lookup_softly k
      end
      def to_load_ticket_scanner
        Scanner_by.new( & @_substrate_adapter_.to_load_ticket_stream )
      end
      def dereference k
        @_substrate_adapter_.dereference k
      end
    end

    class HashBasedFeaturesInjection__
      def initialize h, inj
        @_hash = h
        @injector = inj
      end
      def _parse_found_feature_ o  # experiment
        @injector.send o.trueish_mixed_user_value
      end
      def injection
        self
      end
      def lookup_softly k
        @_hash[ k ]
      end
      def to_load_ticket_scanner
        Scanner_via_Array[ @_hash.keys ]
      end
      def dereference k
        @_hash.fetch k
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

    When_primary_not_found___ = -> avail_prim_scn, args do
      k = args.current_primary_symbol
      args.no_because do |y|
        _scn = avail_prim_scn.map_by { |sym| prim sym }
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

    class Scanner_via_Array ; include ScannerMethods__

      class << self
        def call d=nil, a, & p
          scn = new d, a
          if block_given?
            MappedScanner__.new p, scn
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

      def head_as_is
        @_array.fetch @_pos
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    class MappedScanner__ ; include ScannerMethods__

      def initialize p, scn
        @_proc = p
        @_scn = scn
      end

      def no_unparsed_exists
        @_scn.no_unparsed_exists
      end

      def head_as_is  # ..
        @_proc[ @_scn.head_as_is ]
      end

      def advance_one
        @_scn.advance_one
      end
    end

    class Scanner_by ; include ScannerMethods__
      def initialize & p
        x = p.call  # same as `.gets` but more flexible here :[#060.1]
        if x
          @__current_token = x
          @_current_token = :__current_token_normally
          @_stream = p
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
      def head_as_is
        send @_current_token
      end
      def __current_token_normally
        @__current_token
      end
      attr_reader(
        :no_unparsed_exists,
      )
    end

    module ScannerMethods__

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

      def concat_scanner tail_scn
        if no_unparsed_exists
          tail_scn
        elsif tail_scn.no_unparsed_exists
          self
        else
          # (we haven't generalized this for N scanners yet for lack of interest)
          concat_by = -> scn, & after do
            -> do
              x = scn.gets_one
              if scn.no_unparsed_exists
                after[]
              end
              x
            end
          end
          p = concat_by.call self do
            p = concat_by.call tail_scn do
              p = -> { NIL }  # EMPTY_P_
            end
          end
          Scanner_by.new() { p[] }
        end
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
            scn.gets_one
          end
        end
        p = advance
        Scanner_by.new(){ p[] }
      end

      def map_by & p
        MappedScanner__.new p, self
      end

      def to_minimal_stream
        MinimalStream___.new do
          unless no_unparsed_exists
            gets_one
          end
        end
      end

      def gets_one
        x = head_as_is
        advance_one
        x
      end
    end

    class MinimalStream___ < ::Proc ; alias_method :gets, :call ; end

    # ==

    class MagneticBySimpleModel
      class << self
        def call_by & p
          define( & p ).execute
        end
      end  # >>
    end

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

    Zerk_lib_ = Lazy.call do
      require 'skylab/zerk'
      ::Skylab::Zerk
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
# #tombstone: (temporary) used to close primaries
