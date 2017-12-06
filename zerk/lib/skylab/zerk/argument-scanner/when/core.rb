module Skylab::Zerk

  module ArgumentScanner

    When = ::Module.new

    module WhenScratchSpace____

      When::Ambiguous = -> found_a, omni, type do

        case type
        when :_operator_
          noun, ick_m, good_m = 'operator', :ick_oper_via_head_as_is_, :oper
        when :_primary_
          noun, ick_m, good_m = 'primary', :ick_prim_via_head_as_is_, :prim
        end

        nar = omni.argument_scanner_narrator
        x = nar.token_scanner.head_as_is

        nar.no_because :primary_parse_error do |y|

          buff = ::String.new 'did you mean '

          _scn = Scanner_[ found_a ]

          simple_inflection do
            oxford_join buff, _scn, ' or ' do |fo|
              send good_m, fo.feature_match.feature_symbol
            end
          end

          y << "ambiguous #{ noun } #{ send ick_m, x } - #{ buff }?"
        end
      end

      class When::MissingRequireds  # :[#fi-037.5.N]

        def initialize x_a, as

          @operation_path = nil
          @tuples = []

          scn = Scanner_[ x_a ]
          @_scn = scn
          begin
            send PRIMARIES___.fetch( @_scn.gets_one )
          end until scn.no_unparsed_exists
          remove_instance_variable :@_scn

          @client = as
        end

        PRIMARIES___ = {
          missing: :__parse_missing,
          operation_path: :__parse_operation_path,
        }

        def __parse_operation_path
          x = @_scn.gets_one
          @operation_path = ::Array.try_convert( x ) || [x] ; nil
        end

        def __parse_missing
          @tuples.push @_scn.gets_one ; nil
        end

        def execute

          op_path = @operation_path
          tuples = @tuples

          @client.listener.call(
            :error, :expression, :operation_parse_error, :missing_required_arguments
          ) do |y|

            subsequent_say = nil

            say = -> is_plural, subject_s, primary_s do

              _op = ick_prim op_path.last

              say = subsequent_say
              y << "can't #{ _op } without #{ subject_s }. (maybe use #{ primary_s }.)"
            end

            subsequent_say = -> is_plural, subject_s, primary_s do
              y << "also, must have #{ subject_s }. (maybe use #{ primary_s }.)"
            end

            st = Stream_[ tuples ]
            begin
              tuple = st.gets
              tuple || break

              singplur, subject_s, use_keyword, use_what = tuple

              :use == use_keyword || fail

              _moniker = prim use_what

              _is_plural = IS_PLURAL___.fetch singplur  # not used for now but check anyway

              say[ _is_plural, subject_s, _moniker ]
              redo
            end while above
            y
          end

          UNABLE_
        end

        # ==

        IS_PLURAL___ = {
          is_plural: true,
          is_singular: false,
        }

        # ==
      end

      # ==

      When::Argument_value_not_provided = -> argument_scanner do
        # #cover-me

        sym = argument_scanner.current_primary_symbol

        argument_scanner.listener.call(
          :error, :expression, :primary_parse_error, :primary_value_not_provided
        ) do |y|

          if sym
            y << "#{ prim sym } must be followed by an argument"
          else
            y << "expected a value when input ended"
          end
        end
        UNABLE_
      end

      # ==

      When::Argument_scanner_ended_early_via_search = -> sea do

        req = sea.request

        _tcs = {
          primary: :missing_required_primary,
          business_item: :missing_required_argument,
        }.fetch req.shape_symbol

        When::Unknown_branch_item_via_two__[ _tcs, sea ]
      end

      # ==

      When::Unified_whine_via_reasoning = -> rsn, sea do

        p = rsn.behavior_by
        if p
          _user_x = p[ sea.argument_scanner.listener ]
          _user_x    # #todo
        else
          _tcs = rsn.reason_symbol  # terminal channel symbol
          When::Unknown_branch_item_via_two__[ _tcs, sea ]
        end
      end

      # ==

      class When::Unknown_branch_item_via_two__ < Common_::Dyadic

        def initialize sym, search

          @_argument_scanner = search.argument_scanner
          @_request = search.request
          @_shape_symbol = @_request.shape_symbol
          @__terminal_channel_symbol = sym
        end

        def execute

          When::UnknownFeature.call_by do |o|
            @out = o
            __populate_idea
          end
        end

        def __populate_idea

          @out.listener = @_argument_scanner.listener
          @out.shape_symbol = @_shape_symbol
          @out.terminal_channel_symbol = @__terminal_channel_symbol

          if __has_feature_branch
            __populate_splayer
          end

          if @_argument_scanner.no_unparsed_exists
            NOTHING_  # #feature-island #scn-coverpoint-2
          else
            @out.strange_value_by = @_argument_scanner.method :head_as_is
          end

          NIL
        end

        def __has_feature_branch
          ob = @_request.feature_branch
          if ob
            @_feature_branch = ob  # `_store` DEFINITION_FOR_THE_METHOD_CALLED_STORE_
            @out.talker = ob  # sneak this in here
            ACHIEVED_
          end
        end

        def __populate_splayer

          _p = @_argument_scanner.method(
            :available_branch_internable_stream_via_feature_branch )

          ob = @_feature_branch ; sym = @_shape_symbol

          @out.available_item_internable_stream_by = -> do
            _p[ ob, sym ]
          end
          NIL
        end
      end

      # ==

      Simplified__ = ::Class.new

      class When::Unknown_operator < Simplified__

        def initialize omni
          _receive_omni_ omni
        end

        def execute
          me = self
          @listener.call :error, :expression, :parse_error, :unknown_operator do |y|
            o = me.for y, self
            o.__express_unrecognized_operator
            o.__express_splay_of_available_operators
          end
          UNABLE_
        end
      end

      class When::Unknown_primary < Simplified__
        # (jumped into here at #history-A.1 - was When_primary_not_found___)

        def initialize omni
          _receive_omni_ omni
        end

        def execute
          me = self
          @listener.call :error, :expression, :primary_parse_error, :unknown_primary do |y|
            o = me.for y, self
            o.__express_unrecognized_primary
            o.__express_splay_of_available_primaries
          end
          UNABLE_
        end
      end

      class When::No_arguments < Simplified__

        def initialize omni
          _receive_omni_ omni
        end

        def execute
          me = self
          @listener.call :error, :expression, :parse_error, :no_arguments do |y|
            me.for( y, self ).__express_splay_of_available_features
          end
          UNABLE_
        end
      end

      class When::BestExpresserEver < Common_::MagneticBySimpleModel

        def initialize
          @__did_receive_channel_explicitly = false
          @__has_value_match = false
          @__mutex_for_channel = nil
          @_mutex_for_message = nil
          @feature_match = nil
          super
        end

        def value_match= vm
          @__has_value_match = true
          @feature_match = vm.feature_match
          @value_match = vm
        end

        def message_proc= p
          remove_instance_variable :@_mutex_for_message
          @message_proc = p
        end

        def message_template_string= s
          remove_instance_variable :@_mutex_for_message
          @message_proc = -> { s }
        end

        def channel_tail * these
          _will_receive_channel_explicitly
          _accept_channel_tail these ; nil
        end

        def channel= x
          _will_receive_channel_explicitly
          @channel = x
        end

        def _will_receive_channel_explicitly
          remove_instance_variable :@__mutex_for_channel
          @__did_receive_channel_explicitly = true
        end

        attr_accessor(
          :feature_match,
          :argument_scanner_narrator,
        )

        def execute

          # --

          # default the channel to be based on the feature (type), but only
          # iff you didn't get the channel assigned already and you have ..

          _yes = remove_instance_variable :@__did_receive_channel_explicitly
          if ! _yes && @feature_match

            _accept_channel_tail [ @feature_match.parse_error_symbol_ ]
          end

          # --

          msg_p = remove_instance_variable :@message_proc  # or not. this could be re-entrant..
          me = self

          @argument_scanner_narrator.listener.call( * @channel ) do |y|

            map = -> sym do

              case sym

              when :mixed_value
                ick_mixed me._mixed_value

              when :feature
                fm = me.feature_match
                _m = fm.expression_agent_method_
                send _m, fm.feature_symbol

              when :head_as_is
                ick_mixed me.argument_scanner_narrator.token_scanner.head_as_is

              when :mixed_value_CAUTIOUSLY
                ick_mixed_CAUTIOUSLY me._mixed_value

              else ; no
              end
            end

            _y = ::Enumerator::Yielder.new do |line|
              y << ( line.gsub %r(\{\{[ ]*([a-zA-Z_]+)[ ]*\}\}) do
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
        end

        def _accept_channel_tail these
          @channel = [ :error, :expression, * these ] ; nil
        end

        def _mixed_value
          if @__has_value_match
            @value_match.mixed
          else
            @argument_scanner_narrator.token_scanner.value_at @feature_match.offsets
          end
        end
        NIL
      end

      class Simplified__

        class << self
          def call * x_a
            new( * x_a ).execute
          end
          alias_method :[], :call
          private :new
        end  # >>

        def _receive_omni_ omni
          @listener = omni.argument_scanner_narrator.listener
          @omni = omni ; nil
        end

        def for y, expag
          dup.__init_for_expression y, expag
        end

        def __init_for_expression y, expag
          extend SimplifiedExpressionMethods___
          @expression_agent = expag ; @y = y ; self
        end
      end

      module SimplifiedExpressionMethods___

        def __express_unrecognized_operator
          x = @omni.argument_scanner_narrator.token_scanner.head_as_is ; y = @y
          @expression_agent.calculate do
            y << "unrecognized operator: #{ ick_oper_via_head_as_is_ x }"
          end
        end

        def __express_unrecognized_primary
          x = @omni.argument_scanner_narrator.token_scanner.head_as_is ; y = @y
          @expression_agent.calculate do
            y << "unknown primary #{ ick_prim_via_head_as_is_ x }"
          end
        end

        def __express_splay_of_available_features
          o = @omni.features
          y = @y
          if o.has_operators
            if o.has_primaries
              lem = "available operators and primaries"
              scn = _to_operation_and_primary_moniker_scanner
            else
              lem = "available operators"
              scn = _to_operation_moniker_scanner
            end
          else
            lem = "available primaries"
            scn = _to_primary_moniker_scanner
          end
          @expression_agent.calculate do
            simple_inflection do
              _ = oxford_join scn  # (get the number from this)
              y << "#{ n lem }: #{ _ }"  # (use the number here)
            end
          end
        end

        def __express_splay_of_available_operators

          scn = _to_operation_moniker_scanner ; y = @y
          @expression_agent.calculate do
            simple_inflection do
              _ = oxford_join "", scn, " and "
              y << "#{ n "available operators" }: #{ _ }"
            end
          end
        end

        def __express_splay_of_available_primaries

          scn = _to_primary_moniker_scanner ; y = @y
          @expression_agent.calculate do
            simple_inflection do
              _ = oxford_join ::String.new, scn, ' and '
              y << "#{ n 'available primaries' }: #{ _ }"
            end
          end
        end

        def _to_operation_and_primary_moniker_scanner
          _to_operation_moniker_scanner.concat_scanner _to_primary_moniker_scanner
        end

        def _to_operation_moniker_scanner
          _scn = @omni.features.to_operator_symbolish_scanner__
          _map_by_expag_method :oper, _scn
        end

        def _to_primary_moniker_scanner
          _scn = @omni.features.to_primary_symbolish_scanner
          _map_by_expag_method :prim, _scn
        end

        def _map_by_expag_method m, scn
          @expression_agent.calculate do
            scn.map_by do |mixed_loadable_reference|
              send m, mixed_loadable_reference.intern  # respect [#062]
            end
          end
        end
      end

      # ==

      COLON_ = ':'
      COLON_BYTE_ = COLON_.getbyte 0
      DOT_ = '.'

      # ==
      # ==
    end
  end
end
# #history-A.1 (can be temporary) as referenced
# #history: abstracted from the "when" node of the [tmx] map operation
