require File.expand_path('..', __FILE__)
require 'treetop'
require 'skylab/face/path-tools'
require 'skylab/slake/muxer'

module Skylab::CodeMolester
  module Config
    require DIR.join('../parse-failure-porcelain')
    require "#{DIR}/file-node-classes"
  end

  class Config::File < Pathname
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all

    include Config::FileNode::ItemBranchy

    alias_method :pathname_children, :children
    def children
      _parse_tree.select { |o| o.content? }
    end
    def content= str
      @valid = nil
      @content_tree = nil
      @content_string = str
    end
    def content_tree # @api private
      valid? ? @content_tree : false
    end
    %w(item_enumerator lines).each do |n| # @delegator
      define_method(n) do
        valid? or return false
        content_tree.send(n)
      end
    end
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
    def text_value
      valid? ? @content_tree.text_value : @content_string
    end
    alias_method :content, :text_value
    def write
      fail("reimplement me")
    end
    def valid?
      if @valid.nil?
        @content_string.nil? and @content_string = ''
        p = self.class.parser
        if @content_tree = p.parse(@content_string) # nil ok
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
        Treetop.load "#{Config::DIR}/file-node"
      end
    end
    def parser
      @parser ||= parser_class.new
    end
  end
end

