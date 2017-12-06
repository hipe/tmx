# frozen_string_literal: true

module NoDependenciesZerk

  # freshly abtracted from [cm], officially this is [#060]
  # (those (many) parts having to do with argument scanning are [#052])

  # when you need to make a client that doesn't load a lot of files
  # (like one that turns on coverage testing or similar), this is a
  # single-file implementation of the basics needed to make API & CLI
  #
  # but NOTE [ze] may be loaded to handle the following circumstances:
  #
  #   - to express a parse failure

  #   - [#052.H] local conventions are used.

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

    # = shared life (higher level)

    DEFINITION_FOR_THE_METHOD_CALLED_STORE = -> ivar, x do
      if x
        instance_variable_set ivar, x ; true
      end
    end

    module NarratorMethods  # EXPERIMENT tier [#052.G] five of The N Tiers

    private

      def no_unparsed_exists
        @argument_scanner_narrator.token_scanner.no_unparsed_exists
      end

      def match_operator_shaped_token
        _ = @argument_scanner_narrator.match_operator_shaped_token
        _store_ :@__operator_match_NDZ, _
      end

      def match_primary_shaped_token
        _ = @argument_scanner_narrator.match_primary_shaped_token
        _store_ :@__primary_match_NDZ, _
      end

      def procure_and_process_primary_via_match  # [bs]
        _omni = current_argument_parsing_idioms
        _omni._procure_and_process_primary_via_match release_primary_match
      end

      def procure_operator_via_match
        _om = release_operator_match
        _ = current_argument_parsing_idioms.procure_operator_via_operator_match _om
        _store_ :@__operator_found_NDZ, _
      end

      def look_up_primary_via_match
        _match = release_primary_match
        lu = current_argument_parsing_idioms.unified_lookup_of_primary _match
        if lu.was_found
          @__primary_found_NDZ = lu.feature_found ; true
        else
          @__primary_lookup_NDZ = lu ; false
        end
      end

      def primary_was_ambiguous_or_similar
        _lu = remove_instance_variable :@__primary_lookup_NDZ
        ! _lu.not_found_was_NOT_expressed
      end

      def release_operator_found
        remove_instance_variable :@__operator_found_NDZ
      end

      def current_operator_found  # EXPERIMENT for [br]
        @__operator_found_NDZ
      end

      def release_primary_found
        remove_instance_variable :@__primary_found_NDZ
      end

      def release_operator_match
        remove_instance_variable :@__operator_match_NDZ
      end

      def release_primary_match
        remove_instance_variable :@__primary_match_NDZ
      end

      def when_malformed_primary_or_operator
        @argument_scanner_narrator.__when_malformed_primary_or_operator_
      end

      define_method :_store_, DEFINITION_FOR_THE_METHOD_CALLED_STORE
    end

    class ArgumentParsingIdioms_via_FeaturesInjections < SimpleModel  # ("omni") tier [#052.F] four of The N Tiers

      class << self
        def define
          _fi = FeaturesInjections_via_Definition___.define do |o|
            yield o  # hi.
          end
          new _fi
        end
        private :new
      end

      def redefine  # note [#052.F.2] - used only in testing and here's why
        super  # hi.
      end

      attr_writer(
        :argument_scanner_narrator,
      )

      def initialize fi

        these = fi.__release_things_to_pass_up
        nar = these.argument_scanner_narrator
        sym = these.default_primary_symbol

        # (PRIM_SYM = procure and process primary at head)
        if sym
          @_PRIM_SYM = :__PRIM_SYM_when_default_primary_symbol
          @__primary_match_prototype = PrimaryMatch__.new sym, 0  # NOTE THE MAGIC of the zero-length carbon offset
        else
          @_PRIM_SYM = :__PRIM_SYM_normally
        end

        if nar
          @argument_scanner_narrator = nar
        end

        @features = fi

        freeze
      end

      def procure_operator
        if @argument_scanner_narrator.token_scanner.no_unparsed_exists  # #covered-by [bs]
          Zerk_lib_[]::ArgumentScanner::When::No_arguments[ self ]
        else
          __procure_operator_when_some
        end
      end

      def __procure_operator_when_some
        match = @argument_scanner_narrator.procure_operator_shaped_match
        if match
          procure_operator_via_operator_match match
        end
      end

      def flush_to_find_and_process_this_and_remaining_primaries match

        if _procure_and_process_primary_via_match match
          flush_to_parse_primaries
        end
      end

      def flush_to_parse_primaries

        # parse every of the zero or more remaining tokens as primaries or
        # whine. NOTE this is the only way to reach `default_primary_symbol`

        ok = ACHIEVED_
        scn = @argument_scanner_narrator.token_scanner
        until scn.no_unparsed_exists
          ok = send @_PRIM_SYM
          ok || break
        end
        ok
      end

      def __PRIM_SYM_when_default_primary_symbol  # assume 1. #Coverpoint1.6

        match = @argument_scanner_narrator.match_primary_shaped_token
        if ! match
          match = @__primary_match_prototype.dup
        end
        _procure_and_process_primary_via_match match
      end

      def __PRIM_SYM_normally  # assume 1

        match = @argument_scanner_narrator.procure_primary_shaped_match
        if match
          _procure_and_process_primary_via_match match
        end
      end

      def _procure_and_process_primary_via_match match

        found_primary = __procure_primary_via_match match
        if found_primary
          @features.__process_found_primary_ found_primary, self  # #[#007.H] no advance
        end
      end

      def procure_operator_via_operator_match match
        @argument_scanner_narrator.modality_adapter_scanner.
          _procure_operator_via_shape_match_ match, self
      end

      def __procure_primary_via_match match
        @argument_scanner_narrator.modality_adapter_scanner.
          _procure_primary_via_shape_match_ match, self
      end

      def unified_lookup_of_primary match
        @argument_scanner_narrator.modality_adapter_scanner.
          _unified_lookup_of_primary_ match, self
      end

      attr_reader(
        :features,
        :argument_scanner_narrator,
      )
    end

    class ArgumentScannerNarrator__  # tier [#052.E] three of The N Tiers

      def initialize p, mas
        @listener = p
        @modality_adapter_scanner = mas
        freeze
      end

      # (sections and section contents follow [#052.E.2] proscribed order.)

      # -- `procure_X_after`

      def procure_positive_nonzero_integer_after_feature_match fm
        _procure_via_PLAIN_METHOD_after fm, :__normalize_positive_nonzero_integer
      end

      def procure_non_negative_integer_after_feature_match fm
        _procure_via_PLAIN_METHOD_after fm, :__normalize_non_negative_integer
      end

      def procure_matching_match_after_feature_match rx, fm, & msg_p  # (production: 1x [ts])
        __procure_via_MAP_FILTER_PROC_after fm, msg_p, __regex_map_filter( rx )
      end

      def procure_trueish_match_after_feature_match fm
        __procure_via_IS_after fm, :__is_trueish
      end

      def procure_any_match_after_feature_match fm
        _procure_any_after fm  # hi.
      end

      # -- `procure_X`

      def procure_operator_shaped_match
        _procure_via_match :match_operator_shaped_token
      end

      def procure_primary_shaped_match
        _procure_via_match :match_primary_shaped_token
      end

      # -- `match_X`

      def match_optional_argument_after_feature_match fm
        # (you can't procure an optional argument - it's optinal so you can't fail)
        if token_scanner.has_offset fm.offsets  # so they don't have to
          @modality_adapter_scanner._match_optional_argument_ fm
        end
      end

      def match_operator_shaped_token
        @modality_adapter_scanner._match_operator_shaped_token_
      end

      def match_primary_shaped_token
        @modality_adapter_scanner._match_primary_shaped_token_
      end

      # -- normal normalizers (i.e corral them into one place)

      def __normalize_positive_nonzero_integer vm
        _integer_that( vm ) { |d| 0 < d }
      end

      def __normalize_non_negative_integer vm
        _integer_that( vm ) { |d| 0 <= d }
      end

      def _integer_that vm
        vm = @modality_adapter_scanner._normalize_integer_ vm, self
        if vm
          if yield vm.mixed
            vm
          else
            _base_label = caller_locations( 1, 1 )[ 0 ].base_label  # DIRTY TRICK
            _stem = /\A_*normalize_(.+)_integer\z/.match( _base_label )[1]
            _no_because_value vm do
              "{{ feature }} must be #{ Humanize__[ _stem ] } (had {{ mixed_value }})"
            end
          end
        end
      end

      def __regex_map_filter rx
        -> vm do
          md = rx.match vm.mixed
          if md
            vm.CHANGE_VALUE md
          end
        end
      end

      def __is_trueish vm
        @modality_adapter_scanner._is_trueish_ vm
      end

      # -- support. (see [#052.E.3] normalization categories for methods)

      def __when_malformed_primary_or_operator_  # #covered-by [tmx]
        s = token_scanner.head_as_is
        no_because :feature_parse_error do |y|
          if s.include? UNDERSCORE_ and %r(\A[a-z0-9_]+\z) =~ s
            _hint = " (did you mean #{ s.gsub UNDERSCORE_, DASH_ }?)"
          end
          y << "unknown primary or operator: {{ head_as_is }}#{ _hint }"
        end
      end

      def _procure_via_PLAIN_METHOD_after fm, m
        vm = _procure_any_after fm
        if vm
          send m, vm
        end
      end

      def __procure_via_MAP_FILTER_PROC_after fm, msg_p, map_filter
        vm = _procure_any_after fm
        if vm
          __normal_normalize_for_MAP_FILTER_PROC_after vm, msg_p, map_filter
        end
      end

      def __procure_via_IS_after fm, m
        vm = _procure_any_after fm
        if vm
          __normal_normalize_for_IS_after vm, m
        end
      end

      def _procure_via_match m
        fm = send m
        if fm
          fm
        else
          _no_because_does_not_look_like_feature m
        end
      end

      def _procure_any_after fm
        target_offset = fm.offsets
        ts = token_scanner
        if ts.has_offset target_offset
          ValueMatch__.new ts.value_at( target_offset ), 1, fm
        else
          __no_because_missing_argument fm
        end
      end

      def __normal_normalize_for_IS_after vm, m
        yes = send m, vm
        if yes
          vm
        else
          fm = vm.feature_match
          _moniker = Humanize__[ /\A_*is_/.match( m ).post_match ]
          _msg = "{{ feature }} must be #{ _moniker } (had {{ mixed_value }})"
          no_because_by do |o|
            o.message_template_string = _msg
            o.feature_match = fm
          end
        end
      end

      def __normal_normalize_for_MAP_FILTER_PROC_after vm, msg_p, map_filter
        use_vm = map_filter[ vm ]
        if use_vm
          use_vm
        else
          __no_because_not_valid vm, & msg_p
        end
      end

      def __no_because_not_valid vm, & msg_p
        _no_because_value vm do |o|
          if msg_p
            o.message_proc = msg_p
          else
            o.message_template_string = '{{ mixed_value }} is not a valid {{ feature }}'
          end
        end
      end

      def __no_because_does_not_look_like vm, sym  # compare #here2
        _no_because_value vm do |o|
          o.message_template_string =
            "{{ feature }} does not look like #{ Humanize__[ sym.id2name ] }: {{ mixed_value }}"
        end
      end

      def __no_because_missing_argument fm
        _no_because_feature fm do |o|
          o.message_template_string = '{{ feature }} requires an argument'
        end
      end

      def _no_because_value vm, & p
        no_because_by do |o|
          _same_trick o, p
          o.value_match = vm
          o.channel_tail vm.feature_match.parse_error_symbol_
        end
      end

      def _no_because_feature fm, & p
        no_because_by do |o|
          _same_trick o, p
          o.feature_match = fm
        end
      end

      def _same_trick o, p
        if p.arity.zero?
          o.message_proc = p
        else
          p[ o ]
        end
      end

      def _no_because_does_not_look_like_feature m  # compare #here2
        _no_because_failure_to_match_feature m do |moniker|
          "does not look like #{ moniker }: {{ head_as_is }}"
        end
      end

      def _no_because_end_of_input_for_feature m
        _no_because_failure_to_match_feature m do |moniker|
          "expected #{ moniker } at end of input"
        end
      end

      def _no_because_failure_to_match_feature m
        stem = /\Amatch_([a-z_]+)_shaped_token\z/.match( m )[1]
        no_because :"#{ stem }_parse_error" do  # `operator_parse_error` `primary_parse_error`
          yield Humanize__[ stem ]
        end
      end

      def no_because one, *rest, & msg_p
        no_because_by do |o|
          o.channel_tail one, * rest
          o.message_proc = msg_p
        end
      end

      def no_because_by
        Zerk_lib_[]::ArgumentScanner::When::BestExpresserEver.call_by do |o|
          yield o
          o.argument_scanner_narrator = self
        end
        UNABLE_
      end

      def advance_past_match match
        match._become_accepted_
        case match.offsets
        when 1 ; token_scanner.advance_one
        when 0 ; NOTHING_  # #Coverpoint1.6 - default primary symbol, probably
        when 2 ; token_scanner.advance_this_many 2  # #Coverpoint1.6
        else no
        end
        ACHIEVED_  # convenience
      end

      def token_scanner
        @modality_adapter_scanner.token_scanner
      end

      attr_reader(
        :listener,
        :modality_adapter_scanner,
      )
    end

    # = CLI life

    class CLI_Express_via_Emission < MagneticBySimpleModel

      def emission_proc_and_channel p, chan
        @channel = chan ; @emission_proc = p ; nil
      end

      def initialize
        @client = nil
        @expression_agent_by = nil
        @resource_by = nil
        @stderr = nil
        yield self
        # (but don't freeze)
      end

      attr_writer(
        :client,
        :expression_agent_by,
        :resource_by,
        :signal_by,
        :stderr,
      )

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

    class CLI_ArgumentScanner  # tier [#052.E] two of The N Tiers (two of two)

      class << self
        def narrator_for s_a, & p
          _me = new p, TokenScanner__.new( s_a )
          ArgumentScannerNarrator__.new p, _me
        end
        private :new
      end  # >>

      def initialize p, ts
        @listener = p
        @token_scanner = ts
        freeze
      end

      def _normalize_integer_ vm, nar
        s = vm.mixed
        if %r(\A-?\d+\z) =~ s
          vm.CHANGE_VALUE s.to_i
        else
          nar.__no_because_does_not_look_like vm, :integer
        end
      end

      def _is_trueish_ vm
        vm.mixed.length.nonzero?  # experiment
      end

      def _match_optional_argument_ fm  # assume has offset. counterpart: #[#052.E.3]
        _s = @token_scanner.value_at fm.offsets
        if PRIMARY_RX__ !~ _s
          ValueMatch__.new _s, 1, fm
        end
      end

      def _procure_operator_via_shape_match_ operator_match, omni
        lu = _unified_lookup_of_operator operator_match, omni
        if lu.was_found
          lu.feature_found
        elsif lu.not_found_was_NOT_expressed
          Zerk_lib_[]::ArgumentScanner::When::Unknown_operator[ omni ]
        end
      end

      def _procure_primary_via_shape_match_ primary_match, omni
        lu = _unified_lookup_of_primary_ primary_match, omni
        if lu.was_found
          lu.feature_found
        elsif lu.not_found_was_NOT_expressed
          Zerk_lib_[]::ArgumentScanner::When::Unknown_primary[ omni ]
        end
      end

      def _unified_lookup_of_operator operator_match, omni
        found = omni.features._find_operator_via_shape_match operator_match
        if found
          UnifiedFound__.new found
        else
          _unified_fuzz operator_match, omni, :__find_all_operators_matching_, :_operator_
        end
      end

      def _unified_lookup_of_primary_ primary_match, omni
        found = omni.features._find_primary_via_shape_match primary_match
        if found
          UnifiedFound__.new found
        else
          _unified_fuzz primary_match, omni, :__find_all_primaries_matching_, :_primary_
        end
      end

      def _unified_fuzz match, omni, m, type  # #coverpoint1.4

        _sym_head = match.feature_symbol
        _rx = /\A#{ ::Regexp.escape _sym_head.id2name }/
        a = omni.features.send m, _rx

        case 1 <=> a.length
        when 0  # when found
          UnifiedFound__.new a.fetch 0

        when 1  # when not found
          NOT_FOUND___

        else  # when ambiguous
          Zerk_lib_[]::ArgumentScanner::When::Ambiguous[ a, omni, type ]
          UNRECOVERABLE___
        end
      end

      def _match_operator_shaped_token_  # assume 1
        s = @token_scanner.head_as_is
        if OPERATOR_RX___ =~ s
          OperatorMatch__.new s.gsub( DASH_, UNDERSCORE_ ).intern
        else
          NIL  # #Coverpoint1.1
        end
      end

      OPERATOR_RX___ = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/i

      def _match_primary_shaped_token_  # assume 1
        _s = @token_scanner.head_as_is
        md = PRIMARY_RX__.match _s
        if md
          _ = md[1].gsub( DASH_, UNDERSCORE_ ).intern
          PrimaryMatch__.new _
        else
          NIL  # #coverpoint1.2
        end
      end

      PRIMARY_RX__ = /\A--?([a-z0-9]+(?:-[a-z0-9]+)*)\z/i

      attr_reader(
        :token_scanner,
      )
    end

    class UnifiedFound__
      def initialize fo
        @feature_found = fo
      end
      attr_reader :feature_found
      def was_found
        true
      end
    end

    module UNRECOVERABLE___ ; class << self
      def not_found_was_NOT_expressed ; false end
      def was_found ; false end
    end end

    module NOT_FOUND___ ; class << self
      def not_found_was_NOT_expressed ; true end
      def was_found ; false end
    end ; end

    # ==

    InterfaceExpressionAgent__ = ::Class.new  # forward declaration

    class CLI_InterfaceExpressionAgent < InterfaceExpressionAgent__

      def ick_oper_via_head_as_is_ s
        s.inspect
      end

      def ick_prim_via_head_as_is_ s
        s.inspect
      end

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

      def mixed_primitive s  # (we used to abuse `ick_mixed` for this)
        s.inspect
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

    class API_ArgumentScanner  # tier [#052.E] two of The N Tiers (one of two)

      class << self
        def narrator_for s_a, & p
          _me = new TokenScanner__.new s_a
          ArgumentScannerNarrator__.new p, _me
        end
        private :new
      end  # >>

      def initialize ts
        @token_scanner = ts
        freeze
      end

      def _normalize_integer_ vm, nar  # this is perhaps just a contact exercise ..
        if ::Integer === vm.mixed
          vm
        else  # (in API as opposed to CLI the value could be any object, so cautiously)
          nar._no_because_value vm do
            "{{ feature }} must be integer type (was #{ vm.mixed.class }): {{ mixed_value_CAUTIOUSLY }}"
          end
        end
      end

      def _is_trueish_ vm
        vm.mixed
      end

      def _match_optional_argument_ fm  # assume has offset. see [#052.E.3]
        _x = @token_scanner.value_at fm.offsets
        ValueMatch__.new _x, 1, fm
      end

      def _procure_operator_via_shape_match_ operator_match, omni  # #covered-by [pl]

        found_operator = omni.features._find_operator_via_shape_match operator_match
        if found_operator
          found_operator
        else
          Zerk_lib_[]::ArgumentScanner::When::Unknown_operator[ omni ]
        end
      end

      def _procure_primary_via_shape_match_ primary_match, omni

        found_primary = omni.features._find_primary_via_shape_match primary_match
        if found_primary
          found_primary
        else
          Zerk_lib_[]::ArgumentScanner::When::Unknown_primary[ omni ]  # #covered-by [ts]
        end
      end

      def _match_operator_shaped_token_  # assume 1. #covered-by [pl]
        OperatorMatch__.new @token_scanner.head_as_is
      end

      def _match_primary_shaped_token_  # assume 1
        # (under API, we don't check if it's a symbol but we could)
        PrimaryMatch__.new @token_scanner.head_as_is
      end

      attr_reader(
        :token_scanner,
      )
    end

    # ==

    class API_InterfaceExpressionAgent < InterfaceExpressionAgent__

      def ick_oper_via_head_as_is_ sym  # #experiment
        _same sym
      end

      def ick_prim_via_head_as_is_ sym
        _same sym
      end

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

      def mixed_primitive s  # (we used to abuse `ick_mixed` for this)
        s.inspect
      end

      def em s
        "*#{ s }*"
      end

      # -- not doing anything for these, legacy compat for now

      def pth s  # (needed by [#ts-008.4])
        s
      end
    end

    # = shared life (again)

    Check_requireds = -> o, ivars, & p do  # [ts], [cm]

      # ultra minimal subset of [#fi-012] normalization. :[#fi-037.5.B]

      when_missing = nil ; missing = nil

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
            y << "required: #{ oxford_join ::String.new, _scn, " and " }"
          end
        end
        UNABLE_
      end

      main[]
    end

    class FeaturesInjections_via_Definition___ < SimpleModel

      def initialize

        @_add_operators_injection = :__add_first_operators_injection
        @_add_primaries_injection = :__add_first_primaries_injection

        @argument_scanner_narrator = nil
        @default_primary_symbol = nil
        @has_operators = false
        @has_primaries = false

        yield self

        if @has_operators
          @operators_injections.freeze
        end
        if @has_primaries
          @primaries_injections.freeze
        end
        remove_instance_variable :@_add_operators_injection
        remove_instance_variable :@_add_primaries_injection
        # freeze #here1
      end

      attr_writer(
        :argument_scanner_narrator,
        :default_primary_symbol,
      )

      def add_hash_based_operators_injection h, injector_sym, injection_sym=nil
        _add_operators_injection HashBasedFeaturesInjection__.new( h, injector_sym, injection_sym )
      end

      def add_primaries_injection h, injector_sym, injection_sym=nil  # (is the counterpart to above)
        _add_primaries_injection HashBasedFeaturesInjection__.new( h, injector_sym, injection_sym )
      end

      def add_lazy_operators_injection_by & p
        _add_operators_injection LazyOperatorsInjectionReference___.new p
      end

      def add_lazy_primaries_injection_by & p
        _add_primaries_injection LazyPrimariesInjectionReference___.new p
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
        @_offset_of_last_operator_injection = -1
        @operators_injections = []
        @_add_operators_injection = :__add_operators_injection_normally
        send @_add_operators_injection, ada
      end

      def __add_first_primaries_injection ada
        @has_primaries = true
        @_offset_of_last_primary_injection = -1
        @primaries_injections = []
        @_add_primaries_injection = :__add_primaries_injection_normally
        send @_add_primaries_injection, ada
      end

      def __add_operators_injection_normally ada
        @_offset_of_last_operator_injection += 1
        @operators_injections.push ada ; nil
      end

      def __add_primaries_injection_normally ada
        @_offset_of_last_primary_injection += 1
        @primaries_injections.push ada ; nil
      end

      def add_injector x, sym
        h = ( @_injector_box ||= {} )
        h.key? sym and fail
        h[ sym ] = x ; nil
      end

      def __release_things_to_pass_up

        x = PassUp___.new(
          remove_instance_variable( :@argument_scanner_narrator ),
          remove_instance_variable( :@default_primary_symbol ),
        )
        freeze  # #here1
        x
      end

      PassUp___ = ::Struct.new(
        :argument_scanner_narrator,
        :default_primary_symbol,
      )

      # -- read

      def TO_FLATTENED_QUALIFIED_FEATURE_SCANNER  # experimental new assist usu for help screens
        Zerk_lib_[]::ArgumentScanner::Magnetics::FlattenedQualifiedFeatureScanner_via_Injections.call_by do |o|
          yield o if block_given?
          o.injections = self
        end
      end

      def __process_found_primary_ found, omni  # #[#007.H] for now, client advances
        _inj_ref = _injection_reference_via_primary_found found
        _br = _inj_ref.injection
        _ok = _br._process_found_primary_ found, omni  # EXPERIMENT
      end

      def injector_via_primary_found found   # [tmx]
        _inj_ref = _injection_reference_via_primary_found found
        @_injector_box.fetch _inj_ref.injector_symbol
      end

      def injection_reference_via_operator_found found  # [tmx]
        @operators_injections.fetch found.injection_offset
      end

      def _injection_reference_via_primary_found found  # [tmx]
        @primaries_injections.fetch found.injection_offset
      end

      def __find_all_operators_matching_ rx

        _scn = _to_operators_injections_offset_scanner_downwards
        _find_all_matching _scn, rx, @operators_injections, OperatorFound__
      end

      def __find_all_primaries_matching_ rx

        _scn = _to_primaries_injections_offset_scanner_downwards
        _find_all_matching _scn, rx, @primaries_injections, PrimaryFound__
      end

      def _find_operator_via_shape_match operator_match

        _scn = _to_operators_injections_offset_scanner_upwards
        _find_via_shape_match(
          _scn, operator_match, @operators_injections, OperatorFound__ )
      end

      def _find_primary_via_shape_match primary_match

        _scn = _to_primaries_injections_offset_scanner_upwards
        _find_via_shape_match(
          _scn, primary_match, @primaries_injections, PrimaryFound__ )
      end

      def _find_all_matching scn, rx, injections, cls
        a = []
        until scn.no_unparsed_exists
          offset = scn.gets_one
          inj_ref = injections.fetch offset
          br = inj_ref.injection

          scn_ = br.to_symbolish_reference_scanner
          until scn_.no_unparsed_exists
            ref = scn_.gets_one
            if rx !~ ref.intern
              next
            end
            _fo = cls.define do |o|
              o.injection_offset = offset
              o.trueish_feature_value = br.dereference ref
              o._match_ = cls.match_class.new ref.intern
            end
            a.push _fo
          end
        end
        a
      end

      def _find_via_shape_match scn, match, injections, cls

        k = match.feature_symbol
        until scn.no_unparsed_exists
          offset = scn.gets_one
          _br = injections.fetch( offset ).injection
          x = _br.lookup_softly k
          x || next
          fo = cls.define do |o|
            o.injection_offset = offset
            o.trueish_feature_value = x
            o._match_ = match
          end
          break
        end
        fo
      end

      def to_operator_symbolish_scanner__  # assume
        _ = _to_injections_scanner _to_operators_injections_offset_scanner_downwards, @operators_injections
        _.expand_by do |inj|
          inj.injection.to_symbolish_reference_scanner
        end
      end

      def to_primary_symbolish_scanner  # assume. [tmx]
        _ = _to_injections_scanner _to_primaries_injections_offset_scanner_downwards, @primaries_injections
        _.expand_by do |inj|
          inj.injection.to_symbolish_reference_scanner
        end
      end

      def _to_injections_scanner scn, a
        scn.map_by do |offset|
          a.fetch offset
        end
      end

      def _to_operators_injections_offset_scanner_downwards
        _to_injections_offset_scanner_downwards @_offset_of_last_operator_injection
      end

      def _to_primaries_injections_offset_scanner_downwards
        _to_injections_offset_scanner_downwards @_offset_of_last_primary_injection
      end

      def _to_operators_injections_offset_scanner_upwards
        _to_injections_offset_scanner_upwards @_offset_of_last_operator_injection
      end

      def _to_primaries_injections_offset_scanner_upwards
        _to_injections_offset_scanner_upwards @_offset_of_last_primary_injection
      end

      def _to_injections_offset_scanner_downwards offset_of_last_injection

        # we want down (as opposed to up) typically for documentation so
        # that the screen order follows the code order of the injections

        current = -1
        Scanner_by.new do
          if current != offset_of_last_injection
            current += 1
          end
        end
      end

      def _to_injections_offset_scanner_upwards offset_of_last_injection

        # we want up (as opposed to down) typically for interpreting input,
        # so that injections added more recently can trump those that came
        # before. (throwback to when we used to index every primary in a
        # common, single hash!)

        countdown = offset_of_last_injection + 1
        Scanner_by.new do
          if countdown.nonzero?
            countdown -= 1
          end
        end
      end

      attr_reader(
        :has_operators,  # #covered-by [tmx]
        :has_primaries,  # SAME
        :_injector_box,
        :operators_injections,
        :primaries_injections,
      )
    end

    class TokenScanner__  # tier [052.C] one of The N Tiers (see)

      def initialize a
        len = a.length
        if len.zero?
          @no_unparsed_exists = true
          freeze
        else
          @_final_offset = len - 1
          @_current_offset = 0
          @_array = a
        end
      end

      def gets_one
        x = head_as_is
        advance_one
        x
      end

      def head_as_is
        @_array.fetch @_current_offset
      end

      def value_at positive_d
        @_array.fetch( positive_d + @_current_offset )
      end

      def advance_this_many n
        n.times do
          advance_one
        end
        NIL
      end

      def advance_one
        if @_final_offset == @_current_offset
          remove_instance_variable :@_array
          remove_instance_variable :@_current_offset
          remove_instance_variable :@_final_offset
          @no_unparsed_exists = true
          freeze
        else
          @_current_offset += 1
        end
        NIL
      end

      def has_offset d  # assume 0 or more
        ( d + @_current_offset ) <= @_final_offset
      end

      def LIQUIDATE_TOKEN_SCANNER  # only while #open [#068] and/or #open [#070]
        remove_instance_variable :@_final_offset
        a = [
          remove_instance_variable( :@_current_offset ),
          remove_instance_variable( :@_array ),
        ]
        freeze
        a
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==

    LazyFeaturesInjectionReference__ = ::Class.new
    class LazyOperatorsInjectionReference___ < LazyFeaturesInjectionReference__
      def _realization_class_
        LazyOperatorsInjectionRealized__
      end
    end
    class LazyPrimariesInjectionReference___ < LazyFeaturesInjectionReference__
      def _realization_class_
        LazyPrimariesInjectionRealized___
      end
    end
    class LazyFeaturesInjectionReference__
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
      attr_accessor :injection_symbol

      def _process_found_primary_ found, omni  # #[#007.H] now, client advances
        if 1 == @parse_by.arity  # meh
          @parse_by[ found ]
        else
          @parse_by[ found, omni ]
        end
      end

      def lookup_softly k  # #[#ze-051.1] "trueish item value"
        @_substrate_adapter_.lookup_softly k
      end

      def dereference ref
        @_substrate_adapter_.dereference ref
      end

      def to_symbolish_reference_scanner
        @_substrate_adapter_.to_symbolish_reference_scanner
      end
    end

    class HashBasedFeaturesInjection__

      # (this is the only f.i that doesn't wrap around a features branch)

      def initialize h, injector_sym, injection_sym

        if injector_sym
          @injector_symbol = injector_sym
        end

        if injection_sym
          @injection_symbol = injection_sym
        end

        @_hash = h
      end

      def _process_found_primary_ found, omni  # experiment

        # here we assume that the right-hand side of the hash is method
        # names to be sent to a regisered "injection receiver"
        # #[#007.H] we do NOT (any longer) advance scanner here (#history-C.1) 

        _receiver = omni.features.injector_via_primary_found found
        _receiver.send found.trueish_feature_value, found
      end

      def injection
        self
      end

      def lookup_softly k
        @_hash[ k ]
      end

      def dereference k
        @_hash.fetch k
      end

      def to_symbolish_reference_scanner
        Scanner_via_Array[ @_hash.keys ]
      end

      attr_reader(
        :injection_symbol,
        :injector_symbol,
      )
    end

    # ==

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

      def ick_mixed_CAUTIOUSLY x
        # because this uses a HUGE stack of dependencies we keep it separate for now
        Zerk_lib_[].lib_.basic::String.via_mixed x
      end

      def humanize sym  # (bringing back this ancient thing)
        sym.id2name.gsub UNDERSCORE_, SPACE_
      end
    end

    class OperatorFound__ < SimpleModel
      attr_accessor(
        :injection_offset,
        :operator_match,
        :trueish_feature_value,
      )
      alias_method :_match_=, :operator_match=
      alias_method :feature_match, :operator_match
      def self.match_class
        OperatorMatch__
      end
    end

    class PrimaryFound__ < SimpleModel  # structure backstory at [#060.A]
      attr_accessor(
        :injection_offset,
        :primary_match,
        :trueish_feature_value,
      )
      alias_method :_match_=, :primary_match=
      alias_method :feature_match, :primary_match
      def self.match_class
        PrimaryMatch__
      end
    end

    Match__ = ::Class.new

    class ValueMatch__ < Match__

      def initialize x, offsets, fm
        @mixed = x
        @feature_match = fm
        super( offsets + fm.offsets )
      end

      def CHANGE_VALUE x
        # (this is a violation, but it's probably harmless)
        @mixed = x ; self
      end

      def _become_accepted_
        @feature_match._become_accepted_
        super
      end

      attr_reader(
        :feature_match,
        :mixed,
      )
    end

    class OperatorMatch__ < Match__
      def initialize sym, offsets=1
        @operator_symbol = sym
        super offsets
      end
      attr_reader :operator_symbol
      alias_method :feature_symbol, :operator_symbol
      def parse_error_symbol_
        :operator_parse_error
      end
      def expression_agent_method_
        :oper
      end
    end

    class PrimaryMatch__ < Match__
      def initialize sym, offsets=1
        @primary_symbol = sym
        super offsets
      end
      attr_reader :primary_symbol
      alias_method :feature_symbol, :primary_symbol
      def parse_error_symbol_
        :primary_parse_error
      end
      def expression_agent_method_
        :prim
      end
    end

    class Match__
      def initialize d
        @__mutex_for_is_accepted = false
        @offsets = d
      end
      def _become_accepted_
        remove_instance_variable :@__mutex_for_is_accepted
        NIL
      end
      def TO_IVAR
        :"@#{ feature_symbol }"
      end
      attr_reader :offsets
    end

    # == support

    ScannerMethods__ = ::Module.new

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
        @_head_as_is = :_head_as_is_when_not_cached
        @_proc = p
        @_scn = scn
      end

      def no_unparsed_exists
        @_scn.no_unparsed_exists
      end

      def head_as_is
        send @_head_as_is
      end

      def _head_as_is_when_not_cached
        x = @_proc[ @_scn.head_as_is ]
        @_head_as_is = :__head_as_is_when_cached
        @__cached_mixed = x
        x
      end

      def __head_as_is_when_cached
        @__cached_mixed
      end

      def advance_one
        @_head_as_is = :_head_as_is_when_not_cached
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

      def flush_to_minimal_stream  # 2x
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

      def redefine  # exacty Common_::SimpleModel::DEFINITION_FOR_THE_METHOD_CALLED_STORE
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

    Humanize__ = -> stem { stem.split( UNDERSCORE_ ).join SPACE_ }

    # ==

    ACHIEVED_ = true
    DASH_ = '-'
    EMPTY_S_ = ''
    NIL  = nil  # #open [#sli-116]
    SPACE_ = ' '
    UNABLE_ = false
    UNDERSCORE_ = '_'

    # ==
  # -
end
# #history-C.1: almost full rewrite for 2nd wave
# :#tombstone-B: no more `emission_handler_methods`
# #tombstone: (temporary) used to close primaries
