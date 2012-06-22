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

  class Adapter::Mote < Struct.new(:name_function, :adapter_state, :client_module)
    extend Skylab::Porcelain::Bleeding::DelegatesTo

    delegates_to :name_function, :const, :client_const, :client_path

    attr_reader :client_mo

    def initialize collection, name_function, adapter_state
      @collection = collection
      super(name_function, :file_exists)
    end

    def load! &error
      :file_exists == adapter_state or return client_module
      client_path.exist? or return error["client path not found: #{client_path}"]
      plugins_mod = @collection.adapters_module
      require require_path.to_s
      client_module = [const, client_const].reduce(plugins_mod) do |mod, const|
        mod.const_defined?(const) or return error["#{mod}::#{const} not defined in #{client_path}"]
        mod.const_get(const)
      end
      self.adapter_state = :loaded
      self.client_module = client_module
    end

    delegates_to :name_function, :require_path
  end

  class Adapter::Collection < Hash

    def active_adapter_name= name
      @active_class = nil
      key?(name) or fail("adapter name is not in collection: #{name.inspect}")
      @active_adapter_name = name
      name
    end

    attr_reader :active_adapter_name

    def active_class
      @active_class ||= begin
        if mote = self[(@active_adapter_name ||= nil)]
          mote.client_module or mote.load! { |e| fail(e) }
        end
      end
    end

    attr_reader :adapters_module

    def fuzzy_match_name name
      names = self.names
      normalized = Adapter::NameFunction.normalize name
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

  end
  class Adapter::NameFunction < String
    EXTNAME_RE = /\A(?:(?<stem>|.*[^\.]|\.+)(?<extname>\.[^\.]*)|(?<stem>[^\.]*))\z/
    def self.constantize dashed_name
      dashed_name.gsub(/(?:^|-)([a-z0-9])/) { $1.upcase }
    end
    def self.normalize name
      name.to_s.gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase.sub(/\.rb$/, '').
        gsub(/[- _]+/, '-').gsub(/[^-0-9a-z]+/, '')
    end
    def client_const
      self.class.constantize @client_file_stem
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
      self.class.constantize self
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

