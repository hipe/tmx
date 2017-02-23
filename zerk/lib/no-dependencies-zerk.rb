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

      def emission_proc_and_channel p, chan
        @channel = chan ; @emission_proc = p ; nil
      end

      attr_writer(
        :client,  # for `data`, `resource`, reaching expag, `stderr`
        :expression_agent_by,
        :resource_by,
        :signal_by,
        :stderr,
      )

      def initialize
        @client = nil
        @expression_agent_by = nil
        @resource_by = nil
        @stderr = nil
        yield self
        # (but don't freeze)
      end

      def execute
        method_name = nil
        FIRST_CHANNEL___.fetch( @channel.fetch 0 )[ binding ]  # highly #experimental
        send method_name
      end

      def express_normally
        if :expression == @channel.fetch(1)
          __express_expression
          _flush_result
        else
          __express_event
          _flush_result
        end
      end

      FIRST_CHANNEL___ = {
        data: -> bnd do
          bnd.local_variable_set :method_name, :__when_data
        end,
        error: -> bnd do
          bnd.local_variable_set :method_name, :express_normally
          bnd.receiver.instance_variable_set :@_was_error, true
        end,
        info: -> bnd do
          bnd.local_variable_set :method_name, :express_normally
          bnd.receiver.instance_variable_set :@_was_error, false
        end,
        resource: -> bnd do
          bnd.local_variable_set :method_name, :__when_resource
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

      def __when_resource
        p = @resource_by
        rsc = if p
          p[ * @channel[1..-1], & @emission_proc ]
        else
          @client.receive_resource_request @emission_proc, @channel
        end
        if rsc
          WrappedResource___[ rsc ]
        else
          rsc
        end
      end
      WrappedResource___ = ::Struct.new :resource do
        def has_resource
          true
        end
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
        elsif @client and @client.respond_to? :expression_agent
          @client.expression_agent
        else
          CLI_InterfaceExpressionAgent.instance
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

      def _flush_result
        Result___.new remove_instance_variable :@_was_error
      end

      Result___ = ::Struct.new :was_error do
        def has_resource
          false
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

      def scan_operator_symbol_softly
        s = head_as_is
        if OPERATOR_RX___ =~ s
          _ = s.gsub( DASH_, UNDERSCORE_ ).intern
          send ( @_write_COS_ ||= :_write_COS_initially ), _
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

      def scan_primary_symbol  # exactly as [#ze-052.1] canon
        if scan_primary_symbol_softly
          ACHIEVED_
        else
          __when_malformed_primary
        end
      end

      def scan_primary_symbol_softly
        @_write_CPS_ ||= :_write_CPS_initially
        md = PRIMARY_RX__.match head_as_is
        if md
          _ = md[ 1 ].gsub( DASH_, UNDERSCORE_ ).intern
          send @_write_CPS_, _
          advance_one
          ACHIEVED_
        elsif @default_primary_symbol
          # #not-covered - blind faith
          send @_write_CPS_, @default_primary_symbol
          ACHIEVED_
        else
          NIL  # #nodeps-coverpoint-2
        end
      end

      def head_looks_like_optional_argument  # assume no empty
        PRIMARY_RX__ !~ head_as_is
      end

      PRIMARY_RX__ = /\A--?([a-z0-9]+(?:-[a-z0-9]+)*)\z/i

      def __receive_corrected_primary_normal_symbol sym
        remove_instance_variable :@_CPS_ ; @_CPS_ = sym ; nil
      end

      # --

      def _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_ scn  # #TWOPLE
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

      def head_as_is
        @_array.fetch @_current_index
      end

      attr_reader(
        :has_current_primary_symbol,
        :is_closed,
        :listener,
        :no_unparsed_exists,
      )

      def can_optional_argument
        true
      end

      def can_fuzzy
        true
      end
    end

    # ==

    InterfaceExpressionAgent__ = ::Class.new  # forward declaration

    class CLI_InterfaceExpressionAgent < InterfaceExpressionAgent__

      def ick_oper sym
        oper( sym ).inspect
      end

      def ick_prim sym
        prim( sym ).inspect
      end

      def ick_mixed x
        x.inspect
      end

      def oper sym
        sym.id2name.gsub UNDERSCORE_, DASH_
      end

      def prim sym
        "-#{ oper sym }"
      end

      def em s  # (typically used in tests)
        # near #open [#ts-005] redundant these, maybe move to here
        "\e[1;32m#{ s }\e[0m"
      end

      # -- not doing anything for these, legacy compat for now

      def pth s  # (needed by [#ts-008.4])
        s
      end
    end

    # = API life

    class API_ArgumentScanner

      include ArgumentScannerMethods__

      def initialize a, & l
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

      def scan_operator_symbol_softly
        scan_operator_symbol  # (see)
      end

      def scan_primary_symbol_softly
        scan_primary_symbol  # (see)
      end

      def scan_operator_symbol
        # (under API, we don't check if it's a symbol :#here-2 but we could)
        send ( @_write_COS_ ||= :_write_COS_initially ), head_as_is
        advance_one
        ACHIEVED_
      end

      def scan_primary_symbol
        # (under API, we don't check if it's a symbol but we could)
        send ( @_write_CPS_ ||= :_write_CPS_initially ), head_as_is
        advance_one
        ACHIEVED_
      end

      def _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_ _
        # assume: a `current_primary_symbol` with no exact match
        LENGTH_ZERO___
      end

      module LENGTH_ZERO___ ; class << self ; def length ; 0 end end end

      def _fuzzy_lookup_primary_or_fail h
        When_primary_not_found__[ h, self ]
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
        :has_current_primary_symbol,
        :listener,
        :no_unparsed_exists,
      )

      def can_optional_argument
        false
      end

      def can_fuzzy
        false
      end
    end

    # ==

    class API_InterfaceExpressionAgent < InterfaceExpressionAgent__

      def ick_oper sym
        _same sym
      end

      def ick_prim sym
        _same sym
      end

      def ick_mixed x
        x.inspect  # ..
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

      def em s
        "*#{ s }*"
      end

      # -- not doing anything for these, legacy compat for now

      def pth s  # (needed by [#ts-008.4])
        s
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
          simple_inflection do
            y << "required: #{ oxford_join "", _scn, " and " }"
          end
        end
        UNABLE_
      end

      main[]
    end

    class ParseArguments_via_FeaturesInjections < SimpleModel  # "omni branch"

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

      def add_operators_injection_by & p
        _inj = LazyOperatorsInjectionRealized__.define( & p )
        _add_operators_injection WrapInjection___.new _inj
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

      def parse_operator

        # the hierarchy is `parse` (which calls `lookup` (which calls `scan`))

        if @argument_scanner.no_unparsed_exists
          Zerk_lib_[]::ArgumentScanner::When::No_arguments[ self ]

        elsif scan_operator_symbol_softly
          flush_to_lookup_operator

        else
          # (assume this will never hit API while #here-2)
          when_malformed_primary_or_operator
        end
      end

      def scan_operator_symbol_softly
        @argument_scanner.scan_operator_symbol_softly
      end

      def scan_primary_symbol_softly
        @argument_scanner.scan_primary_symbol_softly
      end

      def flush_to_lookup_operator  # assume:

        #  - assume `scan_operator_symbol_softly` succeeds
        #  - assume there are some operators injections
        #
        #  result is a "found tuple" if found, and FOR NOW
        #  on failure we emit here and result in false.

        sym = @argument_scanner.current_operator_symbol
        scn = to_operators_injections_scanner

        begin
          inj = scn.gets_one
          inj = inj.injection
          trueish_item_value = inj.lookup_softly sym
        end until trueish_item_value || scn.no_unparsed_exists

        if trueish_item_value
          OperatorFound__[ inj.injector, trueish_item_value, sym ]
        elsif @argument_scanner.can_fuzzy
          __fuzzy_lookup_operator
        else
          _when_operator_not_found  # :[#008.4] #borrow-coverage from [pl]
        end
      end

      def __fuzzy_lookup_operator
        a = __all_fuzzily_matching_operators_found
        case 1 <=> a.length
        when 0  # when found
          a.fetch 0
        when 1  # when not found
          _when_operator_not_found
        else  # when ambiguous
          _scn = Scanner_via_Array.call a do |of|
            of.load_ticket.intern  # [#ze-062]
          end
          Ambiguous__[ _scn, :_operator_, @argument_scanner ]
        end
      end

      def _when_operator_not_found
        Zerk_lib_[]::ArgumentScanner::When::Unknown_operator[ self ]
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
          trueish_item_value = injn.lookup_softly sym
          trueish_item_value && break
          redo
        end while above
        trueish_item_value || self._SANITY
        OperatorFound__[ injn.injector, trueish_item_value, sym ]
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
          ok = args.scan_primary_symbol
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
          _injn = @_primaries_injections.fetch( o.injection_offset ).injection
          parsed_OK = _injn._parse_found_feature_ o  # EXPERIMENT
          if ! parsed_OK
            ok = parsed_OK ; break
          end
          if @argument_scanner.no_unparsed_exists
            ok = true
            break
          end
          @argument_scanner.scan_primary_symbol ? redo : break
        end while above
        ok
      end

      # some of the below for #nodeps-coverpoint-3

      def lookup_current_primary_symbol_semi_softly

        # assume grammar has primaries and one primary is parsed and on deck
        # result is always of a tuple strain:
        #   `had_unrecoverable_error_which_was_expressed` t/f (currently for ambiguous only)
        #   if above,
        #     this is the only case where something is expressed (not soft, hence semi-soft)
        #   otherwise
        #     `was_found` t/f
        #     if found,
        #       [primary found structure]

        k = @argument_scanner.current_primary_symbol
        pf = __primary_found_via_lookup_primary_softly_via_symbol k
        if pf
          pf
        else
          __when_primary_not_found_by_exact_match
        end
      end

      def __when_primary_not_found_by_exact_match
        a = @argument_scanner.
          _all_fuzzily_matching_primary_TWOPLES_by_TWOPLE_scanner_(
            __to_primary_TWOPLE_scanner )
        case 1 <=> a.length
        when 0  # when exactly one found
          __when_found_exactly_one_thru_fuzzy( * a.fetch(0) )
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

      def __when_found_exactly_one_thru_fuzzy inj_offset, correct_k

        ::Symbol === correct_k || self._RETHINK  # #todo

        @argument_scanner.__receive_corrected_primary_normal_symbol correct_k

        _ob = @_primaries_injections.fetch( inj_offset ).injection

        _some_trueish_item_value = _ob.dereference correct_k

        PrimaryFound__.define do |o|
          o.injection_offset = inj_offset
          o.primary_symbol = correct_k
          o.trueish_item_value = _some_trueish_item_value
        end
      end

      def injector_via_primary_found found  # see [#060.A.2]
        @_primaries_injections.fetch( found.injection_offset ).injection.injector
      end

      def __whine_about_primary_not_found
        _avail_prim_scn = to_primary_symbol_scanner
        When_primary_not_found___[ _avail_prim_scn, @argument_scanner ]
      end

      # -- read primaries

      def __primary_found_via_lookup_primary_softly_via_symbol k

        scn = _to_primaries_injections_offset_scanner
        until scn.no_unparsed_exists
          offset = scn.gets_one
          _inj = @_primaries_injections.fetch( offset ).injection
          trueish_item_value = _inj.lookup_softly k
          trueish_item_value || next
          pf = PrimaryFound__.define do |o|
            o.injection_offset = offset
            o.primary_symbol = k
            o.trueish_item_value = trueish_item_value
          end
          break
        end
        pf
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

            [ d, load_ticket.intern ]  # :#TWOPLE
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
        noun, ick_m, good_m, curr_m = "operator", :ick_oper, :oper, :current_operator_symbol
      when :_primary_
        noun, ick_m, good_m, curr_m = "primary", :ick_prim, :prim, :current_primary_symbol
      end

      k = argument_scanner.send curr_m

      argument_scanner.no_because do |y|

        buff = "did you mean "

        simple_inflection do
          oxford_join buff, sym_scn, " or " do |sym|
            send good_m, sym
          end
        end

        y << "ambiguous primary #{ send ick_m, k } - #{ buff }?"
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
        LazyOperatorsInjectionRealized__
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
    class LazyOperatorsInjectionRealized__ < LazyFeaturesInjectionRealized__
      def operators= fz
        @_substrate_adapter_ = fz
      end
    end
    class LazyPrimariesInjectionRealized___ < LazyFeaturesInjectionRealized__
      def primaries= fz
        @_substrate_adapter_ = fz
      end
    end
    WrapInjection___ = ::Struct.new :injection

    class LazyFeaturesInjectionRealized__

      attr_writer :parse_by
      attr_accessor :injector

      def _parse_found_feature_ o
        @parse_by[ o ]
      end

      def lookup_softly k  # #[#ze-051.1] "trueish item value"
        @_substrate_adapter_.lookup_softly k
      end

      def to_load_ticket_scanner
        Scanner_by.new( & @_substrate_adapter_.to_load_ticket_stream )
      end

      def load_ticket_via_symbol sym
        @_substrate_adapter_.load_ticket_via_symbol sym
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
        @injector.send o.trueish_item_value
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
      def load_ticket_via_symbol k
        k
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

      # -- higher-level parsers

      def parse_argument_via_regexp rx, & msg  # #experiment [ts]
        map_trueish_value_by do |x|
          md = rx.match x
          if md
            advance_one ; md
          else
            @LAST_REGEXP = rx
            no_because( & msg )
            remove_instance_variable :@LAST_REGEXP
            UNABLE_
          end
        end
      end

      def scan_glob_values  # currently nothing fancy. maybe one day CLI etc
        map_value_by do |x|
          if ::Array.try_convert x  # remove at [#008.2] on stack
            self._THIS_HAS_CHANGED__if_its_glob_just_pass_a_single_value_at_a_time__
          end
          advance_one ; [ x ]
        end
      end

      def scan_flag_value  # currently if a flag is mentioned, it's true. maybe one day etc
        Zerk_lib_[]::Common_::KnownKnown.trueish_instance
      end

      def parse_trueish_primary_value  # as in `parse_primary_value`. :[#008.3] #borrow-coverage from [ts]

        map_trueish_value_by do |x|
          advance_one ; x
        end
      end

      def map_trueish_value_by
        map_value_by do |x|
          if x
            yield x
          else
            no_because { "{{ prim }} must be trueish (had #{ x.inspect })" }
          end
        end
      end

      def map_value_by
        if no_unparsed_exists
          no_because { "{{ prim }} requires an argument" }
        else
          yield head_as_is
        end
      end

      # -- lower-level parsing and reading

      def _write_COS_initially sym
        @_read_COS_ = :__read_COS_normally
        @_write_COS_ = :__write_COS_normally
        send @_write_COS_, sym
      end

      def _write_CPS_initially sym
        @has_current_primary_symbol = true
        @_read_CPS_ = :__read_CPS_normally
        @_write_CPS_ = :__write_CPS_normally
        send @_write_CPS_, sym
      end

      def current_operator_symbol
        send ( @_read_COS_ ||= :__read_COS_initially )
      end

      def current_primary_as_ivar
        :"@#{ current_primary_symbol }"
      end

      def current_primary_symbol
        send ( @_read_CPS_ ||= :__read_CPS_initially )
      end

      def __read_COS_initially
        raise _not_in_that_state 'current_operator_symbol'
      end

      def __read_CPS_initially
        raise _not_in_that_state 'current_primary_symbol'
      end

      def _not_in_that_state s
        raise ScannerIsNotInThatState, "cannot read `#{ s }` from beginning state"
      end

      def __write_COS_normally sym
        @_COS_ = sym ; nil
      end

      def __write_CPS_normally sym
        @_CPS_ = sym ; nil
      end

      def __read_COS_normally
        @_COS_
      end

      def __read_CPS_normally
        @_CPS_
      end

      # -- emission support

      def no_because *channel_tail, & msg_p
        if channel_tail.length.zero?
          channel_tail.push :primary_parse_error
        end
        _the_best_expresser_ever msg_p, :error, :expression, * channel_tail
        UNABLE_
      end

      def express_info * channel_tail, & msg_p
        _the_best_expresser_ever msg_p, :info, :expression, * channel_tail
        NIL
      end

      def _the_best_expresser_ever msg_p, * channel

        scn = self
        @listener.call( * channel ) do |y|

          map = -> sym do
            case sym
            when :prim
              prim scn.current_primary_symbol
            when :ick
              ick_mixed scn.head_as_is
            else never
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

        NIL
      end
    end

    When_primary_not_found___ = -> avail_prim_scn, args do

      k = args.current_primary_symbol

      args.no_because :primary_parse_error, :primary_not_found do |y|

        y << "unknown primary #{ ick_prim k }"

        simple_inflection do

          _ = oxford_join "", avail_prim_scn, " and " do |sym|
            prim sym
          end

          y << "#{ n "available primary" }: #{ _ }"
        end
      end
    end

    class InterfaceExpressionAgent__  # theory at [#040]

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end

      alias_method :calculate, :instance_exec

      def simple_inflection & p
        o = dup
        o.extend Zerk_lib_[].lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end
    end

    class PrimaryFound__ < SimpleModel  # structure backstory at [#here.A]
      attr_accessor(
        :injection_offset,
        :primary_symbol,
        :trueish_item_value,
      )
      def was_found ; true end
      def had_unrecoverable_error_which_was_expressed ; false end
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

    ScannerIsNotInThatState = ::Class.new ::RuntimeError

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
# :#tombstone-B: no more `emission_handler_methods`
# #tombstone: (temporary) used to close primaries
