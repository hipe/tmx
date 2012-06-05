require File.expand_path('..', __FILE__)
prev = $VERBOSE ; $VERBOSE = false
require 'treetop'
$VERBOSE = prev # treetop is naughty (@todo etc?)
require 'skylab/face/path-tools'
require 'skylab/pub-sub/emitter'

module Skylab::CodeMolester

  module Config
    require DIR.join('../parse-failure-porcelain').to_s
    require DIR.join('../sexp').to_s
    require "#{DIR}/node"
  end

  class Config::File
    def self.delegates_when_valid_to implementor, method_name
      define_method(method_name) do |*a, &b|
        if valid?
          send(implementor).send(method_name, *a, &b)
        else
          false
        end
      end
    end
    def self.delegates_to_truish_ivar attr, method
      define_method(method) do |*a, &b|
        if (o = instance_variable_get(attr))
          o.send(method, *a, &b)
        end
      end
    end
    delegates_when_valid_to :sexp, :[]
    # []= defined below
    attr_reader :content # @api private!
    def content= str
      @content = str
      @state = :unparsed
    end
    delegates_when_valid_to :sexp, :content_items
    delegates_to_truish_ivar '@pathname', :dirname
    delegates_to_truish_ivar '@pathname', :exist?
    # [path] [opts]
    def initialize *args
      @content = @mtime = @on_read = @on_write = @pathname = nil
      @state = :initial
      _args = Hash === args.last ? args.pop.dup : {}
      args.size.nonzero? and _args[:path] = args.pop
      args.size.nonzero? and raise ArgumentError.new("syntax: #{self.class}.new([path], [opts])")
      _args.each { |k, v| send("#{k}=", v) }
      block_given? and yield self
    end
    def invalid_reason
      valid?
      @invalid_reason
    end
    delegates_when_valid_to :sexp, :key?
    def modified?
      if pathname.exist?
        if @mtime
          pathname.mtime > @mtime
        else
          true
        end
      end
    end
    def on_read &b
      if b then @on_read = b else @on_read end
    end
    def on_write &b
      if b then @on_write = b else @on_write end
    end
    def path
      @pathname.to_s if @pathname
    end
    def path= mixed
      @pathname = mixed ? ::Skylab::Face::MyPathname.new(mixed) : mixed
    end
    attr_reader :pathname
    delegates_to_truish_ivar '@pathname', :pretty
    OnRead = Skylab::PubSub::Emitter.new(:all, :error => :all, :invalid => :error)
    def read
      e = OnRead.new
      if block_given? then yield(e) else on_read.call(e) end
      self.content = pathname.read
      @mtime = pathname.mtime
      if valid?
        self
      else
        e.emit(:invalid, invalid_reason)
        false
      end
    end
    delegates_when_valid_to :sexp, :sections
    delegates_when_valid_to :sexp, :set_value
    alias_method :[]=, :set_value
    def sexp # @api private
      valid? ? @content : false
    end
    # def to_s do not define or alias this.  "to_s" is so ambiguous for this class it should not be used.
    def string
      valid? ? @content.unparse : @content
    end
    delegates_when_valid_to :sexp, :value_items
    class OnWrite < Skylab::PubSub::Emitter.new(:all, :error => :all, :notice => :all,
      :before_edit => :notice, :after_edit => :notice, :before_create => :notice, :after_create => :notice,
      :no_change => :notice)
    end
    def write
      e = OnWrite.new
      if block_given? then yield(e) else on_write.call(e) end
      bytes = nil
      content = self.string
      if exist?
        if pathname.read == content
          e.emit(:no_change, "no change: #{pretty}")
        else
          e.emit(:before_edit, message: "updating #{pretty}", resource: self)
          writable? or return e.error("cannot edit, file is not writable: #{pretty}")
          pathname.open('w') { |fh| bytes = fh.write(content) }
          e.emit(:after_edit, message: "updated #{pretty} (#{bytes} bytes)", bytes: bytes)
        end
      else
        e.emit(:before_create, message: "creating #{pretty}", resource: self)
        dirname.exist? or return e.error("parent directory does not exist, cannot write #{pretty}")
        dirname.writable? or return e.error("parent direcory is not writable, cannot write #{pretty}")
        pathname.open('w+') { |fh| bytes = fh.write(content) }
        e.emit(:after_create, message: "created #{pretty} (#{bytes} bytes)", bytes: bytes)
      end
      bytes
    end
    def valid?
      # look: two case statements in a row.  first one changes state iff necessary. second one no.
      case @state
      when :initial, :unparsed
        @content.nil? and @content = ''
        p = self.class.parser
        if expensive = p.parse(@content) # nil ok
          @content = expensive.sexp
          @state = :valid
          @invalid_reason = nil
        else
          @state = :invalid
          @invalid_reason = ParseFailurePorcelain.new(p)
        end
      end
      case @state
      when :valid   ; true
      when :invalid ; false
      else          ; fail("unexpected state: #{@state}")
      end
    end
    delegates_to_truish_ivar '@pathname', :writable?
  end
  MyPathname = Skylab::Face::MyPathname
  class << Config::File
    def parser_class
      @parser_class ||= begin
        # require "#{Config::DIR}/file-parser" # if etc ..
        Treetop.load "#{Config::DIR}/file-parser"
        # result is Config::FileParser
      end
    end
    def parser
      @parser ||= parser_class.new
    end
  end
end

