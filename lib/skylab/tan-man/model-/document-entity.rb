module Skylab::TanMan

  class Model_

    module Document_Entity

      class << self

        def downstream_identifier_via_trios trio_a, & oes_p
          Brazen_.byte_downstream_identifier.via_trios trio_a, & oes_p
        end

        def entity_property_class
          IO_PROPERTIES__.entity_property_class
        end

        def IO_properties
          IO_PROPERTIES__.array
        end

        def input_properties  # an array
          INPUT_PROPERTIES___.array
        end

        def output_stream_property
          IO_PROPERTIES__.output_stream
        end

        def upstream_identifier_via_trios trio_a, & oes_p
          Brazen_.byte_upstream_identifier.via_trios trio_a, & oes_p
        end
      end  # >>

      class Action < Action_

        def document_entity_byte_upstream_identifier
          @_DEBUID
        end

        def document_entity_byte_downstream_identifier
          @_DEBDID
        end

      private

        def normalize

          # first call ordinary normalize to let any user-provided defaulting
          # logic play out. then with the result arguments, resolve from them
          # one input and (when applicable) one output means.

          super && document_entity_normalize_
        end

        def document_entity_normalize_

          o = Byte_Stream_Identifier_Resolver.new( @kernel, & handle_event_selectively )

          o.formals formal_properties

          o.for_model model_class

          o.against_argument_box @argument_box

          st = o.to_resolution_pair_stream

          st and begin
            ok = true
            begin
              pair = st.gets
              pair or break
              ok = send :"receive_byte__#{ pair.name_symbol }__identifier_", pair.value_x
              ok or break
              redo
            end while nil
            ok
          end
        end

        def receive_byte__input__identifier_ id
          if id
            @_DEBUID = maybe_convert_to_stdin_stream_ id
            @_DEBUID && ACHIEVED_
          else
            @_DEBUID = id
            ACHIEVED_
          end
        end

        def maybe_convert_to_stdin_stream_ id

          if id && :path == id.shape_symbol && DASH_ == id.path
            sin = stdin_
            if sin.tty?
              maybe_send_event :error, :stdin_should_probably_not_be_interactive
              UNABLE_
            else
              Brazen_::Collection::Byte_Upstream_Identifier.via_stream sin
            end
          else
            id
          end
        end

        def receive_byte__output__identifier_ id

          @_DEBDID = __maybe_convert_to_stdout_stream id
          ACHIEVED_
        end

        def __maybe_convert_to_stdout_stream id

          if id && :path == id.shape_symbol && DASH_ == id.path
            Brazen_::Collection::Byte_Downstream_Identifier.via_stream stdout_
          else
            id
          end
        end
      end

      # every document entity action (by default) must resolve at least an
      # input means (add, ls, rm). those that mutate must also resolve one
      # output means (add, rm). back clients don't have a concept of "PWD"
      # but the front client may re-write the `workspace_path` property to
      # default to an arbitrary path that it provides at run-time (for e.g
      # its own `pwd`); however this effort is wasted if the input and any
      # output means are expressed explicitly for eg path, string or stream

      IO_PROPERTIES__ = Model_.make_common_properties do | sess |

        sess.edit_entity_class do

          entity_property_class_for_write  # (was until #wishlist [#br-084] a flag meta meta property)
          class self::Entity_Property

            def initialize
              @direction_symbols = []
              @is_essential_to_direction = false
              super
            end

            def expresses_direction
              true  # or etc
            end

            attr_reader :direction_symbols

            def direction_specific_symbol
              if 1 == @direction_symbols.length
                @direction_symbols.first
              end
            end

            def is_essential_to_direction
              1 == @direction_symbols.length || @is_essential_to_direction
            end

          private

            def direction_essential=
              @is_essential_to_direction = true
              KEEP_PARSING_
            end

            def for_direction=
              @direction_symbols.push gets_one_polymorphic_value
              KEEP_PARSING_
            end
          end

          otr = Brazen_::Models_::Workspace.common_properties

          o :for_direction, :input, :property, :input_string,
            :for_direction, :input, :property, :input_path,

            :for_direction, :output, :property, :output_string,
            :for_direction, :output, :property, :output_path,

            :for_direction, :input,
            :for_direction, :output,
              :default_proc, otr[ :config_filename ].default_proc,
              :property, :config_filename,

            :for_direction, :input,
            :for_direction, :output,
              :non_negative_integer,
              :default, 1,
              :description, otr[ :max_num_dirs ].description_proc,
              :property, :max_num_dirs,

            :for_direction, :input,
            :for_direction, :output,
              :direction_essential,
              :property, :workspace_path  # at end

          # during the input and output resolution, if there is more than one
          # relevant argument it's a (perhaps resolvable) ambiguity. if among
          # these arguments one is a workspace-related argument it's #trump'ed
          # by any and all non-workspace-related arguments with the following
          # rationale: a workspace-related argument (unlike an argument under
          # opposing classifications) is potentially dual-purpose, expressing
          # a means of both input and output. hence arguments of the opposing
          # classifications may be interpreted to be more specific. [#hu-006]
          # this is an example of the principle that specificity may be a
          # reasonable characteristic to help resolve ambiguity disputes.

        end
      end

      module IO_PROPERTIES__

        define_singleton_method :output_stream, ( Callback_.memoize do  # hidden for now, for #feature [#037]

          self::Entity_Property.new do
            @name = Callback_::Name.via_variegated_symbol :output_stream
          end
        end )
      end

      INPUT_PROPERTIES___ = Model_.common_properties_class.new( nil ).set_properties_proc do

        IO_PROPERTIES__.to_stream.reduce_by do | prp |

          prp.direction_symbols.include? :input

        end.flush_to_mutable_box_like_proxy_keyed_to_method :name_symbol
      end

      # ~

      class Byte_Stream_Identifier_Resolver  # [#021]:#args-partitioning explains it all

        def initialize kr, & oes_p
          @formals = nil
          @kernel = kr
          @model_cls = nil
          @oneness_h = nil
          @on_event_selectively = oes_p
        end

        def set_custom_direction_mapping i, i_
          @custom_direction_mappings_h ||= {}
          @custom_direction_mappings_h[ i ] = i_
        end

        def against_trio_box bx
          @trio_box = bx ; nil
        end

        def against_argument_box bx
          @arg_bx = bx ; nil
        end

        def for_model x
          @model_cls = x ; nil
        end

        def formals x
          @formals = x ; nil
        end

        def to_resolution_pair_stream  # assume formals

          __via_formals_init_direction_symbol_list_and_oneness_hash

          ok, * rest = _produce_any_IDs_at @direction_symbol_list

          ok and begin

            Callback_::Stream.via_times @direction_symbol_list.length do | d |

              Callback_::Pair[
                rest.fetch( d ),
                @direction_symbol_list.fetch( d ) ]
            end
          end
        end

        def __via_formals_init_direction_symbol_list_and_oneness_hash

          dir_sym_a = []
          dir_sym_seen_h = {}
          dir_sym_required_h = {}

          @formals.each_value do | prp |

            if ! prp.respond_to? :expresses_direction
              next
            end

            sym = prp.direction_specific_symbol
            sym or next

            dir_sym_seen_h.fetch sym do

                # #one-day a test of optional-ness
                dir_sym_required_h[ sym ] = true

              dir_sym_a.push sym
              dir_sym_seen_h[ sym ] = true
            end
          end

          @direction_symbol_list = dir_sym_a
          @oneness_h = dir_sym_required_h
          nil
        end

        def solve_for direction_symbol
          ok, id = _produce_any_IDs_at [ direction_symbol ]
          ok && id
        end

        def solve_at * direction_symbol_a
          _produce_any_IDs_at direction_symbol_a
        end

        def _produce_any_IDs_at direction_sym_a

          # 1) partition every relevant argument into one or more buckets,
          # one placement for each direction that the argument solves 2) sort
          # each bucket, short-circuit complaining if it is ambiguous. 3)
          # index each such list by the object id of its "leader" argument.
          # this grouping is called a "waypoint", a waypoint being a data
          # source and/or destination that knows the one or more directions
          # it solves for. 4) after the full pass of the previous step, ask
          # each waypoint to solve each of its ID's, short-circuiting on any
          # failure. with each such waypoint index each of its IDs by the
          # direction (symbols) it produces, a mapping of which is our result.

          ok = true
          bucket_h = __produce_bucket_hash direction_sym_a

          wp_o_a = [] ; wp_via_leader = {}

          direction_sym_a.each do | sym |

            arglist = bucket_h.fetch sym
            ok = __normalize_bucket_list arglist, sym
            ok or break

            if arglist.length.zero?
              next
            end

            k = arglist.first.object_id
            _idx = wp_via_leader.fetch k do
              wp = Waypoint__.new arglist, self
              d = wp_o_a.length
              wp_o_a[ d ] = wp
              wp_via_leader[ k ] = d
            end
            wp = wp_o_a.fetch _idx
            wp.receive_additional_direction sym
          end

          if ok
            identifier_via_direction = {}
            wp_o_a.each do | waypoint |

              ok = waypoint.solve
              ok or break
              waypoint.each_solution_pair do | sym, id |
                identifier_via_direction[ sym ] = id
              end
            end

            [ ok, * ( direction_sym_a.map( &
              identifier_via_direction.method( :[] ) ) ) ]
          else
            ok
          end
        end

        def __produce_bucket_hash direction_sym_a

          bucket_h = ::Hash[ direction_sym_a.map { | sym | [ sym, [] ] } ]

          __each_relevant_trio do | trio |

            trio.property.direction_symbols.each do | sym |

              a = bucket_h[ sym ]
              a or next
              a.push trio
            end
          end

          bucket_h
        end

        def __each_relevant_trio

          # if we were given formals we assume we have the arguments as a
          # box and so we can build our own trios. if we weren't we don't

          if @formals

            @arg_bx.each_pair do | k, x |

              prp = @formals.fetch k

              if ! prp.respond_to? :expresses_direction
                next
              end

              yield Callback_::Trio.new( x, true, prp )
            end
          else

            @trio_box.each_value do | trio |

              if ! trio.property.respond_to? :expresses_direction
                next
              end

              yield trio
            end
          end
          nil
        end

        def __normalize_bucket_list sort_me, direction_sym

          # here is the center of this fun complication: specifics trump
          # non-specific essentials. any in the first category means we
          # don't count the second category at all. but within the category
          # that is relevant, you must have exactly one (or zero) winner.

          specifics = nil
          non_specific_essentials = nil
          others = nil

          sort_me.each do | arg |
            prp = arg.property
            if 1 == prp.direction_symbols.length
              ( specifics ||= [] ).push arg
            elsif prp.is_essential_to_direction
              ( non_specific_essentials ||= [] ).push arg
            else
              ( others ||= [] ).push arg
            end
          end

          count_this = specifics || non_specific_essentials || EMPTY_A_

          case 1 <=> count_this.length

          when 0  # exactly one - success

            sort_me.replace [ * count_this, * others ]
            ACHIEVED_

          when 1  # zero

            if @oneness_h && @oneness_h[ direction_sym ]  # missing required meta-property
              when_count_is_not_one direction_sym

            else

              sort_me.clear  # if you don't have essentials, you get NONE

              ACHIEVED_  # not present but not "missing"
            end

          when -1  # more than one - ambiguous

            when_count_is_not_one direction_sym, count_this

          end
        end

        def when_count_is_not_one sym, essential=EMPTY_A_
          @on_event_selectively.call :error, :non_one_IO do
            __build_non_one_IO_event sym, essential
          end
          UNABLE_
        end

        def __build_non_one_IO_event direction_sym, arg_a

          Callback_::Event.inline_not_OK_with :non_one_IO,
              :direction_i, direction_sym,
              :arg_a, arg_a,
              :formals, @formals do | y, o |

            if o.arg_a.length.zero?

              i = o.direction_i

              _s_a = o.formals.map_reduce_by do | prp |
                if prp.respond_to?( :expresses_direction ) &&
                    prp.direction_symbols.include?( i ) &&
                      prp.is_essential_to_direction

                  par prp
                end
              end.to_a

              _xtra = " (provide #{ or_ _s_a })"
            else
              _s_a = arg_a.map do |arg|
                par arg.property
              end
              _xtra = " (#{ _s_a * ', ' })"
            end

            y << "need exactly 1 #{ o.direction_i }-related argument, #{
             }had #{ o.arg_a.length }#{ _xtra }"
          end
        end

        # ~ for waypoint:

        def kr_
          @kernel
        end

        def model_cls_
          @model_cls
        end

        def oes_p_
          @on_event_selectively
        end

        def const_via_direction_ sym

          CONST_VIA_DIRECTION.fetch sym do
            CONST_VIA_DIRECTION.fetch( @custom_direction_mappings_h.fetch( sym ) )
          end
        end
      end

      class Waypoint__

        def initialize arglist, parent
          @arglist = arglist
          @arg = @arglist.first
          @direction_symbols = []
          @name_symbol = @arg.name_symbol
          @parent = parent
        end

        def receive_additional_direction sym
          @direction_symbols.push sym ; nil
        end

        def solve

          # our only special case in this app is w.s. otherwise use [br]

          if :workspace_path == @name_symbol
            __solve_for_workspace
          else
            __solve_for_normal
          end
        end

        def __solve_for_normal

          id = Brazen_::Collection.const_get(

            @parent.const_via_direction_ @arg.property.direction_specific_symbol

          ).via_trios(
            @arglist, & @parent.oes_p_ )

          id and begin
            @id_a = [ id ]
            ACHIEVED_
          end
        end

        def __solve_for_workspace  # (limit w.s logic to this method only)

          kr = @parent.kr_
          oes_p = @parent.oes_p_

          ws = kr.silo( :workspace ).workspace_via_trio_box(
            Callback_::Stream.via_nonsparse_array( @arglist ).
              flush_to_box_keyed_to_method( :name_symbol ),
              & oes_p )

          ws and begin
            @id_a = kr.silo(
              @parent.model_cls_.document_in_workspace_identifier_symbol ).
                produce_byte_stream_identifiers_at_in(
                  @direction_symbols, ws, & oes_p )

            @id_a && ACHIEVED_
          end
        end

        def each_solution_pair
          @direction_symbols.length.times.each do | d |
            yield @direction_symbols.fetch( d ),
              @id_a.fetch( d )
          end ; nil
        end
      end

      CONST_VIA_DIRECTION = {
        input: :Byte_Upstream_Identifier,
        output: :Byte_Downstream_Identifier
      }.freeze

      class Collection_Controller

        # frontier. this *is* a controller because it is coupled to the action.

        include Callback_::Event::Selective_Builder_Receiver_Sender_Methods

        def initialize act, bx, mc, k, & oes_p

          oes_p or self._EVENT_HANDLER_MANDATORY

          @action = act
          @df = bx.fetch :dot_file
          @kernel = k
          @model_class = mc
          @precons_box_ = bx
          @on_event_selectively = oes_p

        end

        # c r u d

        def unparse_into y
          @df.unparse_into y
        end

        def flush_maybe_changed_document_to_output_adapter__ did_mutate
          if did_mutate
            flush_changed_document_to_ouptut_adapter
          else
            __when_document_did_not_change
          end
        end

        def __when_document_did_not_change
          maybe_send_event :info, :document_did_not_change do
            build_neutral_event_with :document_did_not_change do |y, o|
              y << "document did not change."
            end
          end ; nil
        end

        def flush_changed_document_to_ouptut_adapter
          flush_changed_document_to_output_adapter_per_action @action
        end

        def flush_changed_document_to_output_adapter_per_action action

          @df.persist_into_byte_downstream_identifier(

            action.document_entity_byte_downstream_identifier,

            :is_dry, action.argument_box[ :dry_run ],

            & action.handle_event_selectively )

        end

        def document_

          # we wanted this to be referred to as "digraph" and not "dot file"
          # but the clients need to manipulate the document at the sexp level
          # so it is pointless to try to abstract our implementation away..

          @df
        end
      end

      KEEP_PARSING_ = true
    end
  end
end
