module Skylab::TanMan

  class Model_

    class Document_Entity < self

      class << self

        def IO_properties
          IO_PROPERTIES__.array
        end

        def input_properties  # an array
          INPUT_PROPERTIES___.array
        end

        def output_stream_property
          IO_PROPERTIES__.output_stream
        end

        def action_class
          Action___
        end
      end  # >>

      Action___ = ::Class.new Action_  # before below

      # every document entity action (by default) must resolve at least an
      # input means (add, ls, rm). those that mutate must also resolve one
      # output means (add, rm). back clients don't have a concept of "PWD"
      # but the front client may re-write the `workspace_path` property to
      # default to an arbitrary path that it provides at run-time (for e.g
      # its own `pwd`). however this effort is wasted if the input and any
      # output means are expressed explicitly for eg path, string or stream

      IO_PROPERTIES__ = make_common_properties do | sess |

        sess.edit_entity_class do

          entity_property_class_for_write  # (was until #wishlist [#br-084] a flag meta meta property)
          class self::Entity_Property

            attr_reader(
              :can_be_for_document_input,
              :can_be_for_document_output,
              :is_document_direction_specific,
              :is_document_input_specific,
              :is_document_output_specific,
              :is_document_IO_essential,
              :is_for_document_IO
            )

          private

            def document_IO_essential=
              @is_document_IO_essential = true
              KEEP_PARSING_
            end

            def for_document_input_only=
              @can_be_for_document_input = true
              @is_document_direction_specific = true
              @is_for_document_IO = true
              @is_document_input_specific = true
              KEEP_PARSING_
            end

            def for_document_IO=
              @can_be_for_document_input = true
              @can_be_for_document_output = true
              @is_for_document_IO = true
              KEEP_PARSING_
            end

            def for_document_output_only=
              @can_be_for_document_output = true
              @is_document_direction_specific = true
              @is_for_document_IO = true
              @is_document_output_specific = true
              KEEP_PARSING_
            end
          end

          otr = Brazen_::Models_::Workspace.common_properties

          o :for_document_input_only, :property, :input_string,
            :for_document_input_only, :property, :input_path,

            :for_document_output_only, :property, :output_string,
            :for_document_output_only, :property, :output_path,

            :for_document_IO,
              :default_proc, otr[ :config_filename ].default_proc,
              :property, :config_filename,

            :for_document_IO,
              :non_negative_integer,
              :default, 1,
              :description, otr[ :max_num_dirs ].description_proc,
              :property, :max_num_dirs,

            :for_document_IO,
              :document_IO_essential,
              :property, :workspace_path  # at end

          # during the input and output resolution, if there is more than one
          # relevant argument it's a (perhaps resolvable) ambiguity. if among
          # these arguments one is a workspace-related argument it is trumped
          # by any and all non-workspace-related arguments with the following
          # rationale: a workspace-related argument (unlike an argument under
          # opposing classifications) is potentially dual-purpose, expressing
          # a means of both input and output. hence arguments of the opposing
          # classifications may be interpreted to be more specific. [#it-006]
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

      KEEP_PARSING_ = true

      INPUT_PROPERTIES___ = common_properties_class.new( nil ).set_properties_proc do

        IO_PROPERTIES__.to_stream.reduce_by( & :can_be_for_document_input ).

          flush_to_mutable_box_like_proxy_keyed_to_method( :name_symbol )
      end

      class Partition_IO_Args

        def initialize trio_st, formals=nil, & oes_p
          @trio_st = trio_st
          @on_event_selectively = oes_p
          @formals = formals
        end

        def partition_and_sort

          input_specific_a = nil
          input_non_specific_a = nil
          output_specific_a = nil
          output_non_specific_a = nil

          st = @trio_st
          while trio = st.gets

            prp = trio.property
            prp or next
            prp.respond_to? :is_for_document_IO or next

            trio.value_x or next

            if prp.is_document_direction_specific
              if prp.is_document_input_specific
                ( input_specific_a ||= [] ).push trio
              else
                ( output_specific_a ||= [] ).push trio
              end
            else
              if prp.can_be_for_document_input
                ( input_non_specific_a ||= [] ).push trio
              end
              if prp.can_be_for_document_output
                ( output_non_specific_a ||= [] ).push trio
              end
            end
          end

          @result_array_pair = []

          __partition_any_formals

          _ok = _money( input_specific_a, input_non_specific_a, @normalize_for_input, 0 ) and
            _money( output_specific_a, output_non_specific_a, @normalize_for_output, 1 )

          _ok and @result_array_pair
        end

        def __partition_any_formals
          if @formals
            __partition_formals
          else
            @normalize_for_output = @normalize_for_input = false
          end
          nil
        end

        def __partition_formals

          # whether (variously) any output or input *specific* formals are
          # expressed in the box determines whether we are normalizing for
          # a one-ness of that particular category against the arguments.

          seen = []
          saw_input = saw_output = false
          p_a = [  # diminishing pool
            -> prp do
              prp.is_document_input_specific and saw_input = true
            end,
            -> prp do
              prp.is_document_output_specific and saw_output = true
            end ]

          @formals.each do | prp |

            # here we do not use just the name to match.

            prp.respond_to?( :is_for_document_IO ) or next

            p_a.each_with_index do | p, idx |
              p[ prp ] and seen.push idx
            end
            seen.length.zero? and next
            seen.each do | d |
              p_a[ d ] = nil
            end
            p_a.compact!
            if p_a.length.zero?
              break
            end
            seen.clear
          end
          @normalize_for_input = saw_input
          @normalize_for_output = saw_output
          nil
        end

        def _money spec_a, non_spec_a, do_normalize, idx

          if non_spec_a
            essential_a, non_essential_a = non_spec_a.partition do | arg |
              arg.property.is_document_IO_essential
            end
          end

          if spec_a  # assume nonzero length
            winners_a = spec_a
          elsif essential_a && essential_a.length.nonzero?
            winners_a = essential_a
          end

          if winners_a

            if 1 < winners_a.length  # more than one essential argument
              # of the same ranking is an unresolvable ambiguity always

              _non_one winners_a, idx

            else  # every non-nil input or output value provided is put
              # into the result array sorted by significance descending

              @result_array_pair[ idx ] = [ * spec_a, * essential_a, * non_essential_a ]
              ACHIEVED_
            end
          elsif do_normalize  # because this was in the provided formal
            # array and none was resolved, it's an error
            _non_one EMPTY_A_, idx
          else
            @result_array_pair[ idx ] = EMPTY_A_
            ACHIEVED_
          end
        end

        def _non_one arg_a, d
          @on_event_selectively.call :error, :non_one_IO do
            _build_non_one_IO_event DIRECTIONS__[ d ], arg_a
          end
          UNABLE_
        end

        DIRECTIONS__ = [ :input, :output ]

        def _build_non_one_IO_event direction_sym, arg_a

          Callback_::Event.inline_not_OK_with :non_one_IO,
              :direction_i, direction_sym,
              :arg_a, arg_a,
              :properties, @formals do | y, o |

            if o.arg_a.length.zero?

              meth_sym = {
                input: :can_be_for_document_input,
                output: :can_be_for_document_output
              }.fetch o.direction_i

              _s_a = o.properties.reduce_by do | prp |

                prp.respond_to?( meth_sym ) &&
                  prp.send( meth_sym ) &&  # :+[#br-046]
                  ( prp.is_document_IO_essential || prp.is_document_direction_specific )

              end.map do | prp |
                par prp
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
      end

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

          @df.persist_via_three(
            action.argument_box[ :dry_run ],
            action.output_arguments,
            action.stdout )
        end

        def document_

          # we wanted this to be referred to as "digraph" and not "dot file"
          # but the clients need to manipulate the document at the sexp level
          # so it is pointless to try to abstract our implementation away..

          @df
        end
      end

      DOT_DOT_ = '..'.freeze

      class Action___  # re-open

        def input_arguments
          @input_argument_a
        end

        attr_reader :output_arguments  # not guaranteed to exist for some actions

      private

        def normalize

          # first call ordinary normalize to let any user-provided defaulting
          # logic play out. then with the result arguments, resolve from them
          # one input and (as appropriate) one output means.

          super && __document_entity_normalize
        end

        def __document_entity_normalize

          in_a, out_a = Partition_IO_Args.new(
            to_trio_stream,
            formal_properties,
            & handle_event_selectively ).partition_and_sort

          in_a and begin
            @input_argument_a = in_a
            @output_arguments = out_a
            ACHIEVED_
          end
        end
      end
      Action = Action___  # until next commit
    end
  end
end
