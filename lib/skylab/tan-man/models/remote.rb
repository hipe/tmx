require_relative 'model'

module Skylab::TanMan
  class Models::Remote < Models::Model
    Api::Autoloader.init(self)

    extend Bleeding::DelegatesTo

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

    # @todo{after:.3} abstract or eliminate
    OnEdit = Api::Emitter.new(:all, error: :all)
    def edit attrs, &b
      errors_count = 0
      self.error_emitter = OnEdit.new(b, ->(o) { o.on_error { errors_count += 1 } } )
      attrs.each { |k, v| send("#{k}=", v) } # assume events are emitted on errors
      self.error_emitter = nil
      0 == errors_count ? self : false
    end

    attr_accessor :enumerator

    attr_accessor :error_emitter

    def initialize
      @sexp = nil
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

    delegates_to :enumerator, :resource # will fail when etc

    def resource_label
      resource.label if resource
    end

    def url
      bound? ? url_read : @url
    end
    def url= str
      bound? ? url_write(str) : (@url = str)
      str
    end
    attribute :url, :regex => URL_RE, :required => true, :bound => true
    def url_read
      sexp['url']
    end
    def url_write str
      sexp['url'] = str
      true
    end

    attr_accessor :sexp
  end

  class << Models::Remote
    def bound enum, section_sexp
      r = new
      r.enumerator = enum
      r.sexp = section_sexp
      r # ! leave invalid doohahs in the file
    end
  end
end

