module Skylab::Treemap
  module Adapter
    def self.Collection modul, pathname, client_file
      pairs = pathname.children.map do |p|
        if md = /^[^\.]+$/.match(p.basename.to_s)
          [md[0], :file_exists]
        end
      end.compact
      Collection[ pairs].tap { |c| c.initialize!(modul, pathname, client_file) }
    end
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
        (@active_adapter_name ||= nil) or return
        if :file_exists == self[@active_adapter_name]
          func = self[@active_adapter_name] = @name_function_prototype.dupe(@active_adapter_name)
          func.client_path.exist? or fail("client path not found: #{func.client_path}")
          require func.require_path.to_s
          @module.const_defined?(func.const) or fail("#{@module}::#{func.const} not defined in #{func.client_path}")
          plugin_module = @module.const_get(func.const)
          unless plugin_module.const_defined?(func.client_const)
            fail("#{plugin_module}::#{func.client_const} not defined in #{func.client_path}")
          end
          self[@active_adapter_name] = plugin_module.const_get(func.client_const)
        end
        self[@active_adapter_name]
      end
    end

    def fuzzy_match_name name
      names = self.names
      normalized = Adapter::NameFunction.normalize name
      found = names.grep(/^#{Regexp.escape(normalized)}/)
      found.include?(normalized) and found.clear.push normalized
      [found, names]
    end

    def initialize! modul, pathname, client_file
      @module = modul
      @name_function_prototype = Adapter::NameFunction.new(pathname, client_file)
    end

    def names
      keys
    end

    attr_reader :pathname

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

