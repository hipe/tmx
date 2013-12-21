module Skylab::Headless

  module CLI

    module Action

      module IMs  # see [#064] the CLI action core instance m.. #storypoint-5

        include Headless::Action::IMs

        def initialize * _
          @has_od = @option_parser = @param_queue_a = nil
          @upstrm_is_collapsed = nil
          @q_x_a = nil  # #storypoint-10
          super
        end

        def invoke argv  # #storypoint-15
          @argv = argv
          r = parse_opts @argv
          OK_ == r && @param_queue_a and r = absorb_param_queue  # #todo:after-merge
          if OK_ == r
            r = nil ; scn = get_tsk_scnnr
            while true
              task = scn.gets
              task or break
              r = task.receiver.send task.task_method_name, * task.arguments
              unless OK_ == r
                CEASE_X_ == r and r = exitstatus_for_i( :task_ceased )
                break
              end
              task.close
            end
          end
          r
        end
        Action::OK_ = true  # #storypoint-20 because our namespace is sens.
        Action::INVOKE_METHOD_I = :invoke
      private
        def parse_opts a  # #storypoint-25
          if a.length.zero? or is_branch && DASH_ != a[0].getbyte(0) or ! op
            OK_
          else
            prs_opts_from_nonzero_length_argv_when_op a
          end
        end
        # #storypoint-30 ugly names are used here
        def option_prsr  # :#API-private
          op
        end ; protected :option_prsr
        def op  # #storypoint-35
          @option_parser.nil? and @option_parser = build_option_parser || false
          @option_parser
        end
        def build_option_parser
          if self.class.respond_to? :any_option_parser_p_a and
              (( p_a = self.class.any_option_parser_p_a ))
            op = begin_option_parser
            apply_p_a_on_op p_a, op
            op
          end
        end
        def apply_p_a_on_op p_a, op
          p_a.each do |p|
            instance_exec op, & p
          end ; nil
        end
        def begin_option_parser
          op = option_parser_cls.new
          op.base.long.clear  # never use builtin 'officious' -v, -h  # [#059]
          op
        end ; protected :begin_option_parser
        def option_parser_cls
          Headless::Services::OptionParser
        end
        def prs_opts_from_nonzero_length_argv_when_op a
          @option_parser.parse! a do |p|
            instance_exec( & p )  # :#hook-in for custom o.p
          end ; OK_
        rescue Headless::Services::OptionParser::ParseError => e
          prs_opts_when_parse_error e
        end
        def prs_opts_when_parse_error e
          usage_and_invite e.message
          exitstatus_for_i :parse_opts_failed
        end

        # ~ leaving o.p facility and entering the rendering facility

        def usage_and_invite msg=nil, z=nil  # #storypoint-50, :#hook-in
          y = help_yielder
          msg and y << msg
          render_usg_lns y
          y << invite_line( z )
          CEASE_X_
        end

        def help_yielder  # #storypoint-55 :#public-API
          @help_yielder ||= bld_hlp_yldr
        end

        def bld_hlp_yldr
          ::Enumerator::Yielder.new( & emit_help_line_p )
        end

        def emit_help_line_p  # ~ #storypoint-65, the emitter methods
          @emit_help_line_p ||= @request_client.emit_help_line_p
        end

        def emit_error_line s
          emit_info_line s
        end

        def emit_info_line s
          emit_info_line_p[ s ]
        end

        def emit_payload_line s
          emit_payload_line_p[ s ]
        end

        def emit_info_line_p
          @emit_info_line_p ||= @request_client.emit_info_line_p
        end

        def emit_payload_line_p
          @emit_payload_line_p ||= @request_client.emit_payload_line_p
        end

        def render_usg_lns y
          s = usage_line and y << s ; nil
        end

        def usage_line  # #storypoint-90 :#public-API
          y = [] ; y << stlz_hdr( say :usg )
          y << normalized_invocation_string
          s = render_option_syntax and y << s
          s = rndr_arg_stx_term and y << s
          y.compact * TERM_SEPARATOR_STRING_
        end

        def stlz_hdr header_s
          s = frmt_hdr_s header_s
          say { em s }
        end
        alias_method :stylize_hdr, :stlz_hdr  # #storypoint-100

        def frmt_hdr_s header_s
          "#{ header_s }#{ COLON__ unless COLON__ == header_s[ -1 ] }"
        end
        Action::COLON__ = ':'.freeze

        #  ~ stepping into expressing agent facility for a moment

        def say * a, &p  # #storypoint-105 (pinned to first call)
          if p
            expression_agent.calculate( * a, & p )
          else
            say_with_lxcn( * a )
          end
        end

        def expression_agent
          pen  # #outstream-jump
        end

        def lexical_vals_at * i_a
          lxcn.fetch_default_values_at_i_a i_a
        end

        def say_with_lxcn i
          lxcn.fetch_default i
        end

        def lxcn  # stub implementation
          LEXICON__  # defined near at first write
        end

        CLI::Action::LEXICON__ = class Action::Lexicon__  # #storypoint-155
          def initialize
            @bx = Headless::Services::Basic::Box.new
            @is_collapsed = false ; @p_a = [] ; nil
          end
          def fetch_default_values_at_i_a i_a
            @is_collapsed or collapse
            i_a.map( & @bx.method( :fetch ) )
          end
          def fetch_default i, &p
            @is_collapsed or collapse
            @bx.fetch i, &p
          end
          def add &p
            @is_collapsed = false ; @p_a << p ; nil
          end
          def add_entry_with_default i, s
            @bx.add i, s.freeze ; nil
          end
        private
          def collapse
            @is_collapsed = true
            d = -1 ; len = @p_a.length ; last = len - 1  # assume..
            while d < last
              @p_a.fetch( d += 1 )[ self ]
            end
            @p_a[ 0, len ] = MetaHell::EMPTY_A_ ; nil
          end
          self
        end.new

        LEXICON__.add do |lx|
          lx.add_entry_with_default :usg, 'usage'
          lx.add_entry_with_default :SHRT_HLP_SW, '-h'
          lx.add_entry_with_default :LNG_HLP_SW, '--help'
          lx.add_entry_with_default :THS_SCRN, 'this screen'
        end

        # ~ stepping out of exag. facility and into the name facility

      public  # #todo:during-client-services

        def normalized_invocation_string  # #storypoint-205 (placeholder)
          normalized_invocation_string_prts( y = [] )
          y * TERM_SEPARATOR_STRING_
        end

        def normalized_invocation_string_prts y
          request_client.normalized_invocation_string_prts y
          y << name.as_slug ; nil
        end

        def name  # see also the 'anchored-name' bundle
          @name_function ||= bld_name_func
        end
      private
        def bld_name_func
          Headless::Name::Function::From::Constant.from_name self.class.name
        end

        # ~ stepping out of names and into o.p rendering

        def render_option_syntax
          has_op_docmtr and rndr_opt_sntx_when_option_documenter
        end

        def has_op_docmtr
          @has_od.nil? and @has_od = !! option_documenter
          @has_od
        end

        def option_documenter  # #storypoint-315 :#hook-in
          op
        end

        def rndr_opt_sntx_when_option_documenter
          a = visible_ops.reduce [] do |m, sw|
            s = render_option_parser_switch( sw ) and m << s ; m
          end
          a.length.nonzero? and a * TERM_SEPARATOR_STRING_
        end

        def visible_ops  # #storypoint-320
          ::Enumerator.new do |y|
            p = swtch_wth_obj_id_is_visible_p
            CLI::Option::Enumerator.new( option_documenter ).each do |sw|
              sw.respond_to?( :short ) && p[ sw.object_id ] and y << sw
            end ; nil
          end
        end

        def do_not_render_switch_in_stx_str sw  # :#storypoint-325
          swtch_wth_obj_id_is_visible_p[ sw.object_id ] = false ; nil
        end

        def swtch_wth_obj_id_is_visible_p
          @non_rndrd_switches_h ||= ::Hash.new { |*| true }
        end

        def render_option_parser_switch sw  # #storypoint-335 :#hook-in
          (( a = sw.short )) and _s = a.first
          _s ||= (( a = sw.long )) && a.first
          _s && "[#{ _s }#{ sw.arg }]"
        end

        # ~ stepping out of o.p rendering and into argument parsing facility
        # #storypoint-450 arg parsing introduction

        def rndr_arg_stx_term
          render_argument_stx argument_stx
        end

        def argument_stx  # #storypoint-410
          i = peek_any_last_queue_elmnt_i
          i ||= default_action_i
          i and argument_syntax_for_action_i i
        end

        def peek_any_last_queue_elmnt_i
          q_for_rd.peek_any_last_element_i
        end

        def peek_any_queue_elmnt_i
          q_for_rd.peek_any_element_i
        end

        def q_for_wrt
          @queue ||= bld_q_for_wrt
        end

        def q_for_rd
          @queue ||= bld_q_for_rd
        end

        def queue_len
          ds_have_any_q ? @q_x_a.length : 0
        end

        def ds_have_any_q
          @q_x_a
        end

        def bld_q_for_wrt
          @q_x_a ||= bld_initial_queue
          CLI::Action::Queue__.new @q_x_a
        end

        def bld_q_for_rd
          @q_x_a ||= bld_default_queue
          CLI::Action::Queue__.new @q_x_a
        end

        def argument_syntax_for_action_i meth_x  # #storypoint-415 :#hook-in
          meth_i = meth_x.intern
          arg_stx_cache_h.fetch meth_i do
            @argument_syntax_cache_h[ meth_i ] = build_arg_stx meth_i
          end
        end

        def arg_stx_cache_h  # #storypoint-425
          @argument_syntax_cache_h ||= { }
        end

        def build_arg_stx meth_i
          Headless::CLI::Argument::Syntax::Isomorphic.
            new method( meth_i ).parameters, formal_parameters  # f.p nil ok
        end

        def render_argument_stx stx, em_range=nil  # #storypoint-435
          y = [] ; render_base_arg_stx_prts y, stx, em_range
          apnd_any_cstm_stx y
          y.length.nonzero? and y * TERM_SEPARATOR_STRING_
        end

        def render_base_arg_stx_prts y, stx, em_range=nil
          stx.each_argument.with_index do |arg, d|
            s = if em_range and em_range.include? d
              rndr_arg_w_emphs arg
            else
              render_arg_txt arg
            end
            s and y << s
          end ; nil
        end

        def rndr_arg_w_emphs arg
          s = render_arg_txt arg
          s and say { em s }
        end

        def render_arg_txt arg  # #storypoint-450
          a, b = rndr_rqty_brckts arg.reqity
          if arg.is_atomic_variable
            "#{ a }<#{ arg.as_slug }>#{ b }"
          elsif arg.is_collection
            "#{ a }#{ arg.render_under self }#{ b }"  # #todo:during-merge exag
          else
            "#{ a }#{ arg.as_moniker }#{ b }"
          end
        end

        def rndr_rqty_brckts reqity_i
          CLI::Argument::FUN::Reqity_brackets[ reqity_i ]
        end

        def apnd_any_cstm_stx y  # #storypoint-460
          if self.class.respond_to? :append_syntax_a
            a = self.class.append_syntax_a
          end
          a and y.concat a ; nil
        end

        # ~ this completes the four-step narrative started at #storypoint-60
        # ~ and then this picks back up with #storypoint-50

        def invite_line z=nil  # #storypoint-605
          render_invite_line "#{ normalized_invocation_string } -h", z
        end ; public :invite_line

        def render_invite_line inner_string, z=nil  # #storypoint-610 :#hook-in
          say do
            "use #{ kbd inner_string } for help#{
              "#{ TERM_SEPARATOR_STRING_ }#{ z }" if z }"
          end  # [#124] #i18n challenge
        end

        # ~ this brings us back to opt parsing, the inside of #storypoint-25

        def exitstatus_for_i _  # #storypoint-705 :#hook-in
          CEASE_X_
        end

        # ~ we are back up to our top: the invocation method #storypoint-10

        def absorb_param_queue  # #storypoint-755, #storypoint-760, :#hook-in
          befor = @error_count ; a = @param_queue_a
          while a.length.nonzero?
            i, x = a.shift
            send :"#{ i }=", x
          end
          befor == @error_count and OK_
        end

        def get_tsk_scnnr  # #storypoint-805
          p = -> do
            @q_x_a ||= bld_default_queue
            task = Bound_Task__.new nil, nil, -> do  # #flyweight
              _has_more = release_some_queue_elmnt
              _has_more or p = MetaHell::EMPTY_P_
              nil
            end
            p = -> do
              x = peek_some_queue_elmnt_x
              x_, bnd_mth, arg_a = resolve_call_tuple_from_queue_element_x x
              if OK_ == x_
                task.replace bnd_mth, arg_a ; task
              else
                Value_As_Task__[ x_ ]
              end
            end ; p[]
          end
          Scn_.new { p[] }
        end

        def th_q_has_exactly_one_item
          1 == @q_x_a.length
        end

        def enqueue x  # #storypoint-10 (again)
          (( @q_x_a ||= bld_initial_queue )) << x ; nil
        end

        def enqueue_without_initial_queue x  # #todo:after-merge:01
          puff_queue_without_initial_queue
          @q_x_a << x ; nil
        end

        def puff_queue_without_initial_queue  # #todo:after-merge:01
          @q_x_a ||= [] ; nil
        end

        def bld_default_queue
          bld_initial_queue << default_action_i
        end

        def bld_initial_queue
          [ :rslv_upstream ]  # #todo:after-merge:01
        end

        def rslv_upstream
          @upstrm_is_collapsed ? @upstrm_status_x : cllps_upstream
        end

        def cllps_upstream
          @upstrm_is_collapsed = true
          ok, x = resolve_upstream_status_tuple
          @upstrm_status_x = case ok when PROCEDE_X_, CEASE_X_ ; ok else x end
        end

        def resolve_upstream_status_tuple  # #storypoint-835
          OK_
        end

        def release_some_queue_elmnt
          case 1 <=> @q_x_a.length
          when -1 ; @q_x_a.shift ; true
          when  0 ; @q_x_a.shift ; false
          when  1 ; raise "sanity - task close called with queue empty" end
        end

        def peek_some_queue_elmnt_x
          @q_x_a.fetch 0
        end

        class Action::Bound_Task__ < Headless::Services::Basic::Method::Curry
          alias_method :replace, :initialize ; public :replace
          def initialize bm, arg_a, p
            super bm, arg_a ; @p = p ; nil
          end
          alias_method :task_method_name, :method_name
          def close
            @p.call
          end
          MetaHell::MAARS::Upwards[ self ]
        end

        Action::Value_As_Task__ = -> x do
          bt = Bound_Task__.new nil, nil, -> { x }
          bt.replace bt.method( :close ), nil
          bt
        end

        def resolve_call_tuple_from_queue_element_x x  # #storypoint-815
          if x.respond_to? :id2name
            th_q_has_exactly_one_item and a = release_any_argv
            a ||= MetaHell::EMPTY_A_
            rslv_call_tuple_from_method_i_and_args x, a
          else
            q_for_rd.begin_dequeue self
          end
        end

        def release_any_argv  # :#API-private
          if @argv
            a = @argv.dup ; @argv.clear ; @argv = nil ; a
          end
        end ; public :release_any_argv

        def rslv_call_tuple_from_method_i_and_args i, a
          r = vldt_arity_for i, a
          if OK_ == r
            [ OK_, method( i ), a ]
          else
            [ r ]
          end
        end

        # ~ step into the arguments facility

        def vldt_arity_for meth_i, args  # #storypoint-905
          r = argument_syntax_for_action_i meth_i
          r and w_arg_stx_process_args r, args
        end

        def with_arg_stx_prcss_args stx, a
          w_arg_stx_process_args stx, a
        end ; public :with_arg_stx_prcss_args

        def w_arg_stx_process_args stx, args  # #storypoint-910
          stx.process_args args do |o|
            o.on_missing method :hndl_missing_args
            o.on_result_struct method :hndl_args_result_struct
            o.on_extra method :hndl_unexpected_args
          end
        end

        def hndl_missing_args e
          send HMA_OP_H__.fetch( e.orientation_i ), e
        end
        #
        Action::HMA_OP_H__ = { vertical: :hndl_missing_args_vertical,
          horizontal: :hndl_missing_args_horizontal }.freeze

        def hndl_missing_args_vertical e
          usage_and_invite "expecting: #{ rndr_expecting_term e }"
          exitstatus_for_i :argv_parse_failure_missing_required_arguments
        end

        def rndr_expecting_term e  # #storypoint-920
          ss = e.syntax_slice ; stx = e.any_full_syntax
          arg = ss.first_argument
          missing_idx = arg.syntax_index_d
          a = [ arg ]
          ( missing_idx - 1 ).downto( 0 ).each do |d|  # neg ok
            arg_ = stx[ d ]
            :req == arg_.reqity and break
            a.unshift arg_
          end
          local_emph_idx = a.length - 1
          _my_slice = ss.class.new a  # eek
          render_argument_stx _my_slice, ( local_emph_idx .. local_emph_idx )
        end

        def hndl_missing_args_horizontal e
          y = [ ]
          e.syntax_slice.each do |arg|
            x = if arg.is_literal then "`#{ arg.as_moniker }`"
            else render_arg_txt arg end
            x and y << x
          end
          _s = render_grp_s_a_as_i y, :alternation
          if (( token_set = e.any_at_token_set ))
            1 == token_set.length or fail 'test me'
            _near_s = " at #{ ick token_set.to_a.first }"
          end
          usage_and_invite "expecting { #{ _s } }#{ _near_s }"
          exitstatus_for_i :argv_parse_failure_missing_required_arguments
        end

        def render_grp_s_a_as_i a, i
          a * CLI::Action::SEPARATOR_GLYPH_H__.fetch( i )
        end ; public :render_grp_s_a_as_i
        #
        CLI::Action::SEPARATOR_GLYPH_H__ = {
          series: TERM_SEPARATOR_STRING_,
          alternation: '|' }.freeze

        def hndl_args_result_struct st
          absrb_rslt_struct_into_param_h st
        end

        def absrb_rslt_struct_into_param_h st
          st.members.each { |i| @param_h[ i ] = st[ i ] } ; nil
        end

        def hndl_unexpected_args e
          _ = say_xtra_args e
          usage_and_invite _
          exitstatus_for_i :argv_parse_failure_unexpected_arguments
        end

        def say_xtra_args e
          a = e.s_a
          say do
            _ellips = ' [..]' if a.length > 1
            "unexpected argument#{ s a }: #{ ick a.first }#{ _ellips }"
          end
        end

        # ~ end of narrative

        # ~ #storypoint-1005 the help facility introduction

        def help  # #storypoint-1010 :#public-API
          replace_queue_head_wth_i default_action_i
          help_screen help_yielder
        end

        def replace_queue_head_wth_i i
          @q_x_a[ 0 ] = i ; nil
        end

        def help_screen y  # :+#public-API
          render_usg_lns y
          render_any_hlp_dsc y
          render_any_hlp_opts y
          render_any_hlp_sects y
          render_any_hlp_addtn y
          PROCEDE_X_
        end ; protected :help_screen  # #protected-not-private

        def render_any_hlp_addtn y
        end

        def render_any_hlp_dsc y
          has_dsc_lines and help_description y
        end

        def has_dsc_lines  # #storypoint-1020
          node_stry.has_nonzero_desc_lines
        end

        def node_stry
          @node_stry ||= build_node_stry
        end

        def build_node_stry
          CLI::Action::Desc::Story[ self ]
        end

      public

        def any_description_p_a_for_stry
          if self.class.respond_to? :any_description_p_a
            self.class.any_description_p_a
          end
        end

        def add_any_supplemental_sections_for_stry _
        end

      private

        def help_description y  # #storypoint-1050
          y << EMPTY_STRING_  # #assume-previous-line-above
          case @node_stry.desc_lines_count <=> 1
          when  0 ; s = render_single_description_line and y << s
          when  1 ; render_multiline_description y ; nil ; end
        end

        def render_single_description_line  # assume the ivar
          render_single_line_with_header_and_string(
            say( :dsc ), @node_stry.fetch_first_desc_line )
        end

        LEXICON__.add_entry_with_default :dsc, 'description'

        def render_single_line_with_header_and_string header_s, s
          y = []
          header_s and y << stlz_hdr( header_s )
          s and y << s
          y.length.nonzero? and y * TERM_SEPARATOR_STRING_
        end

        def render_multiline_description y  # assume the ivar
          render_multiline_section_with_header_and_lines y,
            say( :dsc ), @node_stry.desc_lines
        end

        def render_multiline_section_with_header_and_lines y, header_s, lines
          indent_s = some_summary_indent_s
          header_s and y << stlz_hdr( header_s )
          lines.each do |line|
            y << "#{ indent_s }#{ line }"
          end ; nil
        end

        def some_summary_indent_s
          @summary_indent_s ||= rslv_some_summary_indent_s
        end

        def rslv_some_summary_indent_s
          has_op_docmtr and si = option_documenter.summary_indent
          si || DEFAULT_SUMMARY_INDENT__
        end

        Action::DEFAULT_SUMMARY_INDENT__ = ( TERM_SEPARATOR_STRING_ * 2 ).freeze

        def render_any_hlp_opts y
          if has_op_docmtr
            rndr_hlp_opts y
          end ; nil
        end

        def rndr_hlp_opts y
          od = option_documenter
          _w = Action::FUN::Summary_width[ od, col_A_mx_wdth ]
          od.summary_width = _w
          help_options y
        end

        def col_A_mx_wdth
          @col_A_mx_wdth ||= rslv_col_A_mx_wdth
        end

        def rslv_col_A_mx_wdth  # #storypoint-1085
          if node_stry.has_nonzero_sections
            rslv_col_A_mx_wdth_when_sections
          else 0 end
        end

        def rslv_col_A_mx_wdth_when_sections
          @node_stry.sections.reduce 1 do |m, sect|
            if (( a = sect.any_nonzero_length_line_a ))
              m = a.reduce m do |m_, row_a|
                row = row_a.first
                ( row && row.length > m_ ) ? row.length : m_
              end
            end ; m
          end
        end

        def help_options y  # #storypoint-1095, assume o.d
          y << EMPTY_STRING_  # #assume-previous-line-above
          op = option_documenter
          _will_summarize = op.top.list.detect do |x|
            x.respond_to? :summarize
          end
          if _will_summarize
            y << stlz_hdr( say :optns )
          end
          op.summarize do |line|
            y << line
          end ; nil
        end

        LEXICON__.add do |lxc|
          lxc.add_entry_with_default :optns, 'options'
        end

        def render_any_hlp_sects y
          if node_stry.has_nonzero_sections
            rndr_some_help_sections y ; nil
          end
        end

        def rndr_some_help_sections y
          rnd = bld_hlp_sct_rndrr y
          scn = @node_stry.get_section_scanner
          while (( section = scn.gets ))
            rnd << section
          end ; nil
        end

        def bld_hlp_sct_rndrr y
          Help_Section_Renderer__.new :y, y,
            :expr_ag, pen,
            :mx_width, col_A_mx_wdth,
            :option_docr, option_documenter,
            :smmry_indent_s, some_summary_indent_s,
            :stlz_hdr_p, method( :stlz_hdr )
        end

        class Action::Help_Section_Renderer__
          def initialize * x_a
            begin
              i, x = x_a.shift 2
              instance_variable_set :"@#{ i }", x
            end while x_a.length.nonzero?
            bake ; nil
          end
        private
          def bake
            sw = resolve_summary_width ; fmt = "%-#{ sw }s"
            ind = @smmry_indent_s ; y = @y
            op_h = @expr_ag.calculate do {
              line: -> a { y << a[ 1 ] },
              item:  -> a do
                if a[ 1 ]
                  if a[ 2 ]
                    y << "#{ ind }#{ h2( fmt % a[ 1 ] ) }#{ a[ 2 ] }"
                  else
                    y << "#{ ind }#{ h2 a[ 1 ] }"
                  end
                else
                  y << "#{ ind }#{ fmt % EMPTY_STRING_ }#{ a[ 2 ] }"
                end
              end }
            end
            @line_type_op_h = op_h ; nil
          end
          def resolve_summary_width
            if @option_docr
              @option_docr.summary_width + 1
            else
              @mx_width
            end
          end
        public
          def << section
            @y << EMPTY_STRING_  # #assume-previous-line-above
            s = section.header and @y << "#{ @stlz_hdr_p[ s ] }"
            section.lines.each do |line|
              @line_type_op_h.fetch( line.first )[ line ]
            end ; nil
          end
        end

        # ~ #storypoint-1105 acting like a child

        def some_summary_ln  #storypoint-1110 :+#API-private
          if node_stry.has_nonzero_desc_lines
            @node_stry.fetch_first_desc_line
          elsif has_op_docmtr
            smry_ln_from_op
          end
        end ; public :some_summary_ln

        def smry_ln_from_op
          od = option_documenter
          if (( s = ::String.try_convert od.top.list.first ))
            s_ = CLI::Pen::FUN.unstyle[ s ]
            s_.gsub STRIP_DESCRIPTION_LABEL_RX__, EMPTY_STRING_
          else
            CLI::Pen::FUN.unstyle[ usage_line ]
          end
        end

        Action::STRIP_DESCRIPTION_LABEL_RX__ = /\A[ \t]*description:?[ \t]*/i

        # ~ `parameters` - abstract reflection and rendering

        def par norm_i
          parm = fetch_parameter norm_i
          if parm.is_option
            parm.as_parameter_signifier
          elsif parm.is_argument
            render_arg_txt parm
          end
        end  # #todo:after-merge. this

        def fetch_parameter norm_i, &p
          stx = argument_stx
          stx and r = stx.fetch_parameter( norm_i ) { }
          if ! r and option_parser and @option_parser.respond_to? :fetch_parameter
            r = @option_parser.fetch_parameter norm_i do end
          end
          r or prm_not_found p, norm_i
        end
      private
        def prm_not_found p, norm_i
          (( p || -> do
            raise ::KeyError, "parameter not found: #{ norm_i.inspect }"
          end )).call
        end

        # ~ :#private-API methods not used by this node

        def enqueue_with_args i, * arg_a
          q_for_wrt.enqueue_with_args_notify i, arg_a ; nil
        end

        def peek_any_some_queue_elmnt_i
          ds_have_any_q and q_for_rd.peek_any_some_element_i
        end
      end
    end
  end
end
