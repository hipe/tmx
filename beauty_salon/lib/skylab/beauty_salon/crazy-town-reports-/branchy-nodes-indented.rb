# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownReports_::BranchyNodesIndented < Common_::MagneticBySimpleModel

    # -

      def self.describe_into_under y, expag

        y << 'this one is a bit of a "contact exercise" to work with stacks.'
        y << '(we also use it for coverage)'
        y << 'summarize every file in two ways:'
        y << nil
        y << '  1) pretending that it\'s python, use indentation only'
        y << '     (no `end` keywords) to signify the depth of the element.'
        y << nil
        y << '  2) express only "branchy" nodes, so things like modules,'
        y << '     classes and methods..'
      end

      attr_writer(
        :file_path_upstream_resources,
        :named_listeners,
        :listener,
      )

      def execute

        @file_path_upstream_resources.line_stream_via_file_chunked_functional_definition do |y, oo|

          oo.define_document_processor :plan_A do |o|

            # (the below is not necessary because #here1:)
            #
            # o.before_each_file do |potential_node|
            #  y << "file #{ potential_node.path }"
            # end

            o.customize_stack_hooks_by__ do |svc|
              My_custom_stack_thing___[ y, svc ]
            end

            o.named_listeners = @named_listeners

            o.listener = @listener
          end

          oo.on_each_file_path do |path, o|

            o.execute_document_processor :plan_A
          end
        end
      end
    # -

    # ==

    # at this #history-A.1 we "in-loaded" (opposite of off-loaded) lots of
    # code and logic. [#025.G] is dedicated to explaining this report.

    My_custom_stack_thing___ = -> y, svc do

      margin = MARGIN_CACHE___

      recv = -> wnode do
        y << "#{ margin[ wnode.depth ] }#{ wnode.to_description }"
      end

      my_stack_depth = 0

      gram_syms = svc.grammar_symbols_feature_branch

      build_when_branchy = -> o do

        -> n do

          my_stack_depth += 1

          _cls = gram_syms.dereference n.type
          _sn = _cls.via_node_ n

          recv[ ItemStackFrame___.new( my_stack_depth, _sn ) ]

          o.push_stack_via_node_and_pop_callback_by n do

            my_stack_depth -= 1
          end
        end
      end

      is_branchy = ::Hash.new do |h, k|
        _cls = gram_syms.dereference k
        yes = _cls::IS_BRANCHY
        h[ k ] = yes
        yes
      end

      svc.will_push_to_stack_by do |o|

        when_branchy = build_when_branchy[ o ]

        -> n do
          _is_branchy = is_branchy[ n.type ]
          if _is_branchy
            when_branchy[ n ]
          else
            o.push_stack_via_node n
          end
        end
      end

      svc.will_start_with_stack_by do |path|  # :#here1

        recv[ FileStackFrame___.new( path ) ]
      end

      svc.will_finish_with_stack_by do
        my_stack_depth.zero? || fail
      end

      svc.will_visit_terminal_normally
      NIL
    end

    # ==

    class FileStackFrame___

      def initialize path
        @path = path ; freeze
      end

      def to_description
        "file: #{ @path }"
      end

      def depth
        0
      end
    end

    # ==

    class ItemStackFrame___

      def initialize d, sn
        @depth = d
        @structured_node = sn
        freeze
      end

      def to_description
        @structured_node.to_description
      end

      attr_reader(
        :depth,
        :structured_node,
      )
    end

    # ==

    MARGIN_CACHE___ = -> do

      indent_s = SPACE_ * 2

      ::Hash.new do |h, d|
        # the lowest stack depth we ever see for AST nodes is 1..
        s = ( indent_s * d ).freeze
        h[ d ] = s
        s
      end

    end.call

    # ==
  end
end
# #history-A.1: assimilated other file (only took those 2 model classes)
# #born.
