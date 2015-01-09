module Skylab::Face

  CLI::Client = ::Class.new ::Class.new  # read [#056] the CLI client narrative

  class CLI::Client

    Namespace_ = superclass

    Client_ = self

    Command_ = ::Class.new

    NS_Kernel_ = ::Class.new Command_

    CLI_Kernel_ = ::Class.new NS_Kernel_

    X_Kernel__ = CLI_Kernel_

    module Lib_

      include CLI::Lib_

      Call_frame_rx = -> do
        p = -> do
          rx = /#{ Callback_::Name.lib.callframe_path_rx.source } :
            (?<no>\d+) : in [ ] ` (?<meth>[^']+) '\z/x
          p = -> { rx } ; rx
        end
        -> { p[] }
      end.call

      CLI_lib = -> do
        HL__[]::CLI
      end
    end

    class Client_  # open for facet 1. #storypoint-40

      def invoke argv  # #storypoint-75
        ok, res, m, a, b, cmd = @mechanics.get_executable argv
        if ok
          begin
            res = res.send m, *a, &b
          rescue ::ArgumentError => ex
            res = @mechanics.argument_error ex, cmd  # see.
          end  # the above call is coupled to its position in the call stack
        end
        res
      end
    end

    class CLI_Kernel_

      -> do

        # normalize [#sl-114] conventional 'sin sout serr'.

        a_len = {
          1 => -> h { h },
          3 => -> sin, sout, serr { { sin: sin, out: sout, err: serr } }
        }

        define_singleton_method :enhance do |surface, a|
          enhance_surface_with_h surface, a_len.fetch( a.length ).call( * a )
        end

      end.call

      class << self
      private

        # ( because of the power, elegance and whatever, we can add and remove
        # arguments to the below list without dire mofo's or consequences )

        def __enhance surface, sin, out, err, program_name, sheet
          mech = new ( sheet || surface.class.story ), surface
          mech.init_cli_surface surface, sin, out, err, program_name
          mech
        end
      end

      def initialize sheet, surface
        super sheet, surface, nil, nil
      end

      #           ~ class section 2 - public instance methods ~

      # `get_executable` - #existential-workhorse #result-is-tuple. this is the
      # work-horsiest workhorse in this whole fiasco.
      # result tuple: ( ok, result_code_or_receiver, method, args, block, cmd )

      def get_executable argv
        node = self ; ok = r = rest = @last_cli_executable = nil
        catch :break_two do
          r = pre_execute or break
          while true
            node.apply_default_argv( argv ) if argv.length.zero? &&
              node.has_default_argv
            argv.length.zero? and break( ok, cmd = true, node )
            if DASH_BYTE_ == argv.fetch( 0 ).getbyte( 0 )
              ok, _ok, r, *rest = node.process_options argv
              _ok or throw :break_two  # this allows an opt to act cmd-like
              argv.length.zero? and break( ok, cmd = true, node )  # repeat!
            end
            ok, r = node.find_command argv
            ok or break
            cmd = r
            do_short_circuit, *_rest = determine_short_circuit cmd, argv
            if do_short_circuit
              r, *rest = _rest
              throw :break_two
            end
            cmd.respond_to? :find_command or break
            node = cmd  # tail-call like
          end
          begin
            ok or break
            ok, _ok, r, *rest = cmd.parse argv
            _ok or break
            ( f = cmd.invocation_proc ) and
              break( r, rest = node, [ :instance_exec, [ argv ], f ] )
            r, rest = node.surface_receiver, [ cmd.method_name, argv, nil, cmd ]
          end while nil
        end
        [ ok, r, *rest ]
      end

      def determine_short_circuit cmd, argv
        # <is-short-circuit> <receiver> <method> <args> <block> <cmd-for-syntax>
        if cmd.respond_to? :invokee
          [ true, cmd.invokee, :invoke, [ argv ], nil, cmd ]
        elsif cmd.is_autonomous
          [ true, * cmd.get_autonomous_quad( argv ), cmd ]
        end
      end

      DASH_BYTE_ = DASH_.getbyte 0

      # `init_cli_surface` #called-by self.class only. [#040] explains it all.
      # so this is that weird place where we fan-out these resources upwards
      # for a moment.

      def init_cli_surface surface, sin, out, err, program_name
        surface.instance_exec do
          @program_name ||= program_name
          @sin ||= sin ; @out ||= out ; @err ||= err
          if @err
            @y ||= ::Enumerator::Yielder.new( & @err.method( :puts ) )
            # (note it's hard to lazy-evaluate anything in the surface shell
            # because of [#037])
          end
        end
        nil
      end

      def pre_execute  # #storypoint-175
        # we override p-arent and do what our grandparent does. meh.
        @y = parent_services[ :y ]
        @last_hot = nil
        true
      end
    end

    class Namespace_  # 1.2 core only (not deep n.s) & support #storypoint-185

      class << self

        attr_reader :story  # #called-by CLI mechanics, and elsewhere

      private

        def inherited kls

          # (because of its placelement and how the child class is written
          # respectively, this won't be called when CLI descends from NS,
          # only when businessland classes descend from either NS or CLI.)

          kls.class_exec do
            @do_track_method_added = true  # location 1 of 3 - this is for
            # the businessland class. needs to be outside of story becuase ..
            ( @story = NS_Sheet_.new self ).add_option_sheet BRANCH_HELP
          end
          nil
        end

        -> do
          h = { as: -> a, rest { a[ 0 ] = rest.shift } }.freeze
          define_method :use do |*x_a|  # #storypoint-210
            p = @do_track_method_added ; @do_track_method_added = false
            x_a.each do | ( svc_i, *rest ) |
              r = [ ]
              while rest.length.nonzero?
                h.fetch( rest.shift )[ r, rest ]
              end
              m, = r
              m ||= svc_i
              define_method m do |*a, &b|
                @mechanics.send svc_i, *a, &b
              end
              private m
            end
            @do_track_method_added = p
            nil
          end
        end.call
      end

      #    ~ class section 2 - the only instance method (which is private) ~

      def initialize *a

        block_given? and raise ::ArgumentError, "this crap comes back after #100"

        @mechanics ||= ( if self.class.const_defined? :Kernel_, false
          self.class.const_get :Kernel_, false
        else
          self.class.const_set :Kernel_,
            ::Class.new( self.class::X_Kernel__ )
        end ).enhance( self, a )  # (`enhance` rabbit hole begins!)

        # #storypoint-240

        nil
      end

      # note there are no public (and only 1 private) instance method defined.

      Autoloader_[ self ]
    end

    Node_Sheet_ = ::Class.new

    class NS_Sheet_ < Node_Sheet_  # for facet 1, #storypoint-250

      def initialize surface_mod
        @name = nil  # (in a couple places now we check if it is set ..)
        if surface_mod  # no surface mod is bound "statically" when e.g we
          # have a strange module loaded by a function lazily, or if an inline
          # n-amespace is defined with a block (these all happen elsewhere)
          # watch for this becoming a case for two child classes of a shared
          # base class..

          @box = Callback_::Box.new

          @surface_mod = -> { surface_mod }
          @surface_mod_origin_i = :module
          @node_open = false ; @methods_need_to_be_indexed = true
          @has_prenatals = false
          @skip_h = { }  # sad
          @scooper = Scooper_.new -> m do
            close_node do |cl|
              cl.set_method_name m
            end
          end
          define_singleton_method :method_was_added, & @scooper.get_method_added
        end
      end

      #               ~ class section 1 - public instance methods ~

      def is_prenatal  # see parent class
        false
      end

      def command_tree  # #called-by documenters, everything
        if @methods_need_to_be_indexed || @has_prenatals
          black_a, white_h = @scooper.get_black_a_and_white_h
          existing, add, flush = if @has_prenatals
            lift_prenatals
          else
            [ @box.get_names ]
          end
          if @methods_need_to_be_indexed
            @methods_need_to_be_indexed = false
            addme = @surface_mod.call.public_instance_methods( false ) -
              existing - black_a
            addme.each do |i|
              cs = Cmd_Sheet_.new i
              add && add[ i, cs ] or @box.add( i, cs )
            end
          end
          flush and flush[]
          @box.algorithms.mutate_by_sorting_name_by do | i |
            white_h.fetch i do
              raise ::KeyError, "element (n#{ }amespace?) name not found in #{
                }order list (#{ i.inspect } in #{ white_h.keys.inspect })"
            end
          end
        end
        @box.length.zero? ? false : @box
      end

      attr_reader :node_open

      def close_node &blk
        n = @node_open ; @node_open = nil ; blk[ n ]
        ln = n.name.as_variegated_symbol
        otr = @box[ ln ]
        if otr && otr.is_prenatal  # else let the error trigger
          @box.replace ln, nil  # sanity, `natalize`
          n.subsume otr
          @box.replace ln, n
        else
          @box.add ln, n
        end
        nil
      end

      def node_open!  # #called-by e.g n.s for adding aliases
        @node_open ||= Cmd_Sheet_.new nil  # no method name yet.
      end

      def _scooper  # #called-by facets only, and here. for hacks & experiments.
        @scooper
      end

      def if_constituent norm_i, yes, no  # #exposed-for-hacks #todo:cover
        @box.algorithms.if_has_name norm_i, yes, no
      end

      def fetch_constituent norm_i, &no  # #called-by api facet, hacks
        @box.fetch norm_i, &no
      end
    end

    class NS_Kernel_  # #re-open for facet 1, #storypoint-335

      #           ~ class section 1 - singleton methods ~

      class << self
      private
        def enhance_surface_with_h surface, h  # mutates h!  part of "extremely clever" above
          a = method( :__enhance ).parameters[ 1 .. -1 ].reduce [] do |m, (_, i)|
            m << h.delete( i )  # (yes it's just a map. but map would bloat?)
            m
          end
          # (for those of you tuning in at home, n-amespace/facet.rb?)
          h.keys.length.nonzero? and raise ::ArgumentError, "is #{
            }#{ self.name } supposed to handle (#{ h.keys * ', ' })?"
          __enhance surface, *a
        end
      end

      def initialize sheet, surface, parent_services, slug_fragment
        @surface = -> { surface }  # a n-amespace always has a surface
        super sheet, parent_services, slug_fragment
        nil
      end

      #          ~ class section 2 - core public instance methods ~

      def find_command argv  # #storypoint-365
        given = argv.fetch 0
        rx = /\A#{ ::Regexp.escape given }/
        found_a = when_touched do
          @sheet.command_tree or break Empty_A_
          catch :break_two do
            @sheet.command_tree.to_value_stream.to_enum.reduce [] do |mem, node|
              num = node.all_aliases.reduce 0 do |m, nm|
                if given == nm
                  throw :break_two, ( mem.clear << node )
                end
                rx =~ nm ? ( m + 1 ) : m  # keep looking, maybe exact match
              end
              mem << node if num.nonzero?
              mem
            end
          end
        end
        len = found_a.length
        if 1 == len
          sht = found_a[ 0 ]
          if ! (( @last_hot = get_hot sht, argv.shift ))
            @y << "(\"#{ sht.name.as_slug }\" command failed to load)"
            sht.is_ok = false
            len = 0
          end
        end
        case len
        when 0 ; unrecognized_command given
        when 1 ; [ true, @last_hot ]
        else   ; ambiguous_command found_a, given
        end
      end

      def fetch_node_documenter name_i
        get_hot @sheet.command_tree.fetch name_i
      end

      def change_command name_i  # #hacks-only
        @last_hot.change_command_notification name_i
        nil
      end

      def pre_execute  # #called-by-main-invocation-loop
        # (we override this method of p-arent class (cmd) b.c we need to do kind
        # of like what cli does - we need the surface also to have ivars..)
        ps = parent_services
        @y = ps[ :y ]
        parent_shell.instance_exec do
          @out, @err, @y = ps[ :ostream, :estream, :y ]
        end
        @last_hot = nil
        true
      end

      def info_line_yielder  # #hacks
        @y
      end

      def parent_shell
        @surface.call
      end

      def three_streams
        parent_services.three_streams
      end

      def istream
        parent_services.istream
      end

      def ostream  # necessary for true ouroborous
        parent_services.ostream
      end

      def estream
        parent_services.estream
      end

      def set_last_hot x  # #called-by Option_Block#build_into
        @last_hot = x     # this replaces the @command ivar we used to use,
        nil               # used when doing o.p hacks
      end

      #        ~ class section 3 - core private instance methods ~

    private

      def get_hot sht, argv=nil
        sht.is_prenatal and fail 'where'  # #todo
        sht.hot self, argv
      end
    end

    Empty_A_ = [ ].freeze  # detect shenarnigans, have OCD

    class Command_  # #re-open for facet 1

      # @todo:#100.100.400 rename to 'Action'  (maybe..)

      # (note the pattern that emerges in the order)

      def initialize sheet, parent_services, _slug_fragment=nil
        @argv = nil  # is write once. see `argv_notify`
        @op = nil
        @queue_a = nil  # allows transactional o.p, command-like options.
        @sheet = sheet
        @parent_services = -> { parent_services } if parent_services
        process_deferred_set if sheet.set_a
        # (`_slug_fragment` not currently stored insomuch as what the user typed
        # (or which alias was used) to get this command is unimportant to us now.)
      end

      #            ~ class section 1 - public instance methods ~

      attr_reader :sheet  # #called-by facets. because of [#037] we can again
      # reveal this with impunity.

      # `process_queue` #in-accordance-with: `o.p mechanics API`.
      # #result-is-tuple:complex. #called-by e.g. `process_options`.

      def process_queue
        q_a = option_parser_receiver.instance_exec do
          if instance_variable_defined? :@queue_a
            r = @queue_a
            @queua_a = nil
            r
          end
        end
        if ! q_a || q_a.length.zero?   # then stay. any opts that
          [ true, true ]                         # were parsed already expressed.
        else
          @queue_a and fail "sanity - test me - procede with caution"
          @queue_a = q_a
          [ true, false, self, :flush_queue ]
        end
      end

      # `method_name` #called-by-main-invocation-loop
      # #existential-workhorse
      # remeber it is not we who actually execute the implementation.

      def method_name  # called when the `parse` was successful - remember
        @sheet.method_name  # it is not we who actually execute the implementation
      end

      def change_command_notification i  # #hacks-only
        @sheet = Cmd_Sheet_.new i
        @anchored_name = nil
        nil
      end

      def pre_execute  # #called-by-main-invocation-loop
        @y = parent_services[ :y ]
        true
      end

      def is_visible  # ( sneak these in for facet 5.14x + )
        true
      end
      def is_autonomous
        false
      end

      def argv_notify argv
        # for non-standard activities, like command-like options or autonomy.
        @argv and fail "sanity - argv is write once"
        @argv = argv
        nil
      end
      def release_argv  # #hacks-only
        r = @argv ; @argv = nil ; r
      end

      #          ~ class section 2 - private instance methods ~

    private

      def parent_services
        @parent_services.call
      end

      alias_method :parent_shell, :parent_services

      # `flush_queue` - hookback for `process_queue` above. #result-is-exit-code

      def flush_queue
        ok = true ; q_a = @queue_a  # then activity happened.
        begin
          m, *a = @queue_a.shift ; recev = option_parser_receiver
          rcv = if recev.class.method_defined? m or
              recev.class.private_method_defined? m then recev else self end
          o, r = rcv.send m, *a
          ( ok &&= o ) or break     # stop if ever not ok
        end while q_a.length.nonzero?
        r                           # final exit status is whatever the last
      end                           # result was.
    end

    class Cmd_Sheet_ < Node_Sheet_   # open for facet 1.

      def initialize method_name=nil
        @name = nil ; @has_options = false
        if method_name
          @name_origin_i = :method ; @name_x = method_name
          # ( imagine this like an opcode sexp then it makes sense )
        else
          @name_origin_i = :none ; @name_x = nil
        end
      end

      #            ~ class section 1 - public instance methods ~

      def is_prenatal  # see parent class
        false
      end

      # `hot` - #called-by `find_command` - a hot, live action is requested

      def hot parent_services, *rest_to_command
        # (`alias_used` nil e.g in the case of a command tree index listing)
        cmd = Command_.new self, parent_services, *rest_to_command
        r = cmd.pre_execute or cmd = r
        cmd
      end

      attr_reader :name_origin_i, :name_x  # #called-by mech

      def set_method_name x
        :none == @name_origin_i or raise "won't set name with method when #{
          }name already set with #{ @name_origin_i }"
        @name_origin_i = :method ; @name_x = x
        x
      end

      # `method_name`
      -> do
        h = {
          method: -> { @name_x },
          nln: -> do
            raise "sanity - it is meaningless to speak of a method name in #{
              }association with this command"
          end
        }.freeze
        define_method :method_name do
          instance_exec( & h.fetch( @name_origin_i ) )
        end
      end.call

      def has_name
        @name.nil? and name
        @name
      end

      -> do  # `name`  # #called-by command and children to be `name`
        p = -> x { LIB_.name_from_symbol x }
        h = {
          none: -> _ { false },
          method: p,
          nln: p
        }.freeze
        define_method :name do
          if @name.nil?
            @name = h.fetch( @name_origin_i ).call( @name_x )
          end
          @name
        end
      end.call
    end

    class Node_Sheet_  # open for facet 1

      #  ~ class section 0 - notes for subclasses ~
      #    + restricted n-amespace "parse_xtra_*" for class-internal API
      #    + must implement a (possibly false-ish resulting) private method
      #      `name` that memoizes its result to `@name`

      def initialize name_i  # hacks only!
        @name = LIB_.name_from_symbol name_i ; nil
      end

      #  ~ section 1 - public instance methods ~

      attr_reader :name  # gets overridden

      def is_prenatal  # `pre-natalism` allows us to collect data about a node
        true           # before we know whether the node is a branch or a leaf.
      end

      def is_ok= b
        @not_ok = ! b
      end

      attr_reader :not_ok

      def is_ok
        ! not_ok
      end

      def defers_invisibility  # (sneak this in for facet 5.14x)
        false
      end

      attr_reader :set_a  # (sneak this in for facet 5.11x)

    end

    # ~ 1.4 - internal service proxies!, #storypoint-670

    CLI_Surface_Pxy_ = Services_.new do  # declare early, used to make SET_
      services_ivar :@surface_services
      services_accessor_method :[]
      services [ :y, :ivar ],
               [ :istream, :@sin ],
               [ :ostream, :@out ],
               [ :estream, :@err ],
               [ :program_name, :method, :_program_name ]
    end
    class CLI_Surface_Pxy_
      def _program_name surface
        surface.instance_exec do
          instance_variable_defined? :@program_name and @program_name
        end or ::File.basename( $PROGRAM_NAME )
      end
      def last_hot ; end ; def set_last_hot _ ; end  # we don't want the topmost
      # mechanics node to concern itself with the fact that it is topmost here

      def three_streams
        @provider[].instance_exec do
          [ @sin, @out, @err ]
        end
      end
    end

    class NS_Kernel_  # #re-open for 1.4
      Services_.enhance self do
        services_ivar :@ns_mechanics_services
        services_accessor_method :[]
        services [ :y, :ivar ],
                 [ :istream, :up ],
                 [ :ostream, :up ],
                 [ :estream, :up ],
                 [ :program_name, :up ]
      end
      public :[]
    end

    class Command_  # #re-open for 1.4
      Services_.enhance self do  # we need to put the class there and have the
        services_ivar :@cmd_services  # method there for compatability with SET_
        services_accessor_method :[]
      end
    end

    class CLI_Kernel_  # #re-open for 1.4
    private
      def parent_services
        @parent_services ||= CLI_Surface_Pxy_.new @surface.call
      end
    end

    VERTICAL_FIELD__ = Vertical_Fields_.new( [ :top, :middle, :bottom ],
      top: CLI_Surface_Pxy_,
      middle: NS_Kernel_::Services_,
      bottom: Command_::Services_ )


    #            ~ facet 2 - option representation & parsing ~

    class Namespace_
      class << self
      private
        def on first, *rest, &b  # make an intrinsic option for self.
          @story.on first, *rest, &b
        end

        def option_parser &blk  # make an o.p for the following command (method)
          @story.child_option_parser( &blk )
          nil
        end
      end
    end

    class NS_Sheet_

      def on first, *rest, &blk
        add_option_sheet Option_Sheet.new( rest.unshift( first ), blk )
      end

      def option_parser &blk  # NOTE own option parser. so named for consistency
        add_option_sheet Option_Block.new( blk )
      end

      def child_option_parser &blk
        node_open!.add_option_parser_block blk
        @scooper.do_scoop_next_method!  # re-stating true is fine.
        nil
      end
    end

    class NS_Kernel_

      def surface_receiver  # #called-by-main-invocation-loop
        parent_shell
      end

      # `option_parser_receiver` - #buck-stopper different from a leaf node
      # (command), the receiver of whose option parser is ..  see [#039]
      # #called-by-child

      def option_parser_receiver
        parent_shell
      end

      def option_parser_mechanics
        self
      end

      attr_reader :last_hot  # #called-by api intergration services, `init_op`

    private

      def option_syntax
        super if ! @sheet.command_tree  # otherwise it just gets in the way
      end

      def terminal_option_syntax  # assume @op
        a = each_option.reduce [] do |m, opt|
          x = opt.as_shortest_full_parameter_signifier or next m
          m << x
        end
        "{#{ a * '|' }}" if a.length.nonzero?
      end
    end

    class Command_  # #re-open for facet 2

      # `process_opttions` - #existential-workhorse #result-is-tuple:complex
      # #called-by-main-invocation-loop. #assume '-' == argv[0][0].

      def process_options argv, do_permute=false
        begin
          option_parser_receiver.instance_exec do
            @argv = argv  # some switches do ad-hoc parsing
          end
          option_parser or break( r = [ true, true ] )  # pass the buck
          begin                                  # parse destructively, in order
            if do_permute                        # (permute is typically used
              @op.permute! argv                  # for terminal nodes ("commands")
            else                                 # as op. to namespaces.)
              @op.order! argv                    # NOTE stop at 1st non-{arg|opt}!
            end
          rescue ::OptionParser::ParseError => e
            parse_error = true                   # don't linger in this frame
          end
          if parse_error
            reason highlight_header( e.message )  # then don't stay. short-
            break( r = [ false, false, nil ] )  # circuit. early completion.
          end
          r = option_parser_mechanics.process_queue
        end while nil
        r
      end

      def option_parser_receiver                 # a command is not the receiver
        parent_services.option_parser_receiver   # for op blocks, #called-by.
      end

    private

      # `process_options` support

      def option_parser  # (this is not the `documenter`)
        @op.nil? and init_op
        @op
      end

      def op
        @op  # #avoid-warning
      end
      public :op  # experts only - might be called from an option parser block

      def init_op
        @op and fail "sanity" ; @op = op = build_empty_option_parser ; me = self
        @ugly_str, @ugly_id = op.banner.dup, op.banner.object_id  # for doc hack
        option_parser_receiver.instance_exec do  # stdlib o.p's default handling of help just
          # straight up exits after processing help, which is unacceptable here.
          op.base.long[ 'help' ] = op.class::Switch::NoArgument.new do
            ( @queue_a ||= [ ] ) << [ :show_help, me ]
          end  # life is then easier with this i-nvisible option overriding it.
        end
        if @sheet.has_option_sheets
          p = parent_services.last_hot
          @sheet.option_sheet_a.each do |op_sheet|
            op_sheet.build_into op, self
          end
          parent_services.set_last_hot p  # `p` is for "pretty awful"
        end
        nil
      end

      def build_empty_option_parser
        op = Library_::OptionParser.new
        op.base.long.clear  # no builtin -h or -v
        op
      end

      def option_parser_mechanics
        parent_services.option_parser_mechanics
      end

      # maybe hackishly, maybe not, but our `documenter` is our option parser
      # (the same instance) but with the banner maybe set to an enhanced string.

      def documenter
        if has_partially_visible_op
          @op.nil? and init_op
          @did_prerender_help ||= prerender_help
          @op
        end
      end

      def has_fully_visible_op
        @sheet.has_option_sheets and
          @sheet.option_sheet_a.detect( & :is_fully_visible )
      end

      def has_partially_visible_op
        @sheet.has_option_sheets
      end

      def option_syntax
        if option_parser && has_partially_visible_op
          a = each_option.reduce [] do |m, opt|
            x = opt.as_shortest_full_parameter_signifier or next m
            m << "[#{ x }]"
          end
          a * SPACE_ if a.length.nonzero?
        end
      end

      def each_option  # assumes that @op (when constructed) will be an o.p
        @op_enum ||= bld_option_enumerator
      end

      def bld_option_enumerator
        @op.nil? and init_op
        fly = LIB_.CLI_lib.option.new_flyweight
        _scan = LIB_.CLI_lib.option.scan op
        _scan_ = _scan.map_by do |sw|
          fly.replace_with_switch sw
          fly
        end
        _scan_.each
      end

      def options  # #called-by self `parameters`
        @options ||= -> do
          scn = nil ; op_x = option_parser ? @op : Empty_A_
          Face_::Options.new(
            fetch: -> ref, &blk do
              scn ||= LIB_.CLI_lib.option.parser.scanner op_x
              scn.fetch ref, &blk
            end  )
        end.call
      end

      Face_::Options = LIB_.proxy_lib.functional :fetch

    end

    class Node_Sheet_  # #re-open for facet 2.

      def add_option_sheet option_x
        @has_option_sheets ||= true
        ( @option_sheet_a ||= [ ] ) << option_x
        nil
      end

      attr_reader :option_sheet_a, :has_option_sheets

      def add_option_parser_block blk
        add_option_sheet Option_Block.new( blk )  # (we used to avoid creating
        nil                 # this extra object this early. but we simplified.)
      end
    end

    class Option_Sheet

      # the abstract representation of an option, so you can store the
      # arguments passed to `on` in a separate pass, before you build the o.p

      def initialize args, blk, is_fully_visible=true
        @args, @block, @is_fully_visible = args, blk, is_fully_visible
      end

      attr_reader :args, :block, :is_fully_visible

      def build_into op, svcs # #existential-workhorse
        if @block.arity.zero?
          op.define( * @args ) do
            svcs.option_parser_receiver.instance_exec( & @block )
          end
        else
          op.define( * @args ) do |v|
            svcs.option_parser_receiver.instance_exec( v, & @block )
          end
        end
        nil
      end
    end

    class Option_Block

      # the abstract representation of an option block, lets it get processed
      # harmoniously inline with `Option_Sheet`

      def initialize blk
        @block = blk
      end

      def is_fully_visible
        true
      end

      def build_into op, svcs  # #existential-workhorse
        b = @block
        svcs.option_parser_receiver.instance_exec do
          @mechanics.set_last_hot svcs  # some o.p blocks want it both ways -
          # that is, they expect their context to be the p-arent command node
          # ("n-amespace"), and also they want access to the particular command's
          # services, and that's OKAY.
          instance_exec op, & b  # (`option_parser`)
          @mechanics.set_last_hot nil
        end
        nil
      end
    end

    #                      ~ facet 3 - argv processing ~

    class CLI_Kernel_  # #re-open for facet 3, #storypoint-1005

      def argument_error ex, cmd  # result will be final result

        md = Lib_::Call_frame_rx[].match ex.backtrace.fetch 1

        if __FILE__ == md[:path] && 'invoke' == md[:meth]
          @y << ex.message
          cmd.usage @y
          cmd.invite @y
          nil  # final-result
        else
          raise ex  # then it didn't originate from the above spot .. ICK
        end
      end
    end

    class NS_Kernel_  # #re-open for facet 3

      # `parse` - #called-by-main-invocation-loop. #result-is-tuple:complex
      # assume default argv was covered before. the below is characteristic
      # behavior of branches.

      def parse argv
        if argv.empty?
          report_expecting
        else
          super
        end
      end

      def get_command_parameters sheet  # #called-by-child when documenting
        if sheet.has_command_parameters_proc
          sheet.command_parameters_function_value.call
        elsif :method == sheet.name_origin_i
          parent_shell.method( sheet.name_x ).parameters
        else
          fail "sanity - can't get method parameters from client when #{
            }name is #{ sheet.name_origin_i } (maybe set #{
            }`command_parameters_proc`?) (for client #{
            }#{ surface_receiver.class })"
        end
      end
    end

    class Command_  # #re-open for facet 3

      # `parse` - #existential-workhorse #called-by-main-invocation-loop
      # like `process_options` but for a terminal node ("command").
      # #result-is-tuple:complex.

      def parse argv
        if option_parser
          process_options argv, true  # very likely [ false, false, nil ]
        else
          fail 'test me - you have to try hard not to have an o.p'  # #todo
          [ true, true ]
        end
      end
    end

    class Node_Sheet_  # #re-open for facet 3
      attr_reader :has_command_parameters_proc
    end

    #                      ~ facet 4 - core help & UI ~

    # ~ facet 4.1 - a narrative about `normal_last_invocation_string` ~

    class CLI_Kernel_  # #re-open for facet 4.1
      def normal_last_invocation_string          # for UI, narrative from here
        ( last_hot_recursive || self ).normal_invocation_string
      end
      def last_hot_recursive                     # #in-narrative,
        @last_hot.last_hot_recursive if @last_hot  # any last used command or nil
      end
      def get_normal_invocation_string_parts     # #in-narrative, #global-svc
        [ parent_services.program_name ]         # resolves a name for UI.
      end                                        # (note level 1 is included)`
    end
    class NS_Kernel_  # #re-open for facet 4.1
      def normal_last_invocation_string          # for UI, narrative from here
        last_hot_recursive.normal_invocation_string
      end
      def last_hot_recursive                     # #in-narrative
        @last_hot ? @last_hot.last_hot_recursive : self
      end
    end
    class Command_  # #re-open for facet 4.1
      def last_hot_recursive                     # #in-narrative #buck-stopper
        self
      end
      def normal_invocation_string               # #in-narrative
        get_normal_invocation_string_parts * SPACE_
      end
      def get_normal_invocation_string_parts     # #in-narrative
        parent_services.get_normal_invocation_string_parts << name.as_slug
      end
      def name                                   # #in-narrative
        @sheet.name
      end
    end

    #  ~ facet 4.2 - a related narrative about `anchored_last` etc ~

    class NS_Kernel_  # #re-open for facet 4.2
      def anchored_last                          # #in-narrative
        last_hot_recursive.anchored_name
      end
    end
    class Command_
      def anchored_last                          # when @last_hot is command
        anchored_name
      end
      def anchored_name
        @anchored_name ||= get_anchored_name.freeze
      end
      def get_anchored_name                      # #in-narrative
        parent_services.get_anchored_name << name.as_variegated_symbol
      end
    end
    class CLI_Kernel_  # #re-open for facet 4.2
      undef_method :anchored_last                # this is only ever for childs
      def get_anchored_name                      # #in-narrative, for
        [ ]                                      # resolving an action's name.
      end
    end

    #    ~ facet 4.3 - cosmetic concerns (near future #i18n and templating) ~

    class NS_Kernel_  # #re-open for facet 4

      # `subcommand_help` - #result-is-tuple #called-by `process_queue`

      def subcommand_help command, *rest
        argv = rest.unshift command  # (to be clear, it is a contiguous subset
        node = self                # of the received argv)
        while true  # imagine `find_command_recursive`
          stay, cmd = node.find_command argv
          stay or break
          argv.length.zero? and break
          if ! cmd.respond_to? :find_command
            stay, res = false, nil
            @y << "Unexpected argument#{ 's' if 1 != argv.length }: #{
              }#{ argv[0].inspect }#{ ' [..]' if 1 < argv.length }"
            @y << "#{ hi usage_header_text } #{ normal_invocation_string } #{
                parameters.fetch( :help ).as_shortest_nonfull_signifier
              } [cmd [sub-cmd [..]]]"
            invite @y
            break
          end
          node = cmd
        end
        if ! stay then [ stay, res ] else
          subcmd_help cmd  # just a little hook
        end
      end

    private

      def parameters  # #called-by self - `subcommand_help`
        @parameters ||= Face_::Parameters.new(
          fetch: -> ref, &blk do
            ok = false
            res = options.fetch ref do ok = true end
            if ok
              res = arguments.fetch ref do ok = false end   # etc #todo
              if ! ok  # meh
                blk ||= -> _ { raise ::KeyError, "not found - #{ ref }" }
                res = blk[ ref ]
              end
            end
            res
          end )
      end

      Face_::Parameters = LIB_.proxy_lib.nice :fetch  # only here b.c etc

      # `subcmd_help` - #result-is-tuple. a hook for the benefit of both child
      # classes and nodes - it corrals help requests coming in from 2 places:
      # the both pre- and postfix forms.

      def subcmd_help cmd
        cmd.help
        any = option_parser_receiver.instance_exec do
          @argv.length.nonzero? || @queue_a.length.nonzero?
        end
        [ any, nil ]
      end

      def report_expecting
        reason "Expecting #{ expecting }."
        [ false, false ]
      end

      def expecting  # #styled
        when_touched do
          if @sheet.command_tree
            a = @sheet.command_tree.to_value_stream.to_enum.reduce [] do |m, x|
              if x.is_ok and ! x.defers_invisibility  # ick, meh
                m << "#{ hi x.name.as_slug }" if x.is_ok
              end
              m
            end
            a * ' or ' if a.length.nonzero?
          end or 'nothing'
        end
      end

      def unrecognized_command given
        reason "Unrecognized command: #{ given.inspect }. #{
          }Expecting: #{ expecting }"
        [ false, nil ]
      end

      def ambiguous_command found, given  # #todo not covered
        reason "Ambiguous command: #{ given.inspect }. #{
          }Did you mean #{ found.map { |c| hi c.name.as_slug } * ' or ' }?"
        [ false, nil ]
      end

      def invite y
        # override p-arent to include the "[sub-cmd]" part.
        y << "try #{ hi "#{ normal_invocation_string } -h [sub-cmd]" } #{
          }for help."
        nil
      end

      def write_options_header y  # override (empty) p-arent class impl.
        sum = @op.base.list.length + @op.top.list.length
        if sum.nonzero?
          y << "#{ hi "option#{ 's' if 1 != sum }:" }"  # option: options:
        end
      end

      def additional_usage_lines
        if @sheet.command_tree && has_partially_visible_op
          if (( tos = terminal_option_syntax ))
            y = get_normal_invocation_string_parts
            y.unshift( SPACE_ * usage_header_text.length )
            [ ( y << tos ) * SPACE_ ]
          end
        end
      end

      # `argument_syntax`

      def argument_syntax
        @item_a = @item_w = false
        # CAREFUL! set in one place, read in one place
        bx = @sheet.command_tree
        if bx
          slug_a = [] ; w = 0  # reducee three things at once
          itma = bx.to_value_stream.to_enum.reduce [] do |m, sht|
            hot = get_hot sht
            if hot && hot.is_visible
              slug_a << (( slu = hot.name.as_slug ))
              slu.length > w and w = slu.length
              m << Item_[ slu, hot.get_summary_a_from_sheet( sht ) ]
            end ; m
          end
          if itma.length.nonzero?
            @item_a = itma ; @item_w = w
            "{#{ slug_a * '|' }} [opts] [args]"
          end
        end
      end

      Item_ = ::Struct.new :hdr, :lines

      def additional_help y
        if false != (( a = @item_a ))  # sneaky grease
          mar = self[ :margin ]  # call our own self.class::Services_
          fmt = "%#{ @item_w }s#{ mar }"
          y << hi( "command#{ 's' if 1 != a.length }:" )
          a.each do |item|
            if ! item.lines || item.lines.length.zero?
              y << "#{ mar }#{ hi( fmt % item.hdr ) } the #{ item.hdr } command"
            else
              y << "#{ mar }#{ hi( fmt % item.hdr ) }#{ item.lines.first }"
              item.lines[ 1 .. -1 ].each do |line|
                y << "#{ mar }#{ fmt % EMPTY_S_ }#{ line }"
              end
            end
          end
          y << "Try #{ hi "#{ normal_invocation_string } -h <sub-cmd>" } #{
            }for help on a particular command."
        end
      end
    end

    VERTICAL_FIELD__[ :margin, :default, '  '.freeze, :lowest, :middle ]

    class NS_Sheet_
      private
      def parse_xtra_margin scn
        x = scn.fetchs
        ::Fixnum === x and x = ( SPACE_ * x ).freeze  # meh
        defer_set :margin, x
        nil
      end
    end

    class Command_  # #re-open for facet 4. no p-arent.

      # `help` - #result-is-tuple
      # #called-by `process_queue`, p-arent documenting child.

      def help
        when_touched do
          y = @y
          if documenter
            y << @op.banner  # usually usage line(s)
            description_section y
            write_options_header y  # conditionally
            @op.summarize y
          else
            y << usage_line
            description_section y
          end
          additional_help y
          # rather than ignoring args that came after us, we will let the main
          # loop decide what to do with them. stay if any args left.
          [ @argv && @argv.length.nonzero?, nil ]
        end
      end

      def invite y  # #called-by-p-arent documenting this child
        invite_for y, self
        nil
      end

      def invite_for y, svcs
        svcs.respond_to? :id2name and svcs = fetch_node_documenter( svcs )
        name_a = svcs.get_normal_invocation_string_parts
        if name_a.length <= 1
          first = name_a.fetch 0
        else
          first = name_a[ 0 .. -2 ] * SPACE_
          rest = " #{ name_a[ -1 ] }"
        end
        y << "Try #{ hi "#{ first } -h#{ rest }" } for help."
        nil
      end

      def usage y  # #called-by-p-arent documenting child
        y << usage_line
        x = additional_usage_lines and y.concat x
        nil
      end

      def usage_line  # #called-by-p-arent (may be) documenting child
        "#{ hi usage_header_text } #{ syntax }"
      end

      ## #storypoint-1360

      -> do

        excerpt_lines = -> y, num, producer do  # stop a line producer early
          count = 0
          if num.nonzero?
            catch :face_hack do
              producer.call do |s|
                y << s
                if ( count += 1 ) == num
                  throw :face_hack
                end
              end
            end
          end
          count
        end

        ellipsify = -> a, num do    # ellipsify final line conditionally
          # redundant with :+[#hl-045]. if it ever gives you trouble use that
          if 0 <= num && num < a.length  # assumes a's len is w/in 1 of num
            a.pop
            if a.length.nonzero?
              last = a.length - 1
              a[ last ] = "#{ a[ last ] } [..]"
            end
          end
          nil
        end

        restyle_sexp = -> do  # ..

          header_rx = /\A[^ ]+:[ ]?\z/  # no tabs [#hl-056]

          h = {
            string: -> m, x, _ do
              m << LIB_.CLI_lib.unstyle_sexp( x ) ; nil
            end,
            style: -> m, x, usg_hdr_txt do
              s = LIB_.CLI_lib.unstyle_sexp x
              # ICK only let a header through if it says "usage:" ICK
              m << s if usg_hdr_txt == s || header_rx !~ s
              nil
            end
          }.freeze

          -> sexp, usg_hdr_txt do
            ea = LIB_.CLI_lib.pen.chunker.scan( sexp ).each
            a = ea.reduce [] do |m, x|
              h.fetch( x[0][0] )[ m, x, usg_hdr_txt ]
              m
            end
            ( a * EMPTY_S_ ).strip  # (we are re-joining a broken up string)
          end
        end.call

        restyle = -> a, usg_hdr_txt do
          a.length.times do |idx|
            line = a[ idx ]
            sexp = LIB_.CLI_lib.parse_styles line
            if sexp
              a[ idx ] = restyle_sexp[ sexp, usg_hdr_txt ]
            else
              a[ idx ] = line.strip
            end
          end
          nil
        end

        get_desc_proc_a_excerpt = -> svcs, proc_a, num_lines, usg_hdr_txt do
          a = [ ] ; num_left = num_lines + 1 ; rcvr = svcs.option_parser_receiver
          producer = -> f do
            -> &blk do
              rcvr.instance_exec ::Enumerator::Yielder.new( &blk ), &f  # whew
              nil
            end
          end
          if num_left.nonzero?
            proc_a.each do |f|
              num_did = excerpt_lines[ a, num_left, producer[ f ]  ]
              num_left -= num_did
              break if num_left <= 0
            end
          end
          if a.length.nonzero?
            ellipsify[ a, num_lines ]
            restyle[ a, usg_hdr_txt ]
            a
          end
        end

        hack_excerpt_from_op = -> do  # ..

          # rendering multiple non-trivial o.p's on one screen just for summaries
          # causes noticeable lag. we stop the rendering once we have enough.
          get_op_excerpt_lines = -> op, num do
            a = op.banner.split( "\n" )[ 0, num ]
            if a.length < num
              excerpt_lines[ a, num - a.length, op.method( :summarize ) ]
            end
            a
          end
          # a_few_lines_rx = /\A[\n]*([^\n]*)(\n+[^\n])?/
          # (in case we ever go back to op.to_s, this is what we used #todo)

          -> op, usage_header_txt, num_lines do  # `hack_excerpt_from_op`
            a = get_op_excerpt_lines[ op, num_lines + 1 ]
            ellipsify[ a, num_lines ]
            restyle[ a, usage_header_txt ]
            a
          end
        end.call

        define_method :get_summary_a_from_sheet do |sht|
          num_lines = self[ :num_summary_lines ]  # call service proxy (go up)
          if sht.desc_proc_a
            exrp_a = get_desc_proc_a_excerpt[
              self, sht.desc_proc_a, num_lines, usage_header_text ]
          end
          if ! exrp_a && documenter
            exrp_a = hack_excerpt_from_op[ @op, usage_header_text, num_lines ]
          end
          exrp_a or [ "usage: #{ syntax }" ]  # like `usage_line` but unstyled
        end
      end.call

      # `hi` (highlight) #called-by self and possibly from the p-arent shell
      # (surface).. (we used to have ohno=red, yelo=yellow, bold=(bright,green))

      def hi str
        style str, :green
      end                    # (was once `Colors` in a different age)

      -> do  # `style` - same notes as `hi`

        h = { bright: 1, red: 31, green: 32, yellow: 33, cyan: 36, white: 37 }

        esc = "\e"  # "\u001b" ok in 1.9.2

        define_method :style do |str, *styles|
          codes = styles.reduce [] do |m, x|
            if ::Integer === x then m << x else
              xx = h[ x ] and m << xx
            end
            m
          end
          "#{ esc }[#{ codes * ';' }m#{ str }#{ esc }[0m"
        end
        private :style
      end.call

      attr_reader :render_argument_syntax_as_value
      attr_reader :additional_help_proc_value

    private

      -> do  # `highlight_header` (first seen in `process_options`)

        header_rx = /\A([^:]+:)/

        define_method :highlight_header do |str|
          str.sub header_rx do
            "#{ hi $1 }"
          end
        end
        private :highlight_header
      end.call

      def reason txt  # atypical early exit with reason, e.g `report_expecting`
        @y << txt
        invite @y
        nil
      end

      def show_help cmd
        stay, res = cmd.help
        if stay then [ stay, res ] else
          [ @queue_a.length.nonzero?, res ]
        end
      end

      def prerender_help
        # we only "enchance" the main o.p if you didn't write or modify your
        # own banner (very ICK but also kind of MEH)
        if @ugly_str == @op.banner && @ugly_id == @op.banner.object_id
          y = [ ]
          usage y
          # write_options_header y
          @op.banner = y * "\n"
        end
        true  # important!
      end

      def write_options_header y
        # we hackishly don't do this at leaf nodes because we have found it
        # is best to leave this formatting to the humans. (see regret-intermd.)
      end

      -> do  # `usage_header_text`
        txt = 'usage:'.freeze
        define_method :usage_header_text do txt end
        private :usage_header_text
      end.call

      def syntax
        x = nil
        a = get_normal_invocation_string_parts  # sneaky use of this
        a << x if ( x = option_syntax )
        a << x if ( x = argument_syntax )
        a * SPACE_
      end

      def argument_syntax
        if render_argument_syntax_as_value
          @render_argument_syntax_as_value
        else
          build_any_isomorphic_argument_syntax
        end
      end

      def build_any_isomorphic_argument_syntax
        para_a = parent_services.get_command_parameters @sheet
        part_a = para_a.reduce [] do |m, x|
          ob, cb = LIB_.CLI_lib.argument.reqity_brackets x.first
          m.push "#{ ob }<#{ LIB_.name_slugulate x.last }>#{ cb }"
        end
        if part_a.length.nonzero?
          part_a * SPACE_
        end
      end

      def description_section y
        if @sheet.desc_proc_a
          rcvr = option_parser_receiver
          @sheet.desc_proc_a.each do |f|
            rcvr.instance_exec @y, &f
          end
        end
        nil  # ok to change to boolean
      end

      def additional_help y
        if (( p = additional_help_proc_value ))
          instance_exec( y, & p )
        end
      end

      def additional_usage_lines  # (hook that is for now only by branch nodes.)
      end
    end

    VERTICAL_FIELD__[ :num_summary_lines, :default, 1 ]  # full stack

    class NS_Sheet_
    private
      def parse_xtra_num_summary_lines scn
        defer_set :num_summary_lines, scn.fetchs
      end
    end

    BRANCH_HELP = Option_Sheet.new(
      [ '-h', '--help [cmd]', 'this screen [or sub-command help]' ].freeze,
      -> x do
        @queue_a ||= [ ]
        if ! x then @queue_a << :help else
          args = [ x ]  # cutely scoop any subsequent args off argv.
          while @argv.length.nonzero? and DASH_ != @argv[0][0]
            args << @argv.shift
          end
          @queue_a << [ :subcommand_help, * args ]
        end
      end,
      false
    ).freeze

    #       ~ facet 5 - extrinsic features, properties, and behavior ~

    # ~ 5.1x - default argv ~

    class Namespace_  # #re-open for 5.1x
      class << self
      private
        def default_argv *a
          @story.set_default_argv a
        end
      end
    end

    class NS_Sheet_  # #re-open for 5.1x
      def set_default_argv a
        has_default_argv and raise ::ArgumentError,
          "won't overwrite existing `default_argv`"  # for now, but meh..
        @has_default_argv = true
        @default_argv_value = a
        nil
      end

      attr_reader :has_default_argv

      def default_argv_value
        @has_default_argv or fail "sanity - check `has_default_argv` first"
        @default_argv_value
      end
    end

    class NS_Kernel_  # #re-open for 5.1x
      def has_default_argv
        @sheet.has_default_argv
      end

      def apply_default_argv argv
        argv.length.zero? or fail "sanity"
        use = @sheet.default_argv_value.map( & :to_s )  # looks prettier as sym.
        argv.concat use
        nil
      end
    end

    # ~ 5.2x - aliases ~

    class Namespace_  # #re-open for 5.2x
      def self.aliases * i_a
        @story.node_open!.add_aliases i_a
      end
    end

    class Node_Sheet_  # #re-open for 5.2x

      attr_reader :desc_proc_a  # (sneak this in for facet 5.12x)

      def add_aliases i_a
        @aliases_are_touched = nil
        ( @alias_a ||= [ ] ).concat i_a
        nil
      end

      def all_aliases
        if ! has_name then Empty_A_ else  # otherwise too annoying
          if ! aliases_are_touched
            @all_alias_a ||= [ @name.as_slug ]  # NOTE strings important
            if alias_a
              w = ( @alias_a.length - @all_alias_a.length + 1 )
              if w.nonzero?
                @all_alias_a.concat(
                  @alias_a[ @all_alias_a.length - 1 .. -1 ].map(& :to_s ) )
              end
            end
            @aliases_are_touched = true
          end
          @all_alias_a
        end
      end

      attr_reader :aliases_are_touched ; private :aliases_are_touched
      attr_reader :alias_a ; private :alias_a

    private

      def parse_xtra_aliases scn
        ( @alias_a ||= [ ] ).concat scn.fetchs
        @aliases_are_touched = nil
        nil
      end
    end

    # ~ 5.3x - recursively nested namespaces ~

    Magic_Touch_.enhance -> do
      Namespace_::Facet.touch
    end,
      [ Namespace_, :singleton, :private, :namespace ],
      [ NS_Sheet_, :public, :add_namespace ]


    # ~ 5.4x - invocation function ~

    class Command_  # #re-open for 5.4x
      def invocation_proc  # #called-by-main-invocation-loop
        @sheet.invocation_proc
      end
    end

    class Cmd_Sheet_  # #re-open for 5.4x
      attr_accessor :invocation_proc
    end

    # ~ 5.5x - version officious facet ~

    class Client_
      def self.version *a, &b
        Client_::Version_[ self, a, b ]
      end
    end

    # ~ 5.6x - metastories [#035] ~

    Magic_Touch_.enhance -> { Client_::Metastory_.touch },
      [ Command_, :singleton, :public, :metastory ],
      [ Namespace_, :singleton, :public, :metastory ],
      [ NS_Sheet_, :singleton, :public, :metastory ]

    # ~ 5.7x - adapters for when loading namespaces as a "strange module" ~

    class Client_
      module Adapter  # (this is actually a bit like #magic-touch pattern..)
        Autoloader_[ self ]
      end
    end
    class Namespace_
      module Adapter
        # intermedate n.s's use a different adapter than lvl-1 clients
        Autoloader_[ self ]
      end
    end

    # ~ 5.8x - "toucher" API for populating namespaces lazily [#038] ~

    class Command_  # #re-open for 5.8x

      def is_not_touched!
        @is_touched = false ; nil
      end

      def is_touched!
        @is_touched = true ; nil
      end

      attr_reader :is_touched ; private :is_touched  # #annoy

      def when_touched
        false == is_touched and touch  # this is just a hook. you must implement.
        yield
      end
    end

    # ~ 5.9x - command parameters as mutable ~

    Magic_Touch_.enhance -> { Client_.const_get( :Set_, false ).touch },
      [ Node_Sheet_, :public, :set_command_parameters_proc ],
      [ Namespace_, :singleton, :public, :set ],  # (this and below is 5.11x)
      [ Node_Sheet_, :private, :defer_set, :absorb_extr ],
      [ NS_Sheet_, :private, :lift_prenatals ]

    # ~ 5.10x - API integration (*non*-revelation style)

    Magic_Touch_.enhance -> { Client_::API_Integration_.touch },
      [ NS_Kernel_, :public, :api, :call_api, :api_services,
        :get_api_executable_with ]  # may be #called-by surface

    # ~ 5.11x - the `set` API ( munged in with 5.9x above ) ~

    # ~ facet N - housekeeping and file finalizing (and consequently DSL mgmt). ~

    class Client_
      @do_track_method_added = false  # location 2 of 3 -
      # this is explained in depth in its third and final location below.
    end

    class Namespace_

      @do_track_method_added = false  # location 3 of 3 - #storypoint-1845

      class << self
      private

        def method_added m  # NOTE keep this at the end of the i.m's of the class
          if @do_track_method_added  # this prevents it from triggering on the
            @story.method_was_added m  # `CLI` class itself which has no story
          end  # as explained immediately above in painful but illuminating
          nil  # detail.
        end

        def with_dsl_off &blk  # #storypoint-1855
          if instance_variable_defined? :@story  # this will have to do for now
            @story._scooper.while_dsl_off blk
          else
            p = @do_track_method_added ; @do_track_method_added = false
            r = yield ; @do_track_method_added = p ; r
          end
        end

        def dsl_off &blk  # #storypoint-1865
          if block_given? then with_dsl_off( &blk ) else
            @story._scooper.dsl_off  # we do it a greasier way than we need to.
          end
        end
      end
    end

    class Scooper_  # [#bm-001] - this one for sure!!  #storypoint-1870

      def initialize scoop
        do_track_method_added = true
        do_scoop_next_method = false
        order_a = [] ; prev_a = [] ; black_a = []
        method_added = -> m do
          if do_track_method_added
            order_a << m
            if do_scoop_next_method
              scoop[ m ]
              do_scoop_next_method = false
            end
          end ; nil
        end
        method_added_when_dsl_off = -> m do
          black_a << m ; nil
        end
        my_gma = -> m do
          method_added[ m ]
        end
        define_singleton_method :get_method_added do
          r = my_gma ; my_gma = nil ; r
        end
        define_singleton_method :do_scoop_next_method! do
          do_scoop_next_method ||= true  # re-stating true is fine.
        end
        define_singleton_method :dsl_off do
          do_track_method_added = false
        end
        define_singleton_method :while_dsl_off do |blk|
          prev_a << method_added
          method_added = method_added_when_dsl_off
          r = blk.call
          method_added = prev_a.pop
          r
        end
        define_singleton_method :get_black_a_and_white_h do
          [ black_a, ::Hash[ order_a.each_with_index.to_a ] ]
        end
        define_singleton_method :add_name_at_this_point do |x|
          order_a << x ; nil
        end
      end
    end

    Reparenthesize = -> do  # #called-by [te], :+[#061]
      rx = /\A(?<a>\([ ]*)(?<b>.*[^ ]|)(?<c>[ ]*\))\z/
      -> cb, msg do
        if (( md = rx.match msg ))
          "#{ md[:a] }#{ cb[ md[:b] ] }#{ md[:c] }"
        else
          cb[ msg ]
        end
      end
    end.call

    Face_ = Face_  # sub-sub libs expect this in client

  end
end
