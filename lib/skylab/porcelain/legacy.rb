module Skylab::Porcelain::Legacy

  Headless = ::Skylab::Headless
  Legacy = self  # 3 rsns: readability, autoloading, future-proofing
  MAARS  = ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
  MetaHell = ::Skylab::MetaHell
  Porcelain = ::Skylab::Porcelain

  module DSL                      # (section 1 of 7)
    def self.extended mod  # [#sl-111]
      mod.extend DSL::ModuleMethods
      mod.send :include, Client::InstanceMethods
      mod._porcelain_legacy_dsl_init
      nil
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

    #         ~ these are some nerks that affect the whole derk ~

    def fuzzy_match b
      @story.do_fuzzy = b
    end

    def default_action norm_name, argv=nil
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
            resort_is_needed = true
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
      @is_collapsed = false
      @order_a << method_name
      if @story.is_building_action_sheet
        @story.accept_method_added method_name
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
      #
      mutex_h.fetch self do
        mutex_h[ self ] = true
        if respond_to? :emits     # pub-sub is opt-in. implement emit as u like
          class_exec(& event_graph_init )
        end
        @is_collapsed = nil
        @order_a = [ ]
        @story ||= begin
          story = Story.new self
          story.inherit_unseen_ancestor_stories  # first absorb any from the
          # ancestor chain right now, to produce the order this is expected.
          story
        end
        if ! method_defined? :emit  # don't overwrite pub-sub version, e.g
          alias_method :emit, :_porcelain_legacy_emit
        end
        class << self
          alias_method :method_added, :_porcelain_legacy_method_added
        end
      end
      nil
    end

    event_graph_init = -> do
      if ! instance_methods( false ).include?( :event_class )
        event_class ::Skylab::PubSub::Event::Textual
      end  # experimental ack - all our events are textual, so..

      emits         payload: :all,
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
      @default_action and fail "won't clobber default action"
      norm_name = [ norm_name ] if ! ( ::Array === norm_name )
      argv ||= [ ]
      @default_action = Default_Action.new( norm_name, argv ).freeze
      nil
    end

    attr_reader :default_action

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
        ambi_a = @action_box.reduce [] do |amb_a, (k, action)|
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

  protected

    def initialize story_host_module
      @story_host_module = story_host_module
      @action_sheet = nil
      @action_box = MetaHell::Formal::Box::Open.new
      @action_box.enumerator_class = Action::Enumerator
      @ancestors_seen_h = { }
      @do_fuzzy = true  # note this isn't used internally by this class
      @default_action = nil
    end
  end

  class Action  # used as namespace here, re-opends below as class
  end

  class Action::Enumerator < MetaHell::Formal::Box::Enumerator # (used by story)

    def [] k  # actually just fetch - will throw on bad key
      @box_ref.call.fetch k
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
        @name_function = Headless::Name::Function.from_const(
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
      @option_parser_class || Porcelain::Services::OptionParser
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
        @name_function = Headless::Name::Function.new unbound_method.name
        @unbound_method = unbound_method
        self
      end
    end

    attr_reader :unbound_method

    # (`collapse_as_namespace` - see re-opening below)

                                               #   ~ name derivatives ~

    def normalized_local_action_name           # used by action box, NOTE -
      @name_function.normalized_local_name     #   we might s/_action_/_node_/
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

    def full_name_function
      # (this will be borked if ever you actually need truly deep names -
      # h.l has to be better at something! (just kidding, it's better at a lot!)

      @full_name_function ||=
        Headless::Name::Function::Full.new [ @name_function ]
    end

    #         ~ catalyzing ~

    def action_subclient request_client
      @action_subclient[ request_client ]
    end

  protected

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

  module SubClient_InstanceMethods             # (section 4 of 7 - i.m's)

  protected

    def hdr str
      @request_client.send :hdr, str
    end

    def kbd x  # just a cute alternative
      @kbd ||= @request_client.method :kbd
      @kbd[ x ]
    end
  end

  module Adapter
    extend MAARS
  end

  module Action::InstanceMethods

    Adapter = Adapter  # [#hl-054]

    include SubClient_InstanceMethods

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
        parm = option_parser_scanner.fetch norm do end
      end
      if ! parm && @action_sheet.argument_syntax
        parm = @action_sheet.argument_syntax.fetch norm do end
      end
      if parm then parm else
        otr ||= -> { raise ::KeyError, "param not found: #{ norm.inspect }" }
        otr[* [ norm ][ 0, otr.arity.abs ] ]
      end
    end

  protected

    def initialize request_client, action_sheet=nil
      @option_parser = nil
      @option_parser_scanner = nil
      @request_client = request_client
      @action_sheet = action_sheet if action_sheet
      @borrowed_queue = nil
      nil
    end

    def _porcelain_legacy_emit stream, text
      @request_client.send :emit, stream, text
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
      # way to opt-out of this behavior is to override this method [#po-017])
      elsif argv.length.nonzero? && '-' == argv[0][0] &&
          Officious::Help.action_sheet.names.include?( argv[0] ) then
        parse_ok = true
        argv.shift  # #tossed
        ( @borrowed_queue ||= [ ] ) << :help
      end

      if ! parse_ok then [ exit_code, nil, nil ] else
        if @borrowed_queue && @borrowed_queue.length.nonzero?
          if argv.length.nonzero?
            emit :info, "(ignoring: #{ argv.map(& :inspect ).join ' ' })"
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
            ea = Headless::CLI::Option::Enumerator.new op
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

    def option_parser_scanner     # (assumes @option_parser !)
      @option_parser_scanner ||= begin
        Headless::CLI::Option::Parser::Scanner.new @option_parser
      end
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
        emit :help, x
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

    def argument_syntax_subclient
      @argument_syntax_subclient ||= @action_sheet.argument_syntax.
        argument_syntax_subclient self
    end

    def render_syntax_string
      y = [ didactic_invocation_string ]
      str = render_option_syntax
      y << str if str
      str = argument_syntax_subclient.render
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

    def render_option_syntax
      if option_parser
        ea = Headless::CLI::Option::Enumerator.new option_parser
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
      emit :usage_issue, msg
      emit :usage, render_usage_line
      invite
      nil
    end

    def render_usage_line
      "#{ hdr 'usage:' } #{ render_syntax_string }"
    end

    def invite
      emit :ui, "Try #{ kbd "#{ normalized_invocation_string } -h"} for help."
    end
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

  protected

    def resolve_argv_empty
      if self.class.story.default_action
        da = self.class.story.default_action
        # NOTE watch this, it is a bit of an abuse:
        resolve_action [ da.normalized_name_path, * da.argv ]
      else
        argv_empty_final
      end
    end

    def resolve_action argv  # assume nonzero arg length
      @legacy_last_action_subclient = nil
      action_sheet = fetch_action_sheet argv.first
      if action_sheet
        argv.shift   # NOTE token used is #tossed for now, we used to keep it
        sc = action_sheet.action_subclient self
        @legacy_last_action_subclient = sc
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
        ref = Headless::Name::FUN.slugulate[ ref ]
      end
      self.class.story.fetch_action_sheet ref, self.class.story.do_fuzzy,
        -> do
          emit :usage_issue, "invalid action: #{ kbd ref }"
          emit :usage_issue, "expecting #{ render_actions }"
          false
        end,
        -> ambi_a do
          emit :usage_issue, "Ambiguous action #{ kbd ref }. #{
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
      arr = self.class.story.actions.visible.reduce [] do |m, (k, sheet)|
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

    include Headless::CLI::Pen::InstanceMethods

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

  protected

    # `initialize` - etc.. #todo

    args_length_h = {
      0 => -> blk do
        blk or raise ::ArgumentError, "this #{ self.class } - a legacy #{
          } CLI client - requires that you construct it with 1 block or #{
          }3 args for io wiring (no arguments given) (nils or empty block ok)"
        blk[ self ]
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
        if respond_to? :event_listeners  # if pub sub
          if pay  # (may have intentionally passed nil)
            on_payload        do |e| pay.puts  e.text end
          end
          if info  # (may have intentionally passed nil)
            on_info( on_error do |e| info.puts e.text end )
          end
        else
          @paystream, @infostream = pay, info
        end
        nil
      end
    }

    define_method :initialize do |*up_pay_info, &wire|
      @program_name = @request_client = @action_sheet = nil
      instance_exec(* up_pay_info, wire,
                   & args_length_h.fetch( up_pay_info.length ) )
    end

    attr_reader :infostream, :paystream  # for sub-cliented cliented, as above

    # non-pub-sub variant of `emit` gets "turned on" elsewhere

    def _porcelain_legacy_emit stream_name, text
      ( :payload == stream_name ? @paystream : @infostream ).puts text
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

    alias_method :didactic_invocation_string, :normalized_invocation_string

    def render_desc y
      # sadly, no. override n.s version. maybe after integration. also,
      # yes a modality client *could* have its own action sheet but i thought
      # we did this already over there in h.l. yes we did. meearrg.
    end
  end


  class Action                      # (section 5 of 7 - and support)
    include Action::InstanceMethods

  protected
    # all this is for dsl-style actions defined as methods on a host client

    def emit stream, text
      @request_client.send :emit, stream, text
    end

    def bound_process_method  # this is for a dsl-style method on a host client
      @request_client.get_bound_method @action_sheet.normalized_local_action_name
    end
  end

  class Argument

    name_rx = /<( [-_a-z] [-_a-z0-9]* )>/x

    rx = /
         #{ name_rx.source } [ ]* ( \[ (?: <\1> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )?
    | \[ #{ name_rx.source } [ ]* ( \[ (?: <\3> [ ]* \[ \.\.\.? \] | \.\.\.? ) \] )? \]
    /x

    define_singleton_method :rx do rx end

    def is_glob
      @max.nil?
    end

    def is_required
      @min > 0
    end

    attr_reader :normalized_parameter_name  # needed by a `fetch`

    def slug
      Headless::Name::FUN.slugulate[ @normalized_parameter_name ]
    end

    def string
      if ! @max
        ellipsis = " [<#{ slug }>[...]]"
      end
      if is_required
        "<#{ slug }>#{ ellipsis }"
      else
        "[<#{ slug }>#{ ellipsis }]"
      end
    end

  protected

    def initialize name1, max1, name2, max2
      @normalized_parameter_name = ( name1 || name2 ).intern
      if name1
        @min = 1
        @max = max1 ? nil : 1
      else
        @min = 0
        @max = max2 ? nil : 1
      end
    end
  end

  # @todo see if we can get this whole class to go away in lieu of the
  # improved reflection of ruby 1.9

  class Argument::Syntax

    def self.from_string str
      new( str ).validate_self
    end

    # --*--

    [
      :first,
      :length
    ].each do |meth|
      define_method meth do |*a, &b|
        @elements.send meth, *a, &b
      end
    end

    def string
      if @elements.length.nonzero?
        @elements.map(& :string ).join ' '
      end
    end

    def validate_self
      signature = nil
      err = -> do
        signature = @elements.map do |arg| arg.is_glob ? 'G' : 'g' end.join ''
        /G.*G/ =~ signature and break "globs cannot be used more than once"
        /\AGg/ =~ signature and break "globs cannot occur at the beginning"
        /gGg/  =~ signature and break "globs cannot occur in the middle"
        signature = @elements.map do |arg| arg.is_required ? 'o' : 'O' end.join ''
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

    def argument_syntax_subclient request_client
      Argument::Syntax::SubClient.new request_client, @elements
    end

    #                  ~ reflection & courtesy ~

    def fetch norm, &otr
      idx = @elements.index do |arg|
        norm == arg.normalized_parameter_name
      end
      if idx then @elements.fetch( idx ) else
        otr ||= -> { raise ::KeyError, "argument not found: #{ norm.inspect }" }
        otr[ * [norm][ 0, otr.arity ] ]
      end
    end

  protected

    def initialize str
      @elements = [ ]
      scn = Porcelain::Services::StringScanner.new str
      rx = argument_rx
      while ! scn.eos?
        scn.skip( / / )
        matched = scn.scan rx
        if ! matched
          raise ::ArgumentError, "failed to parse #{ scn.rest.inspect }#{
            }#{ " (after #{ @elements.last.string.inspect })" if
              @elements.length.nonzero? }"
        end
        md = rx.match matched
        @elements << Argument.new( * md.captures )
      end
      nil
    end

    def argument_rx
      Argument.rx
    end
  end

  class Argument::Syntax::SubClient < Argument::Syntax

    # sane design and elegant argument parameters dictate that we make a
    # subclass of a.s just for validating argv (the whole point). pub sub
    # is not the answer, nor is jagged payloads. pls wtach:

    include SubClient_InstanceMethods

    def render
      if @elements.length.nonzero?
        @elements.map(& :string ).join ' '
      end
    end

    # (an earlier incarnation of this gave thanks of inspiration
    # to Davis Frank of pivotal)

    def validate argv, error
      tokens = Argument::Scanner.new argv
      params = Argument::Scanner.new @elements
      saw_glob = false
      err = nil
      while ! tokens.eos?
        p = params.current
        if ! p
          break( err = "unexpected argument: #{ tokens.current.inspect }" )
        end
        tokens.advance
        if p.is_glob
          saw_glob = true
        else
          params.advance
        end
      end
      if ! err
        p = params.current
        if p && p.is_required && ( ! p.is_glob && ! saw_glob )
          err = "expecting: #{ kbd p.string }"
        end
      end
      if err
        error[ err ]
      else
        true
      end
    end

  protected

    def initialize request_client, elements
      @request_client = request_client
      @elements = elements
      @kbd = nil
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

  protected

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
        if ! method_defined? :emit  # don't overwrite pub-sub version, e.g
          alias_method :emit, :_porcelain_legacy_emit
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

  protected

    # nothing is protected.

  end

  #         ~ Officious ~         # (section 6 of 7 - officous help)

  module Officious
  end

  class Officious::Help

    extend Action::DSL

    aliases '-h', '--help'

    argument_syntax '[<arg> [..]]'

    visible false

  protected

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

  module DSL  # (re-opened)

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
      nf = Headless::Name::Function.new normalized_local_ns_name
      s2 = s1.collapse_as_namespace nf,
        ext_ref, inline_def, xtra_h, @story_host_module
      @action_box.add s2.normalized_local_node_name, s2
      @@namespaces << s2  # #todo - integration only
      nil
    end

    # START - this is for during integration *only* # #todo
    @@namespaces = [ ]  # used for a hack that will be put down soon
    -> do
      namespaces = -> do  # you don't get to have the whole array
        NSs_Read_Only_Pxy = MetaHell::Proxy::Nice.new :length, :[]
        pxy = NSs_Read_Only_Pxy.new( :length => -> { @@namespaces.length },
                            :'[]' => -> idx { @@namespaces[ idx ] } )
        namespaces = -> { pxy } ; pxy
      end
      Legacy.class_exec do
        define_singleton_method :namespaces do namespaces[] end
      end
    end.call
    # END
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
        freeze  # just being cute, this obj is a tombstone now # #todo
        res
      end
    end
  end

  class Namespace::Sheet < Action::Sheet

    def name  # #todo - this is for integration only
      @name_function.as_slug
    end
    def aliases  # #todo - this is for integration only
      alias_a
    end
    def for_run mc, slug_fragment  # #todo - integration only
      action_class.new out: mc.out, err: mc.err,
        program_name: "#{ mc.program_name } #{ @name_function.as_slug }"
    end
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
      Legacy::Adapter::For::Face::Of::Namespace_Args[ self ]
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
      @name_function.normalized_local_name
    end

  protected

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

  protected

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

    include SubClient_InstanceMethods  # we use kbd and hdr

    def normalized_invocation_string
      "#{ @request_client.send :normalized_invocation_string }"
    end

    def emit a, b
      @request_client.send :emit, a, b
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
