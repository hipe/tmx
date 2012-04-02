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

  class Config::File < Pathname

    alias_method :pathname_children, :children

    def content= str
      @content = str
      @state = :unparsed
    end
    def content_tree # @api private
      valid? ? @content : false
    end
    %w([] content_items key? set_value sections value_items).each do |n| # @delegator-like
      define_method(n) do |*a|
        if valid?
          @content.send(n, *a)
        else
          false
        end
      end
    end
    alias_method :[]=, :set_value
    def initialize(*a, &b)
      @content = @on_read = @on_write = nil
      @state = :initial
      b and b.call(self)
      a.last.kind_of?(Hash) and
        a.pop.each { |k, v| :path == k ? (a.unshift(v.to_s)) : send("#{k}=", v) }
      super(*a)
    end
    def invalid_reason
      valid?
      @invalid_reason
    end
    def on_read &b
      if b then @on_read = b else @on_read end
    end
    def on_write &b
      if b then @on_write = b else @on_write end
    end
    alias_method :path, :to_s
    def pretty
      ::Skylab::Face::PathTools.pretty_path(to_s)
    end
    OnRead = Skylab::PubSub::Emitter.new(:all, :error => :all, :invalid => :error)
    alias_method :pathname_read, :read
    def read
      e = OnRead.new
      if block_given? then yield(e) else on_read.call(e) end
      cntnt = super(&nil)
      self.content = cntnt
      if valid?
        self
      else
        e.emit(:invalid, invalid_reason)
        false
      end
    end
    def unparse
      valid? ? @content.unparse : @content
    end
    alias_method :string, :unparse
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
        if pathname_read == content
          e.emit(:no_change, "no change: #{pretty}")
        else
          e.emit(:before_edit) { { message: "updating #{pretty}", resource: self } }
          writable? or return e.error("cannot edit, file is not writable: #{pretty}")
          open('w') { |fh| bytes = fh.write(content) }
          e.emit(:after_edit) { { message: "updated #{pretty} (#{bytes} bytes)", bytes: bytes } }
        end
      else
        e.emit(:before_create) { { message: "creating #{pretty}", resource: self } }
        dirname.exist? or return e.error("parent directory does not exist, cannot write #{pretty}")
        dirname.writable? or return e.error("parent direcory is not writable, cannot write #{pretty}")
        open('w+') { |fh| bytes = fh.write(content) }
        e.emit(:after_create) { { message: "created #{pretty} (#{bytes} bytes)", bytes: bytes } }
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
  end
  MyPathname = Skylab::Face::MyPathname
  class << Config::File
    alias_method :config_file_new, :new
    # awesomely, subclasses of Pathname retain class identity when doing the getters
    # but we don't always want that in our weird case (oops @todo delgate instead)
    def new(*a, &b)
      if 1 == a.count and String === a.first and b.nil?
        MyPathname.new(*a, &b)
      else
        config_file_new(*a, &b)
      end
    end
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

