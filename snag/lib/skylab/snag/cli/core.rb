module Skylab::Snag

  class CLI < Home_.lib_.brazen::CLI

    CLI_Lib__ = superclass

    # ~ the bulk of this file is the implementation of the hybrid "open"
    # action adapter, an exposure that calls one of two distinct model
    # actions depending on its arguments.

    def to_unordered_selection_stream

      # this is :[#br-066] currently the only example of the code
      # necessary to expose & implement a modality-only action adatper..

      super.unshift_by CLI_Lib__::Backless::Backless_Unbound_Action.new Actions::Open
    end

    class Action_Adapter < Action_Adapter

      MUTATE_THESE_PROPERTIES = [ :upstream_identifier ]

      def mutate__upstream_identifier__properties

        _mutate_upstream_adapter_in mutable_front_properties
        NIL_
      end

      def _mutate_upstream_adapter_in bx

        bx.replace_by :upstream_identifier do | prp |

          prp.dup.set_default_proc do

            present_working_directory

          end.freeze
        end
        NIL_
      end
    end

    Actions = ::Module.new

    class Actions::Open < Action_Adapter

      def populated_option_parser_via _opt_a, _op

        _op_ = super

        Home_.lib_.brazen::
          CLI_Support::Option_Parser::Experiments::Regexp_Replace_Tokens.
        new(

          _op_,

          %r(\A-(?<num>\d+)\z),

          -> md do
            [ '--number-limit', md[ :num ] ]
          end )
      end

      def prepare_backstream_call x_a

        @_filesystem = Home_.lib_.system.filesystem
        @_oes_p = handle_event_selectively

        @_hy = @bound.hybrid

        _mutate_upstream_adapter_in @_hy.moz

        o = Home_.lib_.fields::Attributes::Value_Processing.new

        bx = Callback_::Box.new

        o.value_collection = bx
        o.iambic = x_a
        o.value_models = @_hy.moz
        o.execute
        x_a.clear
        x_a = nil  # because assume processed fully

        # ( not here, but where?

        path = bx.fetch :upstream_identifier
        path = Home_::Models_::Node_Collection.nearest_path(
          path, @_filesystem, & @_oes_p )

        # )

        if path
          bx.replace :upstream_identifier, path

          __finish_prepare_backstream_call bx
        else
          path
        end
      end

      def __finish_prepare_backstream_call bx

        hy = @_hy
        h = hy.category_lookup_table
        lefts = nil
        rights = nil
        bx.a_.each do | k |
          cat_sym = h.fetch k
          case cat_sym
          when :left_only
            ( lefts ||= [] ).push k
          when :right_only
            ( rights ||= [] ).push k
          when :shared_allegiance
            NIL_  # nothing
          else
            raise ::NameError, cat_sym
          end
        end

        if bx.has_name :message

          if lefts
            _when_non_pertient lefts, :right_unbound, :left_unbound
          else
            __prepare_backstream_for_opening bx
          end
        else
          if rights
            _when_non_pertient rights, :left_unbound, :right_unbound
          else
            __prepare_backstream_for_report bx
          end
        end
      end

      def _when_non_pertient bad_sym_a, wont_work_for_this_sym, but_this_sym

        hy = @_hy

        mz = hy.moz

        prp_a = bad_sym_a.map do | k |
          mz.fetch k
        end

        wont_work_for_this = hy.send wont_work_for_this_sym
        but_this = hy.send but_this_sym

        receive__error__expression :non_pertinent_arguments do | y |

          _s_a = prp_a.map do | prp |
            par prp
          end

          _ = and_ _s_a

          _no = wont_work_for_this.name_function.as_slug

          _ok = but_this.name_function.as_slug

          y << "#{ _ } can be used for #{ val _ok } but not for #{ val _no }"
        end
        UNABLE_  # ("downgrade" result of above from nil to false)
      end

      def __prepare_backstream_for_report bx

        o = Home_::Models_::Node_Collection::Sessions::Report_of_Open_Nodes.
          new( & @_oes_p )

        o.filesystem = @_filesystem
        o.kernel = application_kernel
        o.name = self.name
        o.number_limit = bx[ :number_limit ]
        o.upstream_identifier = bx.fetch :upstream_identifier

        @bound = o  # overwrites mock bound

        ACHIEVED_
      end

      def __prepare_backstream_for_opening bx

        o = Home_::Models_::Node::Actions::Open.new( application_kernel, & @_oes_p )

        o.argument_box = bx

        @bound = Customization_Layer_for_Open___.new o
          # overwrites mock bound

        ACHIEVED_
      end
    end

    class Customization_Layer_for_Open___

      def initialize x
        @_up = x
      end

      def bound_call_against_polymorphic_stream st

        @_bc = @_up.bound_call_against_polymorphic_stream st

        Callback_::Bound_Call.via_receiver_and_method_name self, :execute
      end

      def execute

        bc = @_bc
        bc.receiver.send bc.method_name, * bc.args, & bc.block

        # (result is entity, which is OK for now. so this class does nothing)
      end
    end

    class Actions::Open::Backless_Bound_Action < CLI_Lib__::Backless::Backless_Bound_Action

      attr_reader :hybrid

      # .. we have to make one of these when don't have a backstream action

      def describe_into_under y, expag

        y << "open an issue or stream open issues"
      end

      def produce_formal_properties

        __init_hybrid
        @hybrid.moz
      end

      def __init_hybrid

        hy = Hybrid___.new

        hy.left_unbound =
          Home_::Models_::Node::Actions::To_Stream

        hy.right_unbound =
          Home_::Models_::Node::Actions::Open

        hy.init_formal_properties_box

        @hybrid = hy
        bx = hy.moz

        __mutate_message_property
        __mutate_number_limit

        s = 'used for report only'
        hy.left_only.each do | k |
          _hack_qualify_description k, bx, s
        end

        s = 'used for opening issue only'
        hy.right_only.each do | k |
          :message == k and next  # because it's semantically redundant
          _hack_qualify_description k, bx, s
        end

        s = 'used in both forms'
        hy.shared_allegiance.each do | k |
          _hack_qualify_description k, bx, s
        end

        NIL_
      end

      def __mutate_message_property

        # make the message optional not required; the defining mechanic

        @hybrid.moz.replace_by :message do | prp |

          prp.new_with(
            :argument_arity, :zero_or_more,
            :parameter_arity, :zero_or_one,
            :description, -> y do
              y << "if provided, act similar to `node open`"
              y << "otherwise run \"open\" report or equivalent"
            end )
        end
        NIL_
      end

      def __mutate_number_limit

        @hybrid.moz.replace_by :number_limit do | prp |

          prp.new_with(
            :description, -> y do
              y << "`-<number>` too"
            end )
        end
        NIL_
      end

      def _hack_qualify_description k, bx, s

        prp = bx.fetch k
        if prp.frozen?
          mutable_prp = prp.dup
          bx.replace k, mutable_prp
        else
          mutable_prp = prp
        end
        prp = nil

        addendum = "(#{ s })"

        desc_p = mutable_prp.description_proc

        if desc_p
          _new_description_proc = ___fantastic_hack addendum, desc_p
        else
          _new_description_proc = -> y do
            y << addendum
          end
        end

        mutable_prp.description_proc = _new_description_proc
        NIL_
      end

      def ___fantastic_hack addendum, upstream_description_p

        # a hacky (fun) heuristic descides whether we break the line..

        me = self
        -> y do

          # render the lines as they used to appear. (self is expression agent.)

          s_a = []
          _y_ = ::Enumerator::Yielder.new( & s_a.method( :push ) )
          calculate _y_, & upstream_description_p

          # here's the hacky part: we want to break the line if the would-be
          # new line would be considered "too long". so what is long?

          me.___mutate_lines_using_adendum s_a, addendum
        end
      end

      def ___mutate_lines_using_adendum s_a, addendum

        case 1 <=> s_a.length
        when 0

          # if there is only one line, we have no reference point except
          # the addendum, so we use the addendum itself to determine if
          # the existing line is already "long"

          _on_its_own_line = s_a.last.length > addendum.length

        when -1

          # when there is more than one line, will the would-be new line
          # be longer than the longest of all the non-final lines?

          _longest = ( 0 ... s_a.length ).reduce 0 do | m, d |
            length = s_a.fetch( d ).length
            m < length ? length : m
          end

          _would_be_new_line_length =
            s_a.last.length + SPACE_.length + addendum.length

          _on_its_own_line = _longest < _would_be_new_line_length

        when 1

          # if there are no existing lines, addendum gets its own line

          _on_its_own_line = true
        end

        # (the above block is exemplary of name conv. [#bs-032]#D )

        if _on_its_own_line
          s_a.push s
        else
          s_a[ -1 ] = "#{ s_a.last } #{ addendum }"
        end
        NIL_
      end
    end

    class Hybrid___

      attr_reader(
        :left_unbound,
        :right_unbound )

      attr_writer(
        :left_unbound,
        :right_unbound )

      attr_reader(
        :category_lookup_table,
        :left_only,
        :moz,
        :right_only,
        :shared_allegiance )

      def init_formal_properties_box

        bx = @left_unbound.properties.to_new_mutable_box_like_proxy

        shared_allegiance = []
        right_only = []

        @right_unbound.properties.to_value_stream.each do | prp |

          k = prp.name_symbol
          had = true
          bx.touch k do
            had = false
            prp
          end

          if had
            shared_allegiance
          else
            right_only
          end.push k
        end

        left_only = bx.a_ - ( shared_allegiance + right_only )

        @left_only = left_only
        @right_only = right_only
        @shared_allegiance = shared_allegiance

        # (you might want to set the arrays themselves to ivars here)

        h = {}
        left_only.each { | k | h[ k ] = :left_only }
        shared_allegiance.each { | k | h[ k ] = :shared_allegiance }
        right_only.each { | k | h[ k ] = :right_only }

        @category_lookup_table = h

        @moz = bx
        NIL_
      end
    end

    Brazen_ = Home_.lib_.brazen
  end
end
