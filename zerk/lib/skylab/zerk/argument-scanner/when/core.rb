module Skylab::Zerk

  module ArgumentScanner

    When = ::Module.new

    module WhenScratchSpace____

      class When::MissingRequireds

        def initialize x_a, as

          @operation_path = nil
          @tuples = []

          scn = Common_::Scanner.via_array x_a
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

              _name = Common_::Name.via_variegated_symbol op_path.last   # meh
              _op = say_formal_component_ _name

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

              _name = Common_::Name.via_variegated_symbol use_what

              _moniker = say_primary_ _name

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

        When::Unknown_branch_item_via_two__[ _tcs, sea ].execute
      end

      # ==

      When::Unified_whine_via_reasoning = -> rsn, sea do

        p = rsn.behavior_by
        if p
          _user_x = p[ sea.argument_scanner.listener ]
          _user_x    # #todo
        else
          _tcs = rsn.reason_symbol  # terminal channel symbol
          When::Unknown_branch_item_via_two__[ _tcs, sea ].execute
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

          When::UnknownBranchItem.define do |o|
            @out = o
            __populate_idea
          end
        end

        def __populate_idea

          @out.listener = @_argument_scanner.listener
          @out.shape_symbol = @_shape_symbol
          @out.terminal_channel_symbol = @__terminal_channel_symbol

          if __has_operator_branch
            __populate_splayer
          end

          if @_argument_scanner.no_unparsed_exists
            NOTHING_  # #feature-island #scn-coverpoint-2
          else
            @out.strange_value_by = @_argument_scanner.method :head_as_is
          end

          NIL
        end

        def __has_operator_branch
          ob = @_request.operator_branch
          if ob
            @_operator_branch = ob  # `_store` DEFINITION_FOR_THE_METHOD_CALLED_STORE_
            @out.talker = ob  # sneak this in here
            ACHIEVED_
          end
        end

        def __populate_splayer

          _p = @_argument_scanner.method(
            :available_branch_item_name_stream_via_operator_branch )

          ob = @_operator_branch ; sym = @_shape_symbol

          @out.available_item_name_stream_by = -> do
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
          @listener.call :error, :expression, :parse_error do |y|
            o = me.for y, self
            o.__express_unrecognized_operator
            o.__express_splay_of_available_operators
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
          @listener.call :error, :expression, :parse_error do |y|
            me.for( y, self ).__express_splay_of_available_features
          end
          UNABLE_
        end
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
          @listener = omni.argument_scanner.listener
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
          sym = @omni.argument_scanner.current_operator_symbol ; y = @y
          @expression_agent.calculate do
            y << "unrecognized operator: #{ ick_oper sym }"
          end
        end

        def __express_splay_of_available_features
          o = @omni ; y = @y
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

        def _to_operation_and_primary_moniker_scanner
          _to_operation_moniker_scanner.concat_scanner _to_primary_moniker_scanner
        end

        def _to_operation_moniker_scanner
          _scn = @omni.to_operator_symbol_scanner
          _map_by_expag_method :oper, _scn
        end

        def _to_primary_moniker_scanner
          _scn = @omni.to_primary_symbol_scanner
          _map_by_expag_method :prim, _scn
        end

        def _map_by_expag_method m, scn
          @expression_agent.calculate do
            scn.map_by do |sym|
              send m, sym.intern  # respect [#062]
            end
          end
        end
      end

      # ==

      COLON_ = ':'
      COLON_BYTE_ = COLON_.getbyte 0
      DOT_ = '.'
    end
  end
end
# #history: abstracted from the "when" node of the [tmx] map operation
