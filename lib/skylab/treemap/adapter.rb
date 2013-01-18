module Skylab::Treemap
  module Adapter
    def self.Collection modul, pathname, client_file
      pathname.children.reduce(Collection.new.initialize!(modul, pathname, client_file)) do |col, p|
        if md = /^[^\.]+$/.match(p.basename.to_s)
          col[md[0]] = Adapter::Mote.new(col, col.name_function_function.dupe(md[0]), :file_exists)
        end
        col
      end
    end
  end

  CLI_ACTIONS_CONST = 'CLI::Actions'

  class Adapter::Mote < ::Struct.new :name_function, :adapter_state, :client_module
    extend ::Skylab::MetaHell::DelegatesTo # #while [#003]

    attr_accessor :adapter_module

    delegates_to :name_function, :const, :client_const, :client_path

    def cli_actions?
      ! @cli_action_paths.nil? ? @cli_action_paths : (@cli_action_paths = begin
        if ! ( loaded? or load!{ |e| fail("HELPFF: #{e}") } ) then false
        else (paths = Dir[name_function.cli_actions_glob]).empty? ? false : paths
        end
      end)
    end

    def cli_action_collection
      ! @cli_action_collection.nil? ? @cli_action_collection : (@cli_action_collection = begin
        if ! cli_actions? then false else
          CLI_ACTIONS_CONST.split('::').reduce(adapter_module) do |modul, const|
            modul.const_get(const) # for now we let a bad plugin take down the whole thing
          end
        end
      end)
    end

    def initialize collection, name_function, adapter_state
      @cli_action_paths = @cli_action_collection = nil
      @collection = collection
      super(name_function, :file_exists)
    end

    def load! &error
      :file_exists == adapter_state or return client_module
      client_path.exist? or return error["client path not found: #{client_path}"]
      plugins_mod = @collection.adapters_module
      require require_path.to_s
      [[:adapter_module, const], [:client_module, client_const]].reduce(plugins_mod) do |mod, pair|
        member, const = pair
        mod.const_defined?(const) or return error["#{mod}::#{const} not defined in #{client_path}"]
        next_mod = mod.const_get(const)
        send("#{member}=", next_mod)
        next_mod
      end
      self.adapter_state = :loaded
      client_module
    end

    def loaded?
      :loaded == adapter_state
    end

    alias_method :name, :name_function

    delegates_to :name_function, :require_path
  end

  class Adapter::Enumerator < ::Enumerator
    def filter &filter
      self.class.new do |y|
        each { |mote| filter[mote] and y << mote }
      end
    end
  end

  module Adapter::Inflection
  end # defined below

  class Adapter::Collection < Hash
    include Adapter::Inflection

    def active_adapter_name= name
      @active_class = nil
      key?(name) or fail("adapter name is not in collection: #{name.inspect}")
      @active_adapter_name = name
      name
    end

    attr_reader :active_adapter_name

    def active_class
      @active_class ||= begin
        mote = self[ active_adapter_name ] if active_adapter_name
        if mote
          mote.client_module or mote.load! { |e| fail(e) }
        end
      end
    end

    attr_reader :adapters_module

    def all &b
     e = Adapter::Enumerator.new { |y| each { |k, v| y << v } }
     block_given? ? e.each(&b) : e
    end

    def fuzzy_match_name name
      names = self.names
      normalized = normalize_to_dashed_slug name
      found = names.grep(/^#{Regexp.escape(normalized)}/)
      found.include?(normalized) and found.clear.push normalized
      [found, names]
    end

    def initialize! modul, pathname, client_file
      @adapters_module = modul
      @name_function_function = Adapter::NameFunction.new(pathname, client_file)
      self
    end

    def names
      keys
    end

    attr_reader :name_function_function, :pathname

    def with boolean_property
      all.filter(& "#{boolean_property}?".intern)
    end
  end

  module Adapter::Inflection
    EXTNAME_RE = /\A(?:(?<stem>|.*[^\.]|\.+)(?<extname>\.[^\.]*)|(?<stem>[^\.]*))\z/
    def constantize dashed_name
      dashed_name.gsub(/(?:^|-)([a-z0-9])/) { $1.upcase }
    end
    def constantize_path path
      path.to_s.downcase.gsub(%r{^/|(\.rb|/)$}, '').gsub(%r{[^-a-z0-9/]+},'').
        gsub(%r{/+},'::').gsub(/-*\b([a-z])/) { "#{$1.upcase}" }
    end
    def pathify_constant const
      const.gsub(/[^a-z0-9:]+/i, '').gsub(/:+/, '/').
        gsub(/(?<=[a-z0-9])([A-Z0-9])/){ "-#{$1}" }.downcase
    end
    def normalize_to_dashed_slug name # user input
      name.to_s.sub(/\.rb$/, '').gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.
        downcase.gsub(/[- _]+/, '-').gsub(/[^-0-9a-z]+/, '')
    end
  end
  class Adapter::NameFunction < ::String
    include Adapter::Inflection
    def client_const
      constantize @client_file_stem
    end
    def client_file
      "#{@client_file_stem}#{@client_file_extname}"
    end
    def client_file= client_file
      File.extname(client_file).tap do |extname|
        md = EXTNAME_RE.match(client_file)
        @client_file_stem = md[:stem]
        @client_file_extname = md[:extname]
      end
    end
    def const
      constantize self
    end
    def cli_actions_glob
      @pathname.join(self, "#{pathify_constant(CLI_ACTIONS_CONST)}/*.rb")
    end
    def client_path
      @pathname.join(self, client_file)
    end
    def dupe name
      self.class.new(name, nil, nil).initialize!(@pathname, @client_file_stem, @client_file_extname)
    end
    def initialize content='', pathname, client_file
      super(content)
      @pathname = pathname if pathname
      self.client_file = client_file if client_file
    end
    def initialize! pathname, client_file_stem, client_file_extname
      @pathname = pathname
      @client_file_stem = client_file_stem
      @client_file_extname = client_file_extname
      self
    end
    def require_path
      @pathname.join(self, @client_file_stem)
    end
  end
end

