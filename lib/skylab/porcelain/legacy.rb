module Skylab::Porcelain::Legacy

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Legacy_ = self

  Porcelain_ = ::Skylab::Porcelain

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Arity = -> do
      HL__[]::Arity
    end

    Face__ = sidesys[ :Face ]

    HL__ = Porcelain_::Lib_::HL__

    MH__ = sidesys[ :MetaHell ]

    Method_in_mod = -> i, mod do
      MH__[].method_is_defined_by_module i, mod
    end

    Name = -> do
      HL__[]::Name
    end

    Old_box_lib = -> do
      MH__[]::Formal::Box
    end

    Old_name_lib = -> do
      HL__[]::Name
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Plugin = -> do
      Face__[]::Plugin
    end
  end

  LIB_ = Callback_.produce_library_shell_via_library_and_app_modules Lib_, self

  module DSL                      # (section 1 of 7)
    def self.[] mod
      # mod.estend DSL
      mod.extend DSL::ModuleMethods
      mod.send :include, Client::InstanceMethods
      mod._porcelain_legacy_dsl_init ; nil
    end
  end

  module DSL::ModuleMethods

    #         ~ here have these for defining your thing ~

    def visible b
      @story.action_sheet!.is_visible = b
    end

    def aliases alius, *rest
      @story.action_sheet!.concat_aliases rest.unshift( alius )
      nil
    end

    def option_parser &blk
      @story.action_sheet!.add_option_parser_block blk
      nil
    end

    def option_parser_class kls
      @story.action_sheet!.option_parser_class = kls
    end

    def argument_syntax str
      @story.action_sheet!.argument_syntax_string = str
      nil
    end

    def desc str, *rest
      @story.action_sheet!.concat_desc rest.unshift( str )
      nil
    end

    def dsl_off
      @dsl_is_hot = false
    end

    #         ~ these are some nerks that affect the whole derk ~

    def fuzzy_match b
      @story.do_fuzzy = b
    end

    def default_action_i norm_name, argv=nil
      @story.set_default_action norm_name, argv
    end

    # (`namespace` - seet re-opening below)

    #         ~ this is some reflection stuff ~

    def actions  # per spec
      story.actions  # go thru the method you want the hook
    end

    def story
      if ! @is_collapsed
        if ! @story.action_box.has? :help
          @story.add_action_sheet :help, Officious::Help.action_sheet
          @order_a << :help
        end
        the_list = @order_a & public_instance_methods( false )  # assumes 1.9!
        sheetless = the_list - @story.action_box._order
        if sheetless.length.nonzero?
          sheetful = the_list & @story.action_box._order
          sh = @story.delete_action_sheet_if_building_action_sheet
          sheetless.each do |meth|
            @story.action_sheet!
            @story.accept_method_added meth
          end
          @story.adopt_action_sheet( sh ) if sh
          # (you can deal with resorting here)
          if the_list != @story.action_box._order && sheetful.length.nonzero?
            fail 'do me - resort'  # #todo
          end
        end
        @story.inherit_unseen_ancestor_stories  # modules may have been added
        @is_collapsed = true
      end
      @story
    end

    # --*--

    # (this gets aliased over to `method_added` after init)
    def _porcelain_legacy_method_added method_name
      if @dsl_is_hot
        @is_collapsed = false
        @order_a << method_name
        if @story.is_building_action_sheet
          @story.accept_method_added method_name
        end
      end
      nil
    end

    mutex_h = { } ; event_graph_init = nil  # open up as needed

    define_method :_porcelain_legacy_dsl_init do

      # (this may get called multiple times per module object if for
      # example a class descends from a charged class and itself extends
      # the DSL. So we arrive here from one or both of 2 ways. Either way
      # or both is fine, but we want to be sure that we never init a module
      # more than once. Break this up as needed.)

      mutex_h.fetch self do
        mutex_h[ self ] = true
        # [cb] digraph is opt-in, implement `call_digraph_listeners` however you want. still this sux
        do_wire = LIB_.method_in_mod :listeners_digraph, singleton_class
        has_emit_method = LIB_.method_in_mod :call_digraph_listeners, self
        do_wire and class_exec( & event_graph_init )
        @is_collapsed = nil
        @dsl_is_hot = true
        @order_a = [ ]
        @story ||= begin
          story = Story.new self
          story.inherit_unseen_ancestor_stories  # first absorb any from the
          # ancestor chain right now, to produce the order this is expected.
          story
        end
        has_emit_method or alias_method :call_digraph_listeners, :_porcelain_legacy_emit
        class << self  # hack to avoid triggering this hook "early". sux
          alias_method :method_added, :_porcelain_legacy_method_added
        end
      end
      nil
    end

    event_graph_init = -> do
      if ! instance_methods( false ).include?( :event_class )
        event_class Callback_::Event::Textual
      end  # experimental ack - all our events are textual, so..

      listeners_digraph  payload: :all,
                       info: :all,
                      error: :all,
                       help: :info,
                         ui: :info,
                      usage: :info,
                usage_issue: :error
      nil
    end

    def inherited kls
      kls._porcelain_legacy_dsl_init
      nil
    end
  end

  class Story                     # (section 3 of 7)
                                  # (experimentally the "story" is the backend
                                  # of the DSL. it collects and retrieves the
                                  # data that makes up the "model" for the
                                  # interface.)

    #         ~ action-related methods ~

    def action_sheet!
      @action_sheet ||= Action::Sheet.for_story_host_module self
    end

    def is_building_action_sheet
      !! @action_sheet
    end

    def delete_action_sheet_if_building_action_sheet
      if @action_sheet
        x = @action_sheet
        @action_sheet = nil
        x
      end
    end

    def delete_action_sheet!
      action_sheet!
      delete_action_sheet_if_building_action_sheet
    end

    def adopt_action_sheet sheet
      @action_sheet and raise ::ArgumentError, "sanity - sheet in progress"
      @action_sheet = sheet
      nil
    end

    def add_action_sheet norm_name, sheet
      @action_box.add norm_name, sheet
      nil
    end

    def accept_method_added method_name
      sheet = delete_action_sheet!
      sheet = sheet.collapse_with_unbound_method(
        @story_host_module.instance_method( method_name ) )
      @action_box.add sheet.normalized_local_action_name, sheet
      nil
    end

    # (`accept_namespace_added` - see re-opening below)

    def actions
      @action_box.each
    end

    attr_reader :action_box  # used for hacks

    #         ~ runtime settings ~

    attr_accessor :do_fuzzy  # story doesn't use this directly, just holds it

    Default_Action = ::Struct.new :normalized_name_path, :argv

    def set_default_action norm_name, argv=nil
      @default_action_i and fail "won't clobber default action"
      norm_name = [ norm_name ] if ! ( ::Array === norm_name )
      argv ||= [ ]
      @default_action_i = Default_Action.new( norm_name, argv ).freeze
      nil
    end

    attr_reader :default_action_i

    # `fetch_action_sheet` - result in one of three possible outcomes
    # (the third only possible when `do_fuzzy`):
    #
    # 1) No matching action sheets were found. Result is result of `not_found`.
    #
    # 2) Exactly one action sheet was able to be resolved from the name ref.
    # It is the result. This outcome is arrived at in one of two ways:
    # 2a) As soon as one action is found with one name that is an exact match
    # of the name ref, the rest of the search is short-circuited and this
    # is the result (regardless of `do_fuzzy`). This has the effect that if
    # multiple actions share names, order matters, and the action appearing
    # earlier will always "swallow" the match, always preventing subsequent
    # such actions from matching. 2b) when `do_fuzzy` and exactly one action
    # can be resolved, this is the result.
    #
    # 3) The last possible outcome is only in the case of `do_fuzzy`- Each
    # action that has one or more names that matched the name ref with the
    # fuzzy algorithm (which is simply "starts with this string, case-
    # insensitive"), the first name that matched among all the action's
    # names will be aggregated on to a list. You then end up with a list
    # of names that matched, one name per action that matched. In cases where
    # there were no exact matches (b.c that would have short circuited per
    # above) and there was not zero (see above) and not one (see above),
    # `ambiguous` will be called with this list of names, and our result
    # is its result. whew!
    #

    def fetch_action_sheet ref, do_fuzzy, not_found, ambiguous
      exact = -> n { :exact if ref == n }
      match = if do_fuzzy
        rx = /\A#{ ::Regexp.escape ref }/i
        -> n do
          if rx =~ n
            exact[ n ] || :fuzzy
          end
        end
      else
        exact
      end
      ambi_a = nil
      last_ambi_action = nil
      exact_found = catch :exact_found do
        ambi_a = @action_box.reduce [] do |amb_a, (_, action)|
          action.names.each do |n|
            case match[n]
            when :exact
              throw :exact_found, action
            when :fuzzy
              last_ambi_action = action
              amb_a << n
              break  # done seeing names for this action!
            end
          end
          amb_a
        end
        nil
      end
      if exact_found || 1 == ambi_a.length
        exact_found || last_ambi_action
      elsif 1 < ambi_a.length
        ambiguous[ ambi_a ]
      else
        not_found[ ]
      end
    end

    #         ~ inheritance & absorbtion ~

    def inherit_unseen_ancestor_stories
      anc = @story_host_module.ancestors
      if @ancestors_seen_h.length < anc.length
        h = @ancestors_seen_h
        mod = anc.shift
        if @story_host_module == mod  # else ancestor chain is of a sing class
          h[mod] = true
          mod = anc.shift
        end
        while mod && ::Object != mod
          h.fetch mod do
            h[ mod ] = true
            if mod.respond_to? :story
              inherit_story mod.story  # please keep this tight with mutex
            end
          end
          if ::Class === mod  # assume etc
            break
          end
          mod = anc.shift
        end
        # (there is a chance we would miss once, if an ancestor class
        # adds a module to its chain after we saw it. but, really?)
        while mod
          h[ mod ] = true
          mod = anc.shift
        end
      end
      nil
    end

    def inherit_story story
      story.actions.each do |name, action_sheet|
        if ! @action_box.has? name
          @action_box.add name, action_sheet
        end
      end
      nil
    end

    def adapt_story story
      story.actions.each do |name, action_sheet|
        if ! @action_box.has? name
          @action_box.add name, Pxy::Sheet.new( action_sheet, story )
        end
      end
      nil
    end

  private

    def initialize story_host_module
      @story_host_module = story_host_module
      @action_sheet = nil
      @action_box = LIB_.old_box_lib.open_box.new
      @action_box.enumerator_class = Action::Enumerator
      @ancestors_seen_h = { }
      @do_fuzzy = true  # note this isn't used internally by this class
      @default_action_i = nil
    end
  end

  class Action  # used as namespace here, re-opends below as class
  end

  class Action::Enumerator < LIB_.old_box_lib.enumerator  # (used by story)

    def [] k  # actually just fetch - will throw on bad key
      @box_p.call.fetch k
    end

    def visible
      filter(& :is_visible )
    end
  end

  class Action::Sheet               # (section 3 of 7)
                                    # (experimental goofy name for this thing)

    def self.for_story_host_module namespace_module
      new.instance_exec do
        @action_subclient = -> request_client do
          Action.new request_client, self
        end
        self
      end
    end

    def self.for_action_class action_class
      new.instance_exec do
        @is_collapsed = true  # don't take an unbound method as a name
        name = action_class.name
        @name_function = LIB_.old_name_lib.via_const(
          name[ name.rindex(':') + 1  ..  -1] )
        @action_subclient = -> request_client do
          action_class.new request_client, self
        end
        self
      end
    end

    #         ~ for each "field" of upstream info, writers then readers ~
    #           (presented roughly in the order as it might be
    #               read from when presenting a help screen)

    def _name
      @name_function  # #hax
    end

    attr_accessor :is_visible                  #   ~ visibility ~

    def concat_desc a                          #   ~ description ~
      ( @desc_a ||= [] ).concat a
      nil
    end

    def description_lines
      @desc_a  # (per spec)
    end

    def add_option_parser_block blk            #   ~ options ~
      ( @option_parser_block_a ||= [] ) << blk
      nil
    end

    attr_reader :option_parser_block_a

    def option_parser_class= kls
      if @option_parser_class then fail "won't clobber o.p kls" else
        @option_parser_class = kls
      end
    end

    def option_parser_class
      @option_parser_class || Porcelain_::Library_::OptionParser
    end

    def argument_syntax_string= str            #   ~ arguments ~
      if @argument_syntax_string
        fail "won't clobber existing argument syntax - #{
          }#{ @argument_syntax_string }"
      else
        @argument_syntax_string = str
      end
    end

    def argument_syntax
      if @argument_syntax.nil?
        if @argument_syntax_string
          ass = @argument_syntax_string
          @argument_syntax_string = nil
        else
          parts = []
          arity = @unbound_method.arity
          if 0 > arity
            parts << '[<arg> [..]]'
            arity = ( arity * -1 - 1 )  # -1 => 0, -2 => 1, -3 => 2 ..
          end
          if @option_parser_block_a
            arity = [ 0, arity - 1 ].max  # 0 => 0, 1 => 0, 2 => 1 ..
          end
          parts[ 0, 0 ] = ( 0...arity ).map { |i| "<arg#{ i + 1 }>" }
          ass = parts * ' '
        end
        @argument_syntax = Argument::Syntax.from_string ass
      end
      @argument_syntax
    end

    def concat_aliases a                       #   ~ names - aliases ~
      ( @alias_a ||= [] ).concat a
      nil
    end

    attr_reader :alias_a

    def collapse_with_unbound_method unbound_method
      if @is_collapsed
        fail "sanity - action sheet is already collapsed (frozen)"
      else
        @is_collapsed = true
        @name_function = LIB_.old_name_lib.via_symbol unbound_method.name
        @unbound_method = unbound_method
        self
      end
    end

    attr_reader :unbound_method

    # (`collapse_as_namespace` - see re-opening below)

                                               #   ~ name derivatives ~

    def normalized_local_action_name           # used by action box, NOTE -
      @name_function.local_normal              #   we might s/_action_/_node_/
    end

    def slug
      @name_function.as_slug
    end

    def names
      @names ||= begin
        y = [ slug ]
        y.concat @alias_a if @alias_a
        y
      end
    end

    def full_name_proc
      # (this will be borked if ever you actually need truly deep names -
      # h.l has to be better at something! (just kidding, it's better at a lot!)

      @full_name_proc ||= LIB_.old_name_lib.qualified.new [ @name_function ]
    end

    #         ~ catalyzing ~

    def action_subclient request_client
      @action_subclient[ request_client ]
    end

  private

    def initialize
      @is_visible = true
      @alias_a = nil
      @name_function = nil
      @option_parser_block_a = nil
      @option_parser_class = nil
      @argument_syntax_string = nil
      @argument_syntax = nil
      @desc_a = nil
      @is_collapsed = nil
    end
  end

  module Adapter
    Autoloader_[ self ]
  end

  module Action::InstanceMethods

    Adapter = Adapter  # [#hl-054]

    #         ~ `resolve_argv` the primary public entrypoint ~

                                  # standard 3-arg result
    def resolve_argv argv         # mutates argv, compare to n.s version
      exit_code, method, args = resolve_options argv
      if exit_code || method then [ exit_code, method, args ] else
        resolve_arguments argv
      end
    end

    #         ~ experimental convenience & reflection nerks ~

    def fetch_param norm, &otr
      if option_parser
        parm = option_parser_stream.fetch norm do end
      end
      if ! parm && @action_sheet.argument_syntax
        parm = @action_sheet.argument_syntax.fetch norm do end
      end
      if parm then parm else
        otr ||= -> { raise ::KeyError, "param not found: #{ norm.inspect }" }
        otr[* [ norm ][ 0, otr.arity.abs ] ]
      end
    end

    def _sheet
      @action_sheet  # hax
    end

  private

    def initialize request_client, action_sheet=nil
      if request_client
        init_chld request_client, action_sheet
      end
      super()
    end
    def init_chld request_client, action_sheet  #jump-1 wtf something in here is preventing .. #todo
      @option_parser = nil
      @option_parser_stream = nil
      @request_client = request_client
      @action_sheet = action_sheet if action_sheet
      @borrowed_queue = nil
    end

    def _porcelain_legacy_emit stream, text
      @request_client.send :call_digraph_listeners, stream, text
    end

    def resolve_options argv      # standard 3-arg result
      if option_parser
        begin
          option_parser.parse! argv
          exit_code = nil
          parse_ok = true
        rescue ::OptionParser::ParseError => e
          usage_and_invite e.message
          exit_code = status_option_parser_parse_error
          parse_ok = false
        end
      # (for those actions that have no option parser, if e.g an '-h' or
      # a --help is the next argument we process it as help anyway. the only
      # way to opt-out of this behavior is to override this method [#017])
      elsif argv.length.nonzero? && '-' == argv[0][0] &&
          Officious::Help.action_sheet.names.include?( argv[0] ) then
        parse_ok = true
        argv.shift  # #tossed
        ( @borrowed_queue ||= [ ] ) << :help
      end

      if ! parse_ok then [ exit_code, nil, nil ] else
        if @borrowed_queue && @borrowed_queue.length.nonzero?
          if argv.length.nonzero?
            call_digraph_listeners :info, "(ignoring: #{ argv.map(& :inspect ).join ' ' })"
          end
          resolve_queue
        else
          [ nil, nil, nil ]  # procede as normal.
        end
      end
    end

    def status_option_parser_parse_error
      1
    end

    # `option_parser` - there are many like it, but this one is my own.
    # + NOTE this does DSL-style gymnastics with lots of scope jumping
    # + this mutates self, sets lots of ivars, so we don't write a separate
    #   `build_option_parser`

    def option_parser
      if @option_parser.nil?
        if @action_sheet.option_parser_block_a  # is used as context for o.p!
          visible_h = ::Hash.new { true }             # hacktown
          as = @action_sheet ; queue = param_h = nil  # scope
          op = as.option_parser_class.new
          @request_client.instance_exec do            # NOTE below is inside r.c
            queue = @queue ||= [ ]  # r.c that has an o.p must have a @queue!
            param_h = @param_h ||= { }                # and a @param_h

            as.option_parser_block_a.each do |blk|
              instance_exec op, &blk
            end
            h = false                                 # is '-h' defined?
            ea = Porcelain_.lib_.CLI_lib.option.enumerator op
            help_is_defined = ea.detect do |sw|
              if sw.respond_to? :short
                h = true if ! h && sw.short.include?( '-h' )
                sw.long.include? '--help'
              end
            end
            if ! help_is_defined
              sw = op.define(
                * [ ( '-h' if ! h ), '--help', 'this screen' ].compact
              ) do @queue.push :help end
              visible_h[ sw.object_id ] = false       # hacksville
            end
          end # instance_exec
          @option_parser = op
          @borrowed_queue = queue
          @borrowed_param_h = param_h
          @switch_is_visible = -> sw { visible_h[ sw.object_id ] }
        else
          @option_parser = false
        end
      end
      @option_parser
    end

    def option_parser_stream     # (assumes @option_parser !)
      @option_parser_stream ||= bld_op_stream
    end

    def bld_op_stream
      Porcelain_.lib_.CLI_lib.option.parser.scanner @option_parser
    end

    def resolve_queue  # assume nonzero length queue
      normalize = -> x do
        if ::Symbol === x
          p, a = method( x ), []  # p = proc, a = args
        elsif ::Array === x
          p, a = x
        elsif x.respond_to? :call
          p, a = x, []
        else
          raise ::ArgumentError, "no: #{ x.class }"
        end
        [ p, a ]
      end
      halt = nil
      while @borrowed_queue.length > 1  # for all but the final queue item
        p, a = normalize[ @borrowed_queue.shift ]
        rs = p.call( *a )
        rs or break( halt = true )
      end
      if halt
        [ ( false == rs ? status_error : status_early ),  nil, nil ]
      else
        [ nil, * normalize[ @borrowed_queue.shift ] ]
      end
    end

    def status_error  # generic error occured
      1
    end

    def status_early  # non-erroneous early exit
      0
    end

    def status_normal
      0
    end

    def resolve_arguments argv  # NOTE here we do the legacy b.s
      ok = argument_syntax_subclient.validate argv, -> err do
        usage_and_invite err
        false
      end
      if ! ok then [ status_error, nil, nil ] else
        args = argv.slice! 0..-1
        if option_parser
          args << @borrowed_param_h
        end
        [ nil, bound_process_method, args ]
      end
    end

    def bound_process_method  # (make sure to override this when you are doing
      # dsl-derived actions. here we are assuming you have a dedicated action
      # class..)
      method @action_sheet.normalized_local_action_name  # #experimental
    end

    def help
      y = ::Enumerator::Yielder.new do |x|
        call_digraph_listeners :help, x
      end
      y << render_usage_line
      render_desc y
      render_options y
      render_invite_to_even_more_help y
      nil
    end
    public :help

    def render_desc y
      a = @action_sheet.description_lines
      if a
        y << ''
        if 1 == a.length
          y << "#{ hdr 'description:' } #{ a[0] }"
        else
          y << "#{ hdr 'description' }"
          a.each do |line|
            y << "  #{ line }"
          end
        end
      end
      nil
    end

    # `render_options` - basically just o.p#to_s sexed up a tiny bit.
    # (see `render_option_syntax` for the single-line form)
    # if in the option parser string you see any lines that have content
    # that matches the below regex, assume you can safely consider it
    # part of a two-column layout, and hack it accordingly

    def render_options y
      op = option_parser
      if op
        lucky_rx = /\A
          (?<col_a>
            #{ ::Regexp.escape op.summary_indent } . {1,#{ op.summary_width }}
          )
          [ ]+
          (?<col_b> . + )
        \z/x
        y << ''
        y << "#{ hdr 'options' }"
        op.summarize do |line|
          if lucky_rx =~ line
            y << "#{ kbd $~[:col_a] }#{ $~[:col_b] }"
          else
            y << line
          end
        end
      end
      nil
    end

    def render_invite_to_even_more_help y
      # hook for e.g namespaces
    end

    def render_syntax_string
      y = [ didactic_invocation_string ]
      str = render_option_syntax
      y << str if str
      str = argument_syntax_subclient.string
      y << str if str
      y.join ' '
    end

    def didactic_invocation_string
      parts = [ ]
      parts << @request_client.send( :normalized_invocation_string )
      if @action_sheet.alias_a
        parts << "{#{ @action_sheet.names * '|' }}"
      else
        parts << @action_sheet.slug
      end
      parts * ' '
    end

    def normalized_invocation_string
      "#{ @request_client.send( :normalized_invocation_string ) } #{
        }#{ @action_sheet.slug }"
    end
    public :normalized_invocation_string

    def render_option_syntax
      if option_parser
        ea = Porcelain_.lib_.CLI_lib.option.enumerator option_parser
        parts = ea.reduce [] do |m, sw|
          if sw.respond_to?( :short ) && @switch_is_visible[ sw ]
            m << "[#{ sw.short.first || sw.long.first }#{ sw.arg }]"
          end
          m
        end
        if parts.length.nonzero?
          parts * ' '
        end
      end
    end

    def usage_and_invite msg
      call_digraph_listeners :usage_issue, msg
      call_digraph_listeners :usage, render_usage_line
      invite
      nil
    end

    def render_usage_line
      "#{ hdr 'usage:' } #{ render_syntax_string }"
    end

    def invite
      call_digraph_listeners :ui, "Try #{ kbd "#{ normalized_invocation_string } -h"} for help."
    end
    public :invite
  end

  class Namespace < Action  # used as namespace here, class below
  end

  module Namespace::InstanceMethods

    include Action::InstanceMethods

    #         ~ resolution methods (in roughly pre-order traversal) ~

    # [ bound_method, args ] or false/nil. mutates argv.
    def resolve_argv argv  # compare to action versoin
      if argv.length.zero?
        resolve_argv_empty
      else
        resolve_action argv
      end
    end

  private

    def resolve_argv_empty
      if self.class.story.default_action_i
        da = self.class.story.default_action_i
        # NOTE watch this, it is a bit of an abuse:
        resolve_action [ da.normalized_name_path, * da.argv ]
      else
        argv_empty_final
      end
    end

    def resolve_action argv  # assume nonzero arg length
      @legacy_last_hot = nil
      action_sheet = fetch_action_sheet argv.first
      if action_sheet
        argv.shift   # NOTE token used is #tossed for now, we used to keep it
        sc = action_sheet.action_subclient self
        @legacy_last_hot = sc
        sc.resolve_argv argv
      elsif false == action_sheet
        # show the invite now lest it be not fully and accurately qualified.
        invite
        [ status_invalid_action, nil, nil ]
      end
    end

    def status_invalid_action
      1
    end

    def fetch_action_sheet ref
      if ::Array === ref
        fail "implement me - deep paths" if 1 < ref.length
        ref = ref.first
        ref = LIB_.old_name_lib.slugulate ref
      end
      self.class.story.fetch_action_sheet ref, self.class.story.do_fuzzy,
        -> do
          call_digraph_listeners :usage_issue, "invalid action: #{ kbd ref }"
          call_digraph_listeners :usage_issue, "expecting #{ render_actions }"
          false
        end,
        -> ambi_a do
          call_digraph_listeners :usage_issue, "Ambiguous action #{ kbd ref }. #{
            }Did you mean #{ ambi_a.map(& method( :kbd )) * ' or ' }?"
          false
        end
    end

    def argv_empty_final
      usage_and_invite "expecting #{ render_actions }."
      [ status_error, nil, nil ]
    end

    def render_syntax_string
      "#{ didactic_invocation_string } #{ render_actions } [opts] [args]"
    end

    def render_actions
      arr = self.class.story.actions.visible.reduce [] do |m, (_, sheet)|
        m << "#{ kbd sheet.slug }"
      end
      "{#{ arr * '|' }}"
    end

    def syntax_text  # (used in listings sometimes)
      "#{ didactic_invocation_string }#{
        }{#{ self.class.story.actions.visible.map(& :slug ) * '|' }} #{
        }[opts] [args]"
    end
    public :syntax_text

    def render_options y
      nil  # yes, no.
    end

    def render_invite_to_even_more_help y
      y << ''
      y << "For help on a particular subcommand, try #{
        }#{ kbd "#{ normalized_invocation_string } <subcommand> -h" }."
    end
  end

  module Client
  end

  module Client::InstanceMethods

    include Namespace::InstanceMethods

    include Porcelain_.lib_.CLI_lib.pen.instance_methods_module

    def invoke argv  # mutates argv. standard 3-arg result.
      exit_code, method, args = resolve_argv argv
      if exit_code then res = exit_code else
        rs = method.receiver.send method.name, * args
        # (turn conventional true / false / nil into exit codes)
        res = if rs
          true == rs ? status_normal : rs
        else
          false == rs ? status_error : status_normal
        end
      end
      res
    end

    def get_bound_method m
      method m
    end

    def request_client_service x
      method x
    end

  private

    # `initialize` - etc.. #todo - we should settle down this interface mebbe

    Init_Mapper_ = ::Struct.new :sin, :out, :err, :program_name, :wire_p

    wire_me = -> me, blk do
      if me.respond_to? :on  # [#ps-020] part of its public API
        cnd = Event_Wiring_Shell_.new me.method( :on )
        blk[ cnd ]
      else
        me.instance_exec( & blk )
      end ; nil
    end

    args_length_h = {
      0 => -> blk do
        blk or raise ::ArgumentError, "this #{ self.class } - a legacy #{
          } CLI client - requires that you construct it with 1 block or #{
          }3 args for io wiring (no arguments given) (nils or empty block ok)"
        wire_me[ self, blk ] ; nil
      end,
      1 => -> h, blk do
        blk and raise ::ArgumentError, "won't wire when constructing with hash"
        st = Init_Mapper_.new
        h.each { |k, x| st[ k ] = x }
        i, o, e, @program_name, wire_p = st.to_a
        @three_streams_p = -> { [ i, o, e ] }
        wire_p and wire_me[ self, wire_p ]
        nil
      end,
      2 => -> rc, as, blk do  # experimental - one class plugs this in as..
        blk and raise ::ArgumentError, "can't wire a sub-cliented client"
        @request_client = rc
        @action_sheet = as
        @paystream = rc.send :paystream
        @infostream = rc.send :infostream
        nil
      end,
      3 => -> up, pay, info, blk do
        blk and raise ::ArgumentError, "won't take block and args"
        if LIB_.method_in_mod :event_listeners, singleton_class
            # if pub sub eew  #todo
          init_as_with_three_streams_when_event_listener up, pay, info
        else
          @instream = up ; @paystream = pay ; @infostream = info
        end ; nil
      end
    }.freeze

    define_method :initialize do |*up_pay_info, &wire|
      @program_name = @request_client = @action_sheet = nil
      instance_exec(* up_pay_info, wire,
                   & args_length_h.fetch( up_pay_info.length ) )
      super( nil, & nil)  # #jump-1 wtf
    end

    def init_as_with_three_streams_when_event_listener up, pay, info
      if pay
        on_payload do |ev|
          pay.puts ev.text
        end
      end
      if info
        on_info on_error { |ev| info.puts ev.text  }
      end
      @three_streams_p = -> do
        [ up, pay, info ]
      end ; nil
    end

  private


    class Event_Wiring_Shell_ < ::BasicObject
      def initialize on_p
        @on_p = on_p
      end
      def on *a, &b
        @on_p[ *a, &b ]
      end
      def method_missing i, *a, &b
        if (( md = ON_RX_.match i ))
          @on_p[ md[1].intern, *a, &b ]
        else
          super
        end
      end
      ON_RX_ = /\Aon_(.+)\z/
    end

  public

    attr_writer :program_name  # for ouroboros  [#hl-069]

    attr_reader :infostream, :paystream  # for sub-cliented cliented, as above

  private

    def some_instream
      @three_streams_p and collapse_three_streams
      @instream
    end

    def some_paystream
      @three_streams_p and collapse_three_streams
      @paystream
    end

    def some_infostream
      @three_streams_p and collapse_three_streams
      @infostream
    end

    def collapse_three_streams
      i, o, e = @three_streams_p[] ; @three_streams_p = nil
      @instream ||= i ; @paystream ||= o ; @infostream ||= e ; nil
    end

    # non [cb] digraph variant of `call_digraph_listeners` gets "turned on" elsewhere

    def _porcelain_legacy_emit stream_symbol, text
      ( :payload == stream_symbol ? @paystream : @infostream ).puts text
      nil
    end

    #         ~ resolution and support (in roughly pre order) ~

    def normalized_invocation_string
      if @request_client          # some clients get plugged in under
        super                     # other clients
      else
        @program_name || ::File.basename( $PROGRAM_NAME )
      end
    end
    public :normalized_invocation_string

    alias_method :didactic_invocation_string, :normalized_invocation_string

    def render_desc y
      # sadly, no. override n.s version. maybe after integration. also,
      # yes a modality client *could* have its own action sheet but i thought
      # we did this already over there in h.l. yes we did. meearrg.
    end

    def exitstatus_for_error
      self.class::EXITSTATUS_FOR_ERRROR__
    end
    EXITSTATUS_FOR_ERRROR__ = 42  # for findability, douglas adams tribute

    def exitstatus_for_normal
      self.class::EXITSTATUS_FOR_NORMAL__
    end
    EXITSTATUS_FOR_NORMAL__ = 0
  end


  class Action                      # (section 5 of 7 - and support)

    include Action::InstanceMethods

    LIB_.plugin::Host.enhance self do
      services [ :kbd, :method, :kbd_as_service ]
    end

  private

    # all this is for dsl-style actions defined as methods on a host client

    def call_digraph_listeners stream, text
      @request_client.send :call_digraph_listeners, stream, text
    end

    def bound_process_method  # this is for a dsl-style method on a host client
      @request_client.get_bound_method @action_sheet.normalized_local_action_name
    end

    def argument_syntax_subclient
      @argument_syntax_subclient ||= @action_sheet.argument_syntax.
        argument_syntax_subclient self
    end

    def kbd x
      kbd_as_service.call x
    end

    def hdr x
      hdr_as_service.call x
    end

    def kbd_as_service
      @kbd ||= request_client_service( :kbd )
    end

    def hdr_as_service
      @hdr ||= request_client_service( :hdr )
    end

    def request_client_service x
      @request_client.request_client_service x
    end
  end

  class Argument

    name_rx = /<( [-_a-z] [-_a-z0-9]* )>/x

    rx = /
         #{ name_rx.source } [ ]* ( \[ (?: <\1> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )?
    | \[ #{ name_rx.source } [ ]* ( \[ (?: <\3> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )? \]
    /x

    define_singleton_method :rx do rx end

    def self.new_from_matchdata n1, ub1, n2, ub2
      new.instance_exec do
        initialize_from_matchdata n1, ub1, n2, ub2
        self
      end
    end

    def self.new_custom nn, arity
      new.instance_exec do
        initialize_custom nn, arity
        self
      end
    end

    def initialize_from_matchdata name1, unbound1, name2, unbound2
      @normalized_parameter_name = ( name1 || name2 ).intern
      @arity = Arities_.fetch( name1 ?
        ( unbound1 ? :one_or_more : :one ) :
        ( unbound2 ? :zero_or_more : :zero_or_one ) )
      nil
    end
    private :initialize_from_matchdata

    def initialize_custom normalized_parameter_name, arity_o
      @normalized_parameter_name, @arity = normalized_parameter_name, arity_o
      nil
    end

    # the "argument arity" standard - [#fa-024]

    def is_required
      ! @arity.includes_zero
    end

    def is_glob
      @arity.is_polyadic
    end

    attr_reader :normalized_parameter_name  # needed by a `fetch`

    def slug
      LIB_.old_name_lib.slugulate @normalized_parameter_name
    end

    def string
      ellipsis = ( " [<#{ slug }>[...]]" if is_glob )
      if is_required
        "<#{ slug }>#{ ellipsis }"
      else
        "[<#{ slug }>#{ ellipsis }]"
      end
    end
  end

  Arities_ = LIB_.arity::Space.create do
    self::ZERO_OR_ONE = new 0, 1
    self::ZERO_OR_MORE = new 0, nil
    self::ONE = new 1, 1
    self::ONE_OR_MORE = new 1, nil
  end

  # @todo see if we can get this whole class to go away in lieu of the
  # improved reflection of ruby 1.9
  # (EDIT - we would do above except this becomes useful again for
  # `revelation`)

  class Argument::Syntax

    def self.new_mutable
      new.instance_exec do
        @element_a = [ ]
        self
      end
    end

    def self.from_string str
      new.instance_exec do
        init_from_string str
        validate_self
      end
    end

    -> do  # `init_from_string`
      argument_rx = Argument.rx
      define_method :init_from_string do |str|
        @element_a = [ ]
        scn = Porcelain_::Library_::StringScanner.new str
        while ! scn.eos?
          scn.skip( / / )
          matched = scn.scan argument_rx
          if ! matched
            raise ::ArgumentError, "failed to parse #{ scn.rest.inspect }#{
              }#{ " (after #{ @element_a.last.string.inspect })" if
                @element_a.length.nonzero? }"
          end
          md = argument_rx.match matched
          @element_a << Argument.new_from_matchdata( * md.captures )
        end
        @element_a.freeze  # just for sanity - can be changed with design.
        nil
      end
      private :init_from_string
    end.call

    [ :first,
      :length
    ].each do |meth|
      define_method meth do |*a, &b|
        @element_a.send meth, *a, &b
      end
    end

    def string
      if @element_a.length.nonzero?
        @element_a.map(& :string ).join ' '
      end
    end

    def validate_self
      signature = nil
      err = -> do
        signature = @element_a.map do |arg| arg.is_glob ? 'G' : 'g' end.join ''
        /G.*G/ =~ signature and break "globs cannot be used more than once"
        /\AGg/ =~ signature and break "globs cannot occur at the beginning"
        /gGg/  =~ signature and break "globs cannot occur in the middle"
        signature = @element_a.map { |g| g.is_required ? 'o' : 'O' } * ''
        /\AOo/ =~ signature and break "optionals cannot occur at the beginning"
        /oO+o/ =~ signature and break "optionals cannot occur in the middle"
        nil
      end.call
      if err
        raise ::ArgumentError, "#{ err } (had: #{ signature })"
      else
        self
      end
    end

    def argument_syntax_subclient plugin_host
      Argument::Syntax::SubClient.new plugin_host, @element_a
    end

    #                  ~ reflection & courtesy ~

    def fetch norm, opt=nil, *sing, &otr
      idx = @element_a.index do |arg|
        norm == arg.normalized_parameter_name
      end
      if idx then @element_a.fetch( idx ) else
        otr ||= -> { raise ::KeyError, "argument not found: #{ norm.inspect }" }
        otr[ * [norm][ 0, otr.arity ] ]
      end
    end

    def as_ruby_parameters_struct
      @element_a.map do |x|
        [(if x.is_glob then :rest elsif x.is_required then :req else :opt end),
          x.normalized_parameter_name ]
      end
    end

    #                       ~ mutation ~

    def add_custom nn_i, arity_i
      @element_a << Argument.new_custom( nn_i, Arities_.fetch( arity_i ) )
      nil
    end
  end

  class Argument::Syntax::SubClient < Argument::Syntax

    # adds UI behavior to the parent class, making it an 'action node'.

    # so that this can play nice with other frameworks, we implement it
    # as a plugin. (also, trending away from the SubClient pattern [#fa-030])
    #

    LIB_.plugin.enhance self do
      services_used [ :kbd, :ivar ]
    end

    def initialize plugin_host, elements
      receive_plugin_attachment_notification plugin_host.
        plugin_host_metaservices
      @element_a = elements
      nil
    end

    # (an earlier incarnation of this gave thanks of inspiration
    # to Davis Frank of pivotal)

    def validate argv, yes=nil, no
      begin
        ok = -> msg do
          no = no[ msg ]
          ok = nil
        end
        tokens = Argument::Scanner.new argv
        params = Argument::Scanner.new @element_a
        while ! tokens.eos?
          p = params.current
          p or break ok[ "unexpected argument: #{ tokens.current.inspect }" ]
          tokens.advance
          if p.is_glob
            saw_glob = true
          else
            params.advance
          end
        end
        ok or break
        p = params.current
        if p && p.is_required && ( ! p.is_glob && ! saw_glob )
          ok[ "expecting: #{ @kbd[ p.string ] }" ]
        end
      end while nil
      ok ? ( yes ? yes[] : true ) : no
    end
  end

  class Argument::Scanner

    def advance
      @current += 1
    end

    def current
      @args[ @current ]
    end

    def eos?
      @current >= @length
    end

  private

    def initialize args
      @current = 0
      @length = args.length
      @args = args
    end
  end

  module Action::DSL
    def self.extended mod
      mod.extend Action::DSL::ModuleMethods
      mod.send :include, Action::InstanceMethods
      mod._porcelain_legacy_action_dsl_init
      nil
    end
  end

  module Action::DSL::ModuleMethods

    mutex_h = { }  # no matter what never init a module more than once
    define_method :_porcelain_legacy_action_dsl_init do
      mutex_h.fetch self do
        mutex_h[ self ] = true
        @action_sheet ||= Action::Sheet.for_action_class( self )
        if ! LIB_.method_in_mod( :call_digraph_listeners, self )
          alias_method :call_digraph_listeners, :_porcelain_legacy_emit
        end
      end
      nil
    end

    #      ~ here, please use these to define your action ~

    def visible b
      @action_sheet.is_visible = b
      nil
    end

    def aliases alius, *rest
      @action_sheet.concat_aliases rest.unshift( alius )
      nil
    end

    def option_parser &blk
      @action_sheet.add_option_parser_block blk
      nil
    end

    def argument_syntax str
      @action_sheet.argument_syntax_string = str
      nil
    end

    def desc str, *rest
      @action_sheet.concat_desc rest.unshift( str )
      nil
    end

    #         ~ this is some nerkage for reflection et. al ~

    attr_reader :action_sheet

  private

    # nothing is private.

  end

  #         ~ Officious ~         # (section 6 of 7 - officous help)

  module Officious
  end

  class Officious::Help

    extend Action::DSL

    aliases '-h', '--help'

    argument_syntax '[<arg> [..]]'

    visible false

  private

    def resolve_arguments argv  # if you look at our actual signature we take
      # any number of arguments.  in practice we recursively nerk the derk
      if 0 == argv.length
        rs = @request_client.send :help
        [ ( false == rs ) ? status_error : status_normal , nil, nil ]
      else
        argv << '--help'  # eek
        @request_client.send :resolve_action, argv
      end
    end
  end

  #         ~ Namespaces ~        # (section 7 of 7)

  module DSL::ModuleMethods  # (re-opened)

    def namespace normalized_local_ns_name, ext_ref=nil, xtra_h=nil, &inline_def
      # we need the namespace to occur in the right order, after/before
      # e.g officious help, and after/before public methods (with or without
      # explicit sheets having been created for them), so for one thing we
      # use the accessor and not the ivar below for `story`..
      story.accept_namespace_added normalized_local_ns_name,
        ext_ref, xtra_h, inline_def
      nil
    end
  end

  class Story  # (re-opened)

    def accept_namespace_added normalized_local_ns_name, ext_ref,
          xtra_h=nil, inline_def

      ::Symbol === normalized_local_ns_name or fail 'get with the future'
      s1 = delete_action_sheet!
      nf = LIB_.old_name_lib.new normalized_local_ns_name
      s2 = s1.collapse_as_namespace nf,
        ext_ref, inline_def, xtra_h, @story_host_module
      @action_box.add s2.normalized_local_node_name, s2
      nil
    end
  end

  class Action::Sheet  # (re-opened)

    def collapse_as_namespace name_func,
        ext_ref, inline_def, xtra_h, story_host_module

      if @is_collapsed
        fail "sanity - action sheet is already collapsed (frozen)"
      elsif @option_parser_block_a
        raise ::ArgumentError, "namespaces can't have option parsers"
      elsif @argument_syntax_string
        raise ::ArgumentError, "namespaces can't have argument syntaxes"
      else
        res = Namespace::Sheet.new @is_visible,
          @alias_a,
          @desc_a,
          name_func,
          ext_ref,
          inline_def,
          story_host_module
        res.absorb_h xtra_h if xtra_h
        @is_visible = @alias_a = @argument_syntax_string = @argument_syntax =
          @desc_a = nil
        freeze  # just being cute, this obj is a tombstone now
        res
      end
    end
  end

  class Namespace::Sheet < Action::Sheet

    def summary
      @desc_a || [ "the #{ @name_function.as_slug } action" ]
    end

    def action_subclient request_client
      # take it. [#hl-054]
      action_class::Adapter::For::Legacy::Of::Action_Subclient[
        action_class, request_client, self
      ]
    end

    def face_adapter_namespace_args
      Legacy_::Adapter::For::Face::Of::Namespace_Args[ self ]
    end

    -> do
      param_h_h = {
        aliases: -> v do
          @alias_a ||= [ ]
          @alias_a |= v
        end
      }
      define_method :absorb_h do |xtra_h|
        xtra_h.each { |k, v| instance_exec v, & param_h_h.fetch( k ) }
        nil
      end
    end.call

    def normalized_local_node_name
      @name_function.local_normal
    end

  private

    def initialize is_visible, alias_a, desc_a, name_function,
      ext_ref, inline_def, story_host_module
      @is_visible, @alias_a, @desc_a, @name_function,
        @ext_ref, @inline_def, @story_host_module =
      is_visible, alias_a, desc_a, name_function,
        ext_ref, inline_def, story_host_module
      @action_class = nil
      nil
    end

    # `action_class` - experimentally we try to mimic as closely as possible
    # the derkage of hand-writing a modality client, so we dynamically generate
    # a class that will be the action-like sub-client, to represent the n.s
    # Also, we shoe-horn in box-modules, anticipating the future.

    def action_class
      @action_class ||= begin
        if @inline_def
          @ext_ref and raise ::ArgumentError, "1 arg and block or 2 args no blk"
          blk = @inline_def ; @inline_def = nil
          action_class_from_block blk
        elsif @ext_ref
          ext_ref = @ext_ref ; @ext_ref = nil
          if ext_ref.respond_to? :call
            ext_ref.call
          elsif ext_ref.respond_to? :new  # we used to check is_a? ::Class..
            ext_ref                       # but this allows for more hacks
          else
            raise ::ArgumentError, "cannot resolve an action class - #{ext_ref}"
          end
        else
          raise ::ArgumentError, "expecting 2nd arg or block to define n.s"
        end
      end
    end

    def action_class_from_block blk
      act = namespace_class
      act.class_exec(& blk )
      act
    end

    def action_class_from_class kls
      act = namespace_class
      act.story.adapt_story kls.story
      act
    end

    def namespace_class
      existing_or do |box, const|
        # (we could also extend n.s class with the dsl m.m but it adds
        # an extra lookup when the story is initted..)
        kls = box.const_set const, ::Class.new( Namespace )
        kls.extend DSL::ModuleMethods
        kls._porcelain_legacy_dsl_init
        kls
      end
    end

    def existing_or &blk
      box = box_module
      const = @name_function.as_const
      if box.const_defined? const, false
        act = box.const_get const, false
      else
        act = blk[ box, const ]
      end
      act
    end

    def box_module
      if @story_host_module.const_defined? :Actions, false # idgaf - looks familiar
        @story_host_module.const_get :Actions, false
      else
        mod = @story_host_module.const_set :Actions, ::Module.new
        # ...
        mod
      end
    end
  end

  class Namespace  # declared above. not instantiated directly
                                               # (the dynamically created sub-
                                               # class will ge the DSL m.m)
    include Namespace::InstanceMethods         # it doesn't get the client i.m

    def get_bound_method meth
      method meth
    end

  private

    kls = self

    define_method :initialize do |request_client, action_sheet|
      kls == self.class and fail "sanity - do not instantiate directly."
      @request_client, @action_sheet = request_client, action_sheet
      nil
    end
  end

  #         ~ big time hacks for this modularity nonsense ~ SECTION 8

  module Pxy
  end

  class Pxy::Sheet
    [:names, :is_visible, :slug].each do |m|
      define_method m do @real.send m end
    end

    def action_subclient request_client  # #todo big mess while we decide
      strange_client_kls = @story.instance_variable_get :@story_host_module
      Pxy::SubClient.new strange_client_kls, @real, request_client
    end

    def initialize action_sheet, story
      @real = action_sheet
      @story = story
    end
  end

  class Pxy::RequestClient

    def normalized_invocation_string
      "#{ @request_client.send :normalized_invocation_string }"
    end

    def call_digraph_listeners a, b
      @request_client.send :call_digraph_listeners, a, b
    end

    def get_bound_method meth  # upstream
      @strange_client.get_bound_method meth
    end

    def initialize strange_client, real_rc
      @strange_client = strange_client
      @request_client = real_rc
    end
  end

  class Pxy::SubClient

    def resolve_argv argv  # downstream
      @real_sc.resolve_argv argv
    end

    def initialize strange_client_kls, strange_action_sheet, request_client
      real_client = request_client.instance_variable_get :@request_client
      pay, info = real_client.instance_exec { [@paystream, @infostream ] }
      strange_client = strange_client_kls.new nil, pay, info
      rc = Pxy::RequestClient.new strange_client, request_client
      @real_sc = strange_action_sheet.action_subclient rc
      nil
    end
  end
end
