module Skylab::Brazen

  module CLI_Support

    class When::Help < As_Bound_Call  # (fwd declaration)
#==FROM

      # of the 8 or so help-support-like files at writing, this is the
      # second oldest. "isomorphic method client" is older but has less
      # interesting history. yadda yadda unification

      # (at writing used only by [tmx] only for [ze] "argument scanner" related) (etc)

      ScreenForWhichever__ = ::Class.new

      class ScreenForBranch < ScreenForWhichever__

        def express_usage_section program_name

          @express_boundary[]

          buffer = "usage: #{ program_name }"

          if @has_item_groups
            st = to_item_name_stream
            one = st.gets
          end

          if one
            buffer << " { " << one.as_slug
            begin
              nm = st.gets
              nm || break
              buffer << PIPEY___ << nm.as_slug
              redo
            end while above
            buffer << " }"
          end
          buffer << " [opts]"
          @puts.call buffer
          NIL
        end
      end

      class ScreenForEndpoint < ScreenForWhichever__

        def express_usage_section program_name

          @express_boundary[]

          buffer = "usage: #{ program_name }"

          countdown = 3  # max number of primaries to show up here

          if @has_item_groups
            st = to_item_name_stream
            nm = st.gets
          end

          if nm && countdown.nonzero?
            say = -> name do
              "[ #{ name.as_slug } ..]"
            end
            begin
              countdown -= 1
              buffer << SPACE_ << say[ nm ]
              nm = st.gets
              nm || break
              if countdown.zero?
                buffer << " .."
                break
              end
              redo
            end while above
          end

          @puts.call buffer
          NIL
        end
      end

      class ScreenForWhichever__

        class << self
          def express_into io
            yield new io
          end
          private :new
        end  # >>

        def initialize io

          puts = io.method :puts

          @express_boundary = -> do
            @express_boundary = puts ; nil
          end

          @express_blank_line = puts
          @has_item_groups = false
          @margin = TWO_SPACES___
          @puts = puts
        end

        def express_description_section_by & user_p
          express_description_section user_p
        end

        def express_description_section user_p
          express_section_simply_via_header_and_message_proc "description", user_p
        end

        def express_items_section_by & p
          express_items_sections p
        end

        def express_items_sections description_proc_for

          to_item_group_stream.each do |group|

            __express_items_section group, description_proc_for
          end
          NIL
        end

      private

        def __express_items_section group, description_proc_for

          @express_boundary[]

          puts = @puts

          puts.call "#{ LABEL_FOR___.fetch group.normal_item_type_symbol }:"

          fmt = "#{ @margin }%#{ @max_name_width }s"

          indent_with_spaces = fmt % nil

          subsequent_line = -> line do
            puts.call "#{ indent_with_spaces }#{ @margin }#{ line }"
          end

          buffer = ""
          p = nil

          first_line = -> line do
            buffer << @margin
            buffer << line
            puts.call buffer
            p = subsequent_line
          end

          y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          item = -> nm do

            buffer = fmt % nm.as_slug

            desc_p = description_proc_for[ nm.as_variegated_symbol ]
            if desc_p
              p = first_line
              nil.instance_exec y, & desc_p  # #no-expag for now (1 of 2)
            end
            NIL
          end

          subsequent_boundary = -> do
            buffer = ""  # (we used to just clear it, but that botches some tests)
            @express_blank_line[]
          end

          boundary = -> do
            boundary = subsequent_boundary
          end

          st = group.to_item_name_stream
          begin
            nm = st.gets
            nm || break
            boundary[]
            item[ nm ]
            redo
          end while nil
          NIL
        end

        LABEL_FOR___ = {
          operator: "operations",  # misnomer, meh
          primary: "primaries",
        }

        def express_section_simply_via_header_and_message_proc hdr, user_p

          @express_boundary[]

          subsequent_line = nil

          p = -> line do
            p = subsequent_line
            @puts.call "#{ hdr }: #{ line }"
          end

          subsequent_line = -> line do
            if line
              @puts.call "#{ @margin }#{ line }"
            else
              @puts.call line
            end
          end

          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          nil.instance_exec _y, & user_p  # #no-expag for now (2 of 2)
          NIL
        end

        # -- write-on-receive (then read)
      public

        def primary_symbols ks
          _st = Stream_.call ks do |k|
            [ :primary, k ]
          end
          item_normal_tuple_stream _st
          NIL
        end

        def item_normal_tuple_stream st

          current_item_group_normal_sym = nil
          item_groups_cache = []
          max = 0

          begin
            tuple = st.gets
            tuple || break
            type_sym, normal_sym = tuple
            normal_sym || ::Kernel._OOPS  # #todo
            name = NAME_FOR___.fetch( type_sym )[ normal_sym ]

            # -- maybe increase max width

            len = name.as_slug.length
            max = len if max < len

            # -- add to groups

            if current_item_group_normal_sym != type_sym
              g = ItemGroup___.new type_sym
              item_groups_cache.push g
              current_item_array = g.item_array
              current_item_group_normal_sym = type_sym
            end

            current_item_array.push name
            redo
          end while above

          @has_item_groups = true
          @item_groups = item_groups_cache
          @max_name_width = max
          NIL
        end

      private

        def to_item_name_stream
          to_item_group_stream.expand_by do |group|
            group.to_item_name_stream
          end
        end

        def to_item_group_stream
          Stream_[ @item_groups ]
        end
      end

      # ==

      NAME_FOR___ = {
        operator: -> sym do
          Common_::Name.via_variegated_symbol sym
        end,
        primary: -> sym do
          nm = Common_::Name.via_variegated_symbol sym
          nm.as_slug = "-#{ nm.as_slug }"
          nm
        end,
      }

      # ==

      class ItemGroup___

        def initialize type_sym
          @item_array = []
          @normal_item_type_symbol = type_sym
        end

        def to_item_name_stream
          Stream_[ @item_array ]
        end

        attr_reader(
          :item_array,
          :normal_item_type_symbol,
        )
      end

      # ==

      PIPEY___ = ' | '
      TWO_SPACES___ = '  '.freeze
#==TO
    end

    class When::Help < As_Bound_Call  # abstract

      def initialize
        @command_string = nil
      end

      attr_writer(
        :command_string,
        :invocation_expression,
        :invocation_reflection,
      )

      def _express_common_screen

        @invocation_expression.express_usage_section

        @invocation_expression.express_description

        @invocation_expression.express_custom_sections

        @_do_options_as_actions = @invocation_expression.do_express_options_as_actions_for_help

        express_items_
      end
    end

    class When::Help::For_Branch < When::Help

      def produce_result

        if @command_string
          ___when_command_string
        else
          _express_common_screen
        end
      end

      def ___when_command_string

        o = @invocation_reflection

        a = o.find_matching_action_adapters_against_tok_(
          @command_string )

        case 1 <=> a.length
        when  0
          a.first.receive_show_help o

        when  1
          o.receive_no_matching_via_token__ @command_string

        when -1
          o.receive_multiple_matching_via_adapters_and_token__(
            a, @command_string )
        end
      end

      def express_items_  # actions

        # when options are expressed separate from actions they are expressed
        # *after* the actions by the justification that they are generally
        # more detailed and low-level. note that it is always the expression
        # of actions that determines the exitstatus (for now).

        es = ___express_actions

        if ! @_do_options_as_actions
          __express_branch_options
        end

        es
      end

      def ___express_actions  # result is exitstatus

        ada_a = ___arrange_items

        if ada_a.length.zero?
          __when_no_actions
        else
          __when_some_actions ada_a
        end
      end

      def __express_branch_options

        exp = @invocation_expression
        op = exp.option_parser
        if op
          _s = exp.plural_options_section_header_label_for_help
          exp.express_section(
            :header, _s,
            :singularize,  # not working, but meh
          ) do |y|
            op.summarize y
          end
        end
        NIL_
      end

      def ___arrange_items

        o = @invocation_reflection

        _visible_st = o.to_adapter_stream.reduce_by( & :is_visible )

        _ordered_st = o.wrap_adapter_stream_with_ordering_buffer _visible_st

        _ordered_st.to_a
      end

      def __when_no_actions

        @invocation_expression.express_section do |y|
          y << "(no actions)"
        end

        GENERIC_ERROR_EXITSTATUS  # ..
      end

      def __when_some_actions ada_a

        Require_fields_lib_[]

        exp = @invocation_expression

        did = exp.express_section(
          :header, 'actions',
          :singularize,
          :wrapped_second_column, exp.option_parser,
        ) do | y |
          ___express_action_items_into y, ada_a
        end

        if did
          @invocation_expression.express_invite_to_help_as_compound_to @invocation_reflection
          SUCCESS_EXITSTATUS
        else
          GENERIC_ERROR_EXITSTATUS  # ..
        end
      end

      def ___express_action_items_into y, ada_a

        exp = @invocation_expression
        expag = exp.expression_agent

        if @_do_options_as_actions
          # present the 'help' option (or whatever) as an action
          op = exp.option_parser
          if op
            op.summarize y
          end
        end

        ada_a.each do | ada |

          if Field_::Has_description[ ada ]

            # #[#002]an-optimization-for-summary-of-child-under-parent

            _p = ada.description_proc_for_summary_under exp

            _desc_lines = Field_::N_lines_via_proc[ MAX_DESC_LINES, expag, _p ]
          end

          y.yield ada.name.as_slug, ( _desc_lines || EMPTY_A_ )
        end
        NIL_
      end
    end

    class When::Help::For_Action < When::Help

      def produce_result
        _express_common_screen
      end

      def express_items_

        ___express_options

        express_any_custom_sections_  # result is t/f of any

        SUCCESS_EXITSTATUS
      end

      def ___express_options

        op = @invocation_reflection.option_parser
        if op

          _ = 1 == op.top.list.length ? 'option' : 'options'

          @invocation_expression.express_section :header, _ do | y |
            op.summarize y
          end
        end
        NIL_
      end
    end

    class When::Help

      def express_any_custom_sections_

        intr = nil

        p = -> xx_aa do
          intr = Here_::Section::DSL.new @invocation_expression
          p = -> x_a do
            intr.receive x_a
          end
          p[ xx_aa ]
        end

        @invocation_reflection.custom_sections do |*x_a|
          p[ x_a ]
        end

        if intr
          intr.finish  # result is t/f of any
        else
          NOTHING_
        end
      end
    end
  end
end
