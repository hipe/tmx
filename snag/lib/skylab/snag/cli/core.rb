module Skylab::Snag

  class CLI < Home_.lib_.brazen::CLI

    CLI_Lib__ = superclass

    # ~ the bulk of this file is the implementation of the hybrid "open"
    # action adapter, an exposure that calls one of two distinct model
    # actions depending on its arguments.

    # awful alias method chain only #while #exist [br] and while #open [#co-016.3]

    expose_executables_with_prefix 'tmx-snag-'

    alias_method :__this_guy, :to_unordered_selection_stream

    def to_unordered_selection_stream

      _head_item = CLI_Lib__::Backless::Backless_Unbound_Action.new Actions::Open

      _tail_st = __this_guy

      Common_::Stream::CompoundStream.define do |o|
        o.add_item _head_item
        o.add_stream _tail_st
      end
    end

    def build_expression_agent_for_this_invocation invo
      CLI::InterfaceExpressionAgent.new invo
    end

    class Action_Adapter < Action_Adapter

      MUTATE_THESE_PROPERTIES = [ :upstream_reference ]

      def mutate__upstream_reference__properties

        _mutate_upstream_adapter_in mutable_front_properties
        NIL_
      end

      def _mutate_upstream_adapter_in bx

        bx.replace_by :upstream_reference do | prp |

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
        @_listener = handle_event_selectively

        @_hy = @bound.hybrid

        _mutate_upstream_adapter_in @_hy.moz

        o = Home_.lib_.fields::Normalization::JUNE_08_2015.new

        # so: we're in the middle of unifying all normalization. the above
        # facility is on deck to be assimilated. however, we don't have
        # coverage of this point because CLI is on furlough for [sn] while
        # we go through the big migration off of [br]. when we come back
        # around to all that we *suspect* that all of this will have changed
        # because feature injection will hopefully be cleaner by then.
        # as such, we're just gonna sunset the entire above node. if we
        # want something from it we can always dig it back up. #tombstone-A

        bx = Common_::Box.new

        o.value_collection = bx
        o.iambic = x_a
        o.value_models = @_hy.moz
        o.execute
        x_a.clear
        x_a = nil  # because assume processed fully

        # ( not here, but where?

        path = bx.fetch :upstream_reference
        path = Home_::Models_::NodeCollection::Nearest_path.call(
          path, @_filesystem, & @_listener )

        # )

        if path
          bx.replace :upstream_reference, path

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

        if bx.has_key :message

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

        o = Home_::Models_::NodeCollection::Magnetics::Expression_of_OpenNodes_via_Arguments.
          new( & @_listener )

        o.filesystem = @_filesystem
        o.kernel = application_kernel
        o.name = self.name
        o.number_limit = bx[ :number_limit ]
        o.upstream_reference = bx.fetch :upstream_reference

        @bound = o  # overwrites mock bound

        ACHIEVED_
      end

      def __prepare_backstream_for_opening bx

        o = Home_::Models_::Node::Actions::Open.new( application_kernel, & @_listener )

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

      def bound_call_against_argument_scanner st

        @_bc = @_up.bound_call_against_argument_scanner st

        Common_::BoundCall.via_receiver_and_method_name self, :execute
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
          Home_::Models_::Node::Actions::ToStream

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

          prp.with(
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

          prp.with(
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

        # (the above block is exemplary of name conv. [#bs-032.4] )

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

    def expression_strategy_for_uncategorized_property prp
      :render_property_as_unknown
    end

    Brazen_ = Home_.lib_.brazen
  end
end
# :#tombstone-A: sunset a normalization over in [fi] that was used only here
