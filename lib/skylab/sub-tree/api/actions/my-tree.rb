module Skylab::SubTree

  class API::Actions::My_Tree

    SubTree::Lib_::Enhance_as_API_normalizer[ self, :all ]

    Lib_::Basic_fields[ :client, self,
      :absorber, :absrb_iambic_fully,
      :passive, :absorber, :absorb_iambic_passively,  # until [#mh-067]
      :field_i_a, [ :expression_agent, :program_name, :param_h,
                    :upstream, :paystream, :infostream ] ]

    VERBOSE_SET_A = [ 'find command', 'lines' ].freeze
    VSA_ = [ 'v', * VERBOSE_SET_A.map { |str| str[ 0 ] } ].freeze
    Build_vtuple_ = -> do
      p = -> do
        Vtuple_ = ::Struct.new( :volume, *
          VERBOSE_SET_A.map { |s| :"#{ s.gsub SPACE_, '_' }" } )
        (( p = -> { Vtuple_.new 0 } ))[]
      end
      -> { p.call }
    end.call
    Normalize_verbose_flags = -> y, x, p do      # x = [ 'fl', 'l', 'f' ] etc
      vt = Build_vtuple_[] ; xtra_a = nil
      x and x.each do |str|
        str ||= 'v'                              # then '-v' bare
        str.split( '' ).each do |s|
          if (( idx = VSA_.index s ))
            if vt[ idx ] then vt[ idx ] += 1 else vt[ idx ] = 1 end
          else ( xtra_a ||= [ ] ) << s end
        end
      end
      if xtra_a
        rest_a =
        (1...(VSA_.length)).reduce( [] ) { |m, d| vt[d] or m << VSA_[ d ] ; m }
        rest_a.unshift VSA_[ 0 ]
        bad = xtra_a * ''
        @expression_agent.calculate do
          y << "#{ ick bad } #{ s bad.length, :is } not #{ s :a}valid letter#{
            }#{ s } for #{ par :verbose } - expecting #{
            }#{ or_ rest_a.map( & method( :ick ) ) }"
        end
      else
        p[ vt ]
      end
      nil  # when field is optional, response "shouldn't" matter
    end

    SubTree::Lib_::API_Params[ :client, self,

      :meta_param, :extension,

      :param, :path_a, :arity, :one_or_more,

      :param, :file, :arity, :zero_or_one,
        :desc, -> y do
          y << "instead of #{ par :path_a }s, get tree paths from #{
            }file, one per line"
        end,

      :param, :line_count, :arity, :zero_or_one, :argument_arity,
        :zero, :extension, :desc, "as reported by wc, affixed as metadata",

      :param, :mtime, :arity, :zero_or_one, :argument_arity, :zero,
        :extension, :desc, "if ordinary file, display humanized mtime",

      :param, :pattern, :arity, :zero_or_one, :argument_arity, :one,
        :single_letter, 'P', :desc, -> y do
          y << "reduce the search with this pattern (passsed to `find -name`)"
        end,

      :param, :verbose, :arity, :zero_or_more, :argument_arity, :one,
        :argument_string, " [#{ VSA_ * '|' }]", :desc, -> y do
          hilite_first = -> s { "#{ kbd s[0] }#{ s[1..-1] }" }
          y << "verbose #{ VERBOSE_SET_A.map( & hilite_first ) * ', ' } #{
           }(any permutation - bitmask-like)"
          y << "#{ kbd 'v' } adds volume for generic msgs, e.g \"-vflvv\""
        end, :normalizer, Normalize_verbose_flags    ]

    def write_option_parser_to o
      ex_ag = some_expression_agent
      SubTree::Lib_::Write_isomorphic_option_parser_options[
        :field_box, field_box, :any_expression_agent, ex_ag,
        :param_h, order_proxy, :op, o ]
      ex_ag.instance_exec do
        o.separator "   (it can also read paths from STDIN instead of #{
          }#{ par :file } or #{ par :path_a })"
      end
      nil
    end

    def with_properties * x_a
      absrb_iambic_fully x_a
      self  # #allow-chaining
    end

    def with_parameters * x_a
      h = order_proxy
      0.step( x_a.length - 1, 2 ).each do |i|
        h[ x_a[ i ] ] = x_a[ i + 1 ]
      end
      self  # #allow-chaining
    end

  private
    def order_proxy
      @order_proxy ||= bld_order_proxy
    end
    def bld_order_proxy
      Lib_::Order_proxy[ @param_h ]
    end


    def initialize
      @exit_status_p = nil
    end

  public
    def execute
      begin
        r = resolve_upstream_from_i_and_OK or break
        r = resolve_extensions or break
        @traversal = self.class::Traversal_.new(
          :info_p, @infostream.method( :puts ),
          :do_verbose_lines, @verbose.lines )
        traverse
        @exit_status_p and mention_exit_status
        r = true
      end while nil
      r
    end

    def resolve_upstream_from_i_and_OK
      i = Upstream_resolver_[ @upstream, @path_a, @file, @pattern,
        method( :mention ),
        -> io { @upstream = io },
        -> find_cmd_str do
          @verbose.find_command and mention find_cmd_str
        end, -> p do
          @exit_status_p = p
        end
      ]
      i and @resolve_upstream_from_i = i and true
    end

    def traverse
      if @extensions
        if @extensions.has_post_notifiees
          traverse_via_triple_buffer
        else
          traverse_with_notification
        end
      else
        traverse_direct
      end
      nil
    end

    def traverse_direct
      t = @traversal ; u = @upstream ; line = nil
      t.with :out_p, @paystream.method( :puts )
      t.puts line while (( line = u.gets ))
      close_upstream_and_flush_traversal
      true
    end

    def close_upstream_and_flush_traversal
      close_upstream
      @traversal.flush ; nil
    end

    def close_upstream
      @upstream.tty? or @upstream.close
      nil
    end

    def traverse_with_notification  # assume extensions
      u = @upstream ; t = @traversal
      t.with :out_p, @paystream.method( :puts )
      while (( line = u.gets ))
        line.chomp!
        lf = Leaf_.new line
        @extensions.any_in_notify_notify lf
        t.puts_with_free_cel lf.input_line, lf.any_free_cel
      end
      close_upstream_and_flush_traversal
      nil
    end

    def traverse_via_triple_buffer  # assume extensions
      u = @upstream ; t = @traversal ; row_a = [ ]
      t.with :out_p, -> glyphs, slug, any_leaf do
        row_a << Row_.new( glyphs, slug, any_leaf )
        nil
      end
      while (( line = u.gets ))
        line.chomp!
        lf = Leaf_.new line
        @extensions.any_in_notify_notify lf
        t.puts_with_free_cel lf.input_line, lf
      end
      close_upstream_and_flush_traversal
      @extensions.post_notify_notify row_a
      self.class::Render_table_[ @paystream, row_a ]
      nil
    end
    #
    Row_ = ::Struct.new :glyphs, :slug, :any_leaf

    def mention_exit_status
      if @exit_status_p and 1 <= @verbose.volume
        mention "(exitstauts #{ @exit_status_p[] })"
      end
    end

    #  ~ extension support ~

    def resolve_extensions
      ext_a = field_box.which( & :is_extension ).to_a
      opt_order_i_a = @order_proxy.aset_k_a.uniq ; @order_proxy = nil
      # (if the field arities are set right, should be unique already anyway)
      order_i_a = opt_order_i_a & ext_a.map( & :local_normal_name )
      if order_i_a.length.zero?
        @extensions = nil
        true
      else
        init_extensions order_i_a
      end
    end

    def init_extensions order_i_a
      bx = Lib_::Box[]
      bound = Lib_::Bound_field_reflection_class[]
      order_i_a.each do |i|
        fld = field_box.fetch i
        bf = bound.new fld, -> { instance_variable_get fld.as_host_ivar }
        bx.add bf.local_normal_name, bf
      end

      is_valid, @extensions =
        self.class::Extensions_.new(
          :arg_box, bx, :infostream, @infostream, :verbose, @verbose ).
            is_valid_and_valid_self
      is_valid
    end

    #  ~ abstraction candidates ~

  public

    def field_box
      self.class::FIELDS_
    end

  private

    def bork x
      mention x
      false
    end

    def mention x
      p = x.respond_to?( :call ) ? x : -> { x }
      msg = some_expression_agent.calculate( & p )
      @infostream.puts msg
      nil
    end

    def some_expression_agent
      @expression_agent || self.class::EXPRESSION_AGENT_
    end

    alias_method :any_expression_agent, :some_expression_agent

    class Upstream_resolver_ < Lib_::Struct[ :upstream, :path_a, :file,
      :pattern, :say_p_p, :change_upstream_p, :cmd_s_p, :exit_status_p_p ]

      Lib_::Funcy_globful[ self ]

      def execute
        have_a = [ ]
        ( ! @upstream || @upstream.tty? ) or have_a << :stdin
        @path_a[ 0 ] and have_a << :path
        @file and have_a << :file
        case have_a.length
        when 0 ; bork "no input"
        when 1 ; from_one( have_a.fetch 0 )
        else   ; bork -> do
            "can't read input from #{ both have_a }#{
              }#{ and_ have_a.map( & method( :par ) ) }"
          end
        end
      end

    private

      def from_one i
        @from_i = i
        send RUFH_.fetch( i ) and i
      end
      #
      RUFH_ = { stdin: :resolve_upstream_from_stdin,
                 file: :resolve_upstream_from_file,
                 path: :resolve_upstream_from_path }.freeze

      def resolve_upstream_from_stdin
        ensure_no_pattern
      end

      def ensure_no_pattern
        if ! @pattern then true else
          i = @some_i
          bork -> do
            "can't use #{ par :pattern } with #{ par i }, #{
              }only #{ par :path }"
          end
        end
      end

      def resolve_upstream_from_file
        if ensure_no_pattern
          @change_upstream_p[ ::File.open @file, 'r' ]
          true
        end
      end

      def resolve_upstream_from_path
        cmd = SubTree::Find_Command_.new
        cmd.concat_paths @path_a
        @pattern and cmd.set_pattern_s @pattern
        if ! (( cmd_s = cmd.string )) then false else
          @cmd_s_p[ cmd_s ]
          i, o, e, t = SubTree::Library_::Open3.popen3 cmd_s
          i.close
          if (( s = e.read )) && '' != s
            o.close
            bork "#{ s.chomp } (exitstatus #{ t.value.exitstatus })"
          else
            e.close
            @exit_status_p_p[ -> { t.value.exitstatus } ]
            @change_upstream_p[ o ]
            true
          end
        end
      end

      def bork s_or_p
        p = s_or_p.respond_to?( :ascii_only? ) ? -> { s_or_p } : s_or_p
        @say_p_p[ p ]
        false
      end
    end
  end
end
