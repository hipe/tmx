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
      @valid = nil
      @content_tree = nil
      @content_string = str
    end
    def content_tree # @api private
      valid? ? @content_tree : false
    end
    %w([] content_items key? set_value sections value_items).each do |n| # @delegator
      define_method(n) do |*a|
        valid? or return false
        @content_tree.send(n, *a)
      end
    end
    alias_method :[]=, :set_value
    def initialize(*a, &b)
      @content_string = @invalid_reason = @on_read = @on_write = @valid = nil
      b and b.call(self)
      a.last.kind_of?(Hash) and
        a.pop.each { |k, v| :path == k ? (a.unshift(v.to_s)) : send("#{k}=", v) }
      super(*a)
    end
    def invalid_reason
      @valid.nil? and valid?
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
    class OnRead < Skylab::PubSub::Emitter.new(:all, :error => :all, :notice => :all)
      def error s ; emit(:error, s) ; false end
    end
    alias_method :pathname_read, :read
    def read
      e = OnRead.new
      if block_given? then yield(e) else on_read.call(e) end
      cntnt = super
      self.content = cntnt
      valid? or return e.error(invalid_reason)
      self
    end
    def unparse
      valid? ? @content_tree.unparse : @content_string
    end
    alias_method :content, :unparse
    class OnWrite < Skylab::PubSub::Emitter.new(:all, :error => :all, :notice => :all,
      :before_edit => :notice, :after_edit => :notice, :before_create => :notice, :after_create => :notice)
      def error msg
        emit :error, msg
        false
      end
    end
    def write
      e = OnWrite.new
      if block_given? then yield(e) else on_write.call(e) end
      bytes = nil
      if exist?
        e.emit(:before_edit, "updating #{pretty}")
        writable? or return e.error("cannot edit, file is not writable: #{pretty}")
        open('w') { |fh| bytes = fh.write(content) }
        e.emit(:after_edit, "updated #{pretty} (#{bytes} bytes)", bytes)
      else
        e.emit(:before_create, "creating #{pretty}")
        dirname.exist? or return e.error("parent directory does not exist, cannot write #{pretty}")
        dirname.writable? or return e.error("parent direcory is not writable, cannot write #{pretty}")
        open('w+') { |fh| bytes = fh.write(content) }
        e.emit(:after_create, "created #{pretty} (#{bytes} bytes)", bytes)
      end
      bytes
    end
    def valid?
      if @valid.nil?
        @content_string.nil? and @content_string = ''
        p = self.class.parser
        @content_tree = nil
        if expensive = p.parse(@content_string) # nil ok
          @content_tree = expensive.sexp
          @content_string = nil
          @valid = true
          @invalid_reason = nil
        else
          @valid = false
          @invalid_reason = ParseFailurePorcelain.new(p)
        end
      end
      @valid
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

