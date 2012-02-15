require File.expand_path('..', __FILE__)
require 'treetop'
require 'skylab/face/path-tools'
require 'skylab/slake/muxer'

module Skylab::CodeMolester
  module Config
    require DIR.join('../parse-failure-porcelain')
    require DIR.join('../sexp')
    require "#{DIR}/file-node-classes"
  end

  class Config::File < Pathname
    extend ::Skylab::Slake::Muxer
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
    %w(content_items [] set_value).each do |n| # @delegator
      define_method(n) do |*a|
        valid? or return false
        @content_tree.send(n, *a)
      end
    end
    alias_method :[]=, :set_value
    def initialize(*a, &b)
      @valid = @invalid_reason = nil
      b and b.call(self)
      a.last.kind_of?(Hash) and
        a.pop.each { |k, v| :path == k ? (a.unshift(v.to_s)) : send("#{k}=", v) }
      super(*a)
    end
    def invalid_reason
      @valid.nil? and valid?
      @invalid_reason
    end
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
        # require "#{Config::DIR}/file-node"
        # Config::FileNodeParser
        Treetop.load "#{Config::DIR}/file-node"
      end
    end
    def parser
      @parser ||= parser_class.new
    end
  end
end

