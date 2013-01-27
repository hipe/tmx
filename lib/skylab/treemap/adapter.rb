module Skylab::Treemap
  module Adapter

    o = { }                       # #todo etc - this is etc

    o[:constantize] = -> dashed_name do
      dashed_name.gsub( /(?:^|-)([a-z0-9])/ ) { $1.upcase }
    end

    o[:extname_rx] = /\A (?: (?<stem>|.*[^\.]|\.+)
                         (?<extname>\.[^\.]*)
                        |(?<stem>[^\.]*)
                     ) \z/x

    o[:normalize_to_dashed_slug] = -> name do # user input
      name.to_s.sub(/\.rb$/, '').gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.
        downcase.gsub(/[- _]+/, '-').gsub(/[^-0-9a-z]+/, '')
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

  class Adapter::Metadata         # (formerly called `Mote`)
                                  # we almost god rid of this, but then it
                                  # flourished

    def action_box                # #todo you know what i'm thinking
      @action_box ||= Adapter::Action::Box.new @rc, @name_function,
        cli_action_pathanmes, self
    end

    def cli_metadata_emissary
      @cli_metadata_emissary ||=
        Adapter::Metadata::Emissary.new @rc, @name_function
    end

    def client_module             # used to determine `hot_class` by box
      if @client_module.nil?
        load -> e { fail e } if ! is_loaded
        @client_module ||= false
      end
      @client_module
    end

    def has_cli_actions
      cli_action_pathanmes if @cli_action_pathnames.nil?
      !! @cli_action_pathnames
    end

    def load error                # called by the Box, expect more params
      res = nil
      begin
        if :file_exists != @adapter_state
          break( res = @client_module )
        end
        if ! client_pathname.exist?
          break( res = error[ "client path not found: #{ client_pathname }" ] )
        end
        require require_path.to_s # here
        res = [[:@adapter_module, const], [:@client_module, client_const]].
          reduce( adapter_box.module ) do |mod, (ivar, const)|
          if ! mod.const_defined? const, false
            break error[ "#{mod}::#{const} not defined in #{ client_pathname }"]
          end
          next_mod = mod.const_get const, false
          instance_variable_set ivar, next_mod
          next_mod
        end
        @adapter_state = :loaded
        res = @client_module
      end while nil
      res
    end

    def normalized_local_name     # used when building the box flip
      @name_function.stem.intern
    end

    def to_s # #todo - temporary
      normalized_local_name.to_s
    end

  protected

    def initialize rc, name_function, adapter_state, adapter_box
                                  # order: small to big
      @adapter_state = adapter_state
      @client_module = nil
      @name_function = name_function
      @cli_action_pathnames = nil
      @cli_metadata_emissary = nil
      @action_box = nil
      @adapter_box_f = -> { adapter_box }
      @rc = rc
      nil
    end

    def adapter_box
      @adapter_box_f[]
    end

    extend MetaHell::DelegatesTo

    delegates_to :name_function,
      :const,
      :client_const,
      :client_pathname

    attr_accessor :adapter_module

    def cli_action_pathanmes
      if @cli_action_pathnames.nil?   # if we haven't tried yet
        a = ::Pathname.glob( adapter_box.module.dir_pathname.join(
          @name_function.cli_actions_glob_tail ) )
        @cli_action_pathnames = a.length.zero? ? false : a
      end
      # puts "(#{ @name_function.stem } has some cli actions)" # #todo - twice ?
      @cli_action_pathnames
    end

    def is_loaded
      :loaded == @adapter_state
    end

    attr_reader :name_function

    def require_path
      @name_function.require_path
    end
  end

  class Adapter::Enumerator < ::Enumerator
    def filter &filter
      self.class.new do |y|
        each { |mote| filter[mote] and y << mote }
      end
    end
  end

  class Adapter::Box

    fun = Adapter::FUN

    def fetch_hot_instance &otherwise
      @hot_instance || begin
        if @hot_name
          if hot_class
            if hot_instance
              @hot_instance
            else
              otherwise[ %|failed to create instance of #{ @hot_class }| ]
            end
          else
            otherwise[ %|was unable to load class for "#{ hot_name }"| ]
          end
        else
          otherwise[ "name for active adapter is not set" ]
        end
      end
    end

    attr_reader :hot_class                     # read next line

    alias_method :hot_class_ivar, :hot_class

    def hot_class                              # used by action i.m's
      @hot_class || load_hot_class
    end

    attr_reader :hot_instance                  # read next line

    alias_method :hot_instance_ivar, :hot_instance

    def hot_instance
      @hot_instance ||= begin
        if hot_class
          @hot_class.new self
        end
      end
    end

    attr_reader :hot_name # weird design [#009]

    def load_hot_class err=nil                 # expect params to expand
      res = nil
      begin
        hot_name or break
        mote = @hash[ hot_name ] or break
        res = mote.client_module and break
        res = mote.load( err || -> e { fail e } ) # params will expand
      end while nil
      res and @hot_class = res
      res
    end

    attr_reader :name_function_function  # this is duplicated by motes

                                            # called by `set_adapter_name` (why?)
                                            # weird design [#009]

    define_method :fuzzy_match_name do |name|
      name = fun.normalize_to_dashed_slug[ name ]
      found = @order.grep( /^#{ ::Regexp.escape name }/ )
      found.clear.push( name ) if found.include? name
      [ found, names ]
    end

    attr_reader :module           # one day this will be all

    def names                     # documentors e.g. want to know this
      @order.dup
    end

    def set_hot_name name         # [#009] weird design (was?)
      @hash.fetch name do |k|
        raise ::KeyError, "adapter name is not in collection: #{ k.inspect }"
      end
      if name == @hot_name
        nil
      else
        clear_hot
        @hot_name = name.dup.freeze
        name
      end
    end

    def with boolean_property     # e.g. find me all adapters with cli actions
      each.filter(& boolean_property )
    end

  protected
                                  # make a box with one mote
                                  # for each adapter inferred from the fs

    basename_rx = /^[^.]+$/       # for now we say no dots in adapter names

    define_method :initialize do |_, mod, client_filename|
      @module = mod
      clear_hot
      @order = [ ] ; @hash = { }  # motes go here
      pn = @module.dir_pathname or fail 'sanity'
      @name_function_function =
        Adapter::Name::Function.new nil, nil, pn, client_filename
      pn.children.reduce nil do |_, pathname|
        md = basename_rx.match pathname.basename.to_s
        if md
          add md.string, Adapter::Metadata.new( nil,
            @name_function_function.dupe( md.string ),
            :file_exists, self )
        end
        nil
      end
      nil
    end

    def add name_string, mote      # this is how motes are added
      if @hash.key? name_string
        raise ::NameError.new "won't clobber - #{ name_string }"
      else
        @order << name_string
        @hash[name_string] = mote
      end
      nil
    end

    def clear_hot
      @hot_name = @hot_class = @hot_instance = nil
    end

    def each &block
      enum = Adapter::Enumerator.new do |y|
        @order.each do |k|
          y << @hash[k]
        end
        nil
      end
      if block
        enum.each(&block)
      else
        enum
      end
    end

    attr_reader :pathname
  end

  module Adapter::Name
    # what's in a name? two classes at least
  end

  class Adapter::Name::Function # #todo considering making this go away
    # for some combination of boxxy and bleeding stubs but we'll see

    fun = Adapter::FUN

    constantize = fun.constantize

    def cli_actions_glob_tail     # for fun we assume monolithic plugins dir
      "#{ @stem }/cli/actions/*"
    end

    def client_pathname                        # loading logic
      @adapter_box_pathname.join @stem, client_filename
    end

    define_method :const do
      constantize[ @stem ]
    end

    def dupe use_stem                          # motes duplicate name functions
      o = self.class.new @rc, use_stem, @adapter_box_pathname
      a, b = @client_file_stem, @client_file_extname
      o.instance_exec do
        @client_file_stem, @client_file_extname = a, b
        nil
      end
      o
    end

    def require_path                           # used to load the guy
      @adapter_box_pathname.join @stem, @client_file_stem
    end

    attr_reader :stem                          # debugging output

  protected

    def initialize rc=nil, stem=nil, pathname=nil, client_filename=nil
      @stem = ( stem.dup.freeze if stem )
      @adapter_box_pathname = pathname
      if client_filename
        self.client_filename = client_filename
      else
        @client_file_stem, @client_file_extname = nil, nil
      end
      @rc = rc
      nil
    end

    define_method :client_const do
      constantize[ @client_file_stem ]
    end

    def client_filename
      "#{ @client_file_stem }#{ @client_file_extname }"
    end

    define_method :client_filename= do |client_filename|
      md = fun.extname_rx.match client_filename # HA
      @client_file_stem = md[:stem].freeze
      @client_file_extname = md[:extname].freeze
    end
  end

  class Adapter::BoxFlip

    def visit y
      @cache_a or collapse
      @cache_a.each { |x| y << x }
      nil
    end

  protected

    def initialize modality_client
      @adapter_order = []
      @action_order = []
      @cache_a = nil # used as a flag too
      @rc = -> { modality_client } # the buck starts here
      nil
    end

    def api_client
      @rc.call.api_client
    end

    define_method :collapse do
      @adapter_order.clear ; @action_order.clear
      wat_h = api_client.adapter_box.
        with( :has_cli_actions ).reduce( {} ) do |h, adapter|
        @adapter_order.push adapter.normalized_local_name
        adapter.action_box.each.cli do |act|
          action = act.collapse @rc
          hh = h.fetch( action.normalized_local_name ) do |k|
            @action_order << k
            h[k] = { }
          end
          hh[ adapter.normalized_local_name ] = action
        end
        h
      end

      @cache_a = @action_order.reduce( [] ) do |act_y, act_name|
        act_a = @adapter_order.reduce( [] ) do |a_a, ad_name|
          if act = wat_h[ act_name ][ ad_name ]
            a_a << act
          end
          a_a
        end
        act_y << Adapter::Monstrosity::Emissary.new( @rc, act_a )
      end
      @cache_a or fail 'santiy'
      nil
    end
  end

  module Adapter::Action
    # nothing here.
  end

  class Adapter::Action::Metadata

    attr_reader :adapter

    attr_reader :modality

    def normalized_local_name
      @normalized_local_name ||= begin
        @pathname.basename.sub_ext( '' ).to_s.intern
      end
    end

    def to_s
      normalized_local_name.to_s # #todo - temporary
    end

    attr_reader :pathname

  protected

    def initialize rc, modality, pathname, adapter
      @modality, @pathname = modality, pathname
      @adapter = adapter
      @normalized_local_name = nil
      @rc = rc
      nil
    end

    def request_client
      @adapter.send :request_client
    end
  end

  class Adapter::Action::Flyweight

    attr_accessor :adapter

    def collapse rc
      Adapter::Action::Metadata.new rc, @modality, @pathname, @adapter
    end

    def clear
      @adapter = @modality = @pathname = nil
    end

    attr_accessor :modality

    attr_accessor :pathname

  protected

    alias_method :initialize, :clear
  end

  module Adapter::Monstrosity

  end

  module Adapter::Monstrosity::Action_IMs
    include Treemap::Core::SubClient::InstanceMethods

  protected

    def initialize rc, act_a
      act_a.length.nonzero? or fail 'sanity'
      @error_count = 0
      @act_a, @rc = act_a, rc
    end

    def emit a, b # etc
      request_client.send :emit, a, b
    end

    def request_client
      @rc.call
    end

    def normalized_local_name
      @act_a.first.normalized_local_name
    end
  end

  class Adapter::Monstrosity::Emissary
    # emissaries are for hacking into legacy fwks
    include Adapter::Monstrosity::Action_IMs

    def aliases
      @aliases ||= [ normalized_local_name.to_s ]
    end

    def build x                   # porcelain expects we might be a class
      x.object_id == @rc.call.object_id or fail 'sanity'
      Adapter::Monstrosity::Emissary::CLI_Action.new @rc, @act_a
    end

    def is_visible
      true
    end

    def summary_lines
      @summary_line ||= begin
        a = @act_a.reduce [] do |y, act|
          y << act.adapter.normalized_local_name.to_s
        end
        [ "`#{ normalized_local_name }` for the #{
          }#{ and_ a.map { |x| %|"#{ x }"| } } plugin#{ s a }" ]
      end
    end

  protected

    def dummy *args
    end
  end

  class  Adapter::Monstrosity::Emissary::CLI_Action
    include Adapter::Monstrosity::Action_IMs

    def help h
      os = option_syntax ; o = os.options
      nln = normalized_local_name

      a = @act_a.map { |x| x.adapter.normalized_local_name }

      emit :help, "there exist#{ s a, :_s } #{ an nln, a }`#{ nln }` #{
        }action#{ s a } for the #{
        }#{ and_ a.map { |x| %|"#{ x }"| } } plugin#{ s a }."

      emit :help, "try #{ pre "#{ normalized_invocation_string } #{
        }#{ o[:help].rndr } #{ o[:adapter_name].rndr }" } #{
        }for `#{ nln }` help for that particular plugin."
      nil
    end

    def help_invite _=nil
      emit :help, "try #{ pre "#{ normalized_invocation_string } #{
        }#{ option_syntax.string :help }" } for help"
      nil
    end

    def resolve argv              # porcelain again
      opts = option_syntax.options
      ad_name = opts[:adapter_name].parse! argv
      show_help = opts[:help].parse argv # leave the -h there
      if ad_name
        resolve_particular_adapter ad_name, argv
      elsif show_help
        emit :help, "usage: #{ pre "#{ normalized_invocation_string } #{
          }#{ }" }"
        nil
      else
        emit :help, "please indicate an adapter to load with #{
          }#{ pre "#{ opts[:adapter_name].rndr }" }"
        false
      end
    end

  protected

    def build_option_syntax
      os = CLI::DynamicOptionSyntax.new [], ::OptionParser, :parser_class
      os.define! do |h|
        on '-a', '--adapter <NAME>' do |v| h[:adapter_name] = v end
        on '-h', '--help' do h[:help] = true end
        nil
      end
      os
    end

    def option_syntax
      @option_syntax ||= build_option_syntax
    end

    def resolve_particular_adapter ad_name, argv
      # adapter_box = @act_a.first.adapter.send :adapter_box # yeah..
      res = request_client.send :set_adapter_name, ad_name
      if res
        puts 'WONDERFUL' ; exit 0
      end
      res
    end
  end

  class Adapter::Action::Box      # (coupled tight with enumerator)

    attr_reader :adapter

    def each
      @each ||= Adapter::Action::Enumerator.new self
    end

  protected

    def initialize rc, name_function, cli_action_pathnames, adapter
      @name_function, @cli_action_pathnames = name_function,
        cli_action_pathnames
      @adapter = adapter
      @each = nil
      @rc = nil
      nil
    end

    attr_reader :cli_action_pathnames

  end

  class Adapter::Action::Enumerator < ::Enumerator
                                  # (coupled tigth with box)

    def cli &b
      filter -> fw do
        :cli == fw.modality
      end, &b
    end

  protected

    def initialize box, filter=nil
      @box, @filter = box, filter
      super( ) { |y| visit y }
    end

    def filter new_filter, &block
      use_filter = if @filter
        -> x do
          r = @filter[ x ] # short-circuit boolean failure, check prev one first
          if r
            r = new_filter[ x ]
          end
          r
        end
      else
        new_filter
      end
      enum = self.class.new @box, use_filter
      if block
        enum.each(& block )
      else
        enum
      end
    end

    fw = Adapter::Action::Flyweight.new

    define_method :visit do |y|
      fw.clear
      fw.modality = :cli
      fw.adapter = @box.adapter
      pns = @box.send :cli_action_pathnames # special access
      if pns
        pns.each do |pathname|
          fw.pathname = pathname
          if ! @filter || @filter[ fw ]
            y << fw
          end
        end
      end
      nil
    end
  end
end
