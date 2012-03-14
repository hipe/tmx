require File.expand_path('..', __FILE__)
prev = $VERBOSE ; $VERBOSE = false
require 'treetop'
$VERBOSE = prev # treetop is naughty (@todo etc?)
require 'skylab/face/path-tools'
require 'skylab/pub-sub/emitter'

module Skylab::CodeMolester
  module Config
    require DIR.join('../parse-failure-porcelain')
    require DIR.join('../sexp')
    require "#{DIR}/node"
  end

  class Config::File < Pathname
    extend ::Skylab::PubSub::Emitter
    emits :all, :info => :all, :error => :all

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
      @content_string = @invalid_reason = @valid = nil
      b and b.call(self)
      a.last.kind_of?(Hash) and
        a.pop.each { |k, v| :path == k ? (a.unshift(v.to_s)) : send("#{k}=", v) }
      super(*a)
    end
    def invalid_reason
      @valid.nil? and valid?
      @invalid_reason
    end
    alias_method :path, :to_s
    def pretty
      ::Skylab::Face::PathTools.pretty_path(to_s)
    end
    def unparse
      valid? ? @content_tree.unparse : @content_string
    end
    alias_method :content, :unparse
    def write
      fail("reimplement me")
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

