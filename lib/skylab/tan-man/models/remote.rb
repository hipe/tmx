module Skylab::TanMan
  class Models::Remote < Models::Model

    NAME_RE = /^[^"]+$/
    URL_RE = /^[^ ]+$/
    SECTION_NAME_RE = /^remote "([^"]+)"$/

    meta_attribute(* MetaAttributes[:regex, :required] )
    meta_attribute :bound

    def bound?
      !! @sexp
    end

    def bind sexp
      ks = self.class.attributes.select { |_, h| h[:bound] }.map { |k, _| k }
      vals = {} # atomic
      ks.each do |k|
        (val = send(k)).nil? and fail("wat do when values is nil?")
        vals[k] = val
      end
      @sexp = sexp
      ks.each do |k|
        send("#{k}_write", vals[k]) or return false
      end
      true
    end

    attr_accessor :config

    attr_accessor :enumerator

    def initialize emitter, opts
      super(emitter)
      @sexp = nil
      opts.each { |k, v| send("#{k}=", v) }
    end

    def name
      bound? ? name_read : @name
    end
    def name= str
      bound? ? name_write(str) : (@name = str)
      str
    end
    alias_method :'remote_name=', :'name='
    def name_read
      if md = SECTION_NAME_RE.match(sexp.section_name)
        md[1]
      else
        fail("wat do")
      end
    end
    def name_write str
      sexp.section_name = "remote \"#{str}\""
      true
    end
    attribute :name, :regex => NAME_RE, :required => true, :bound => true

    def url
      bound? ? url_read : @url
    end
    def url= str
      bound? ? url_write(str) : (@url = str)
      str
    end
    attribute :url, :regex => URL_RE, :required => true, :bound => true
    def url_write str
      sexp['url'] = str
      true
    end

    attr_accessor :sexp
  end

  class << Models::Remote
    def bound enum, sec
      r = new(enum, :enumerator => enum, :sexp => sec)
      r # ! leave invalid doohahs in the file
    end
    def unbound config, name, url
      r = new(config, :config => config, :name => name, :url => url)
      r.valid? ? r : false
    end
  end

  class Models::Remote::MyEnumerator < ::Enumerator
    Remote = Models::Remote
    attr_reader :config
    def initialize(config)
      block_given? and raise ArgumentError.new("this enumerator creates its own block.")
      @config = config
      super() do |y|
        config.bridge.sections.each do |sec|
          if Remote::SECTION_NAME_RE =~ sec.section_name and rem = Remote.bound(self, sec)
            y << rem
          end
        end
      end
    end
    def push remote
      remote.bound? and fail("won't push bound remote")
      parent = config.bridge.content_tree.detect(:sections)
      sexp = CodeMolester::Config::Section.create('', parent)
      remote.bind(sexp) ? self : false
    end
  end
end

