require 'pathname'
require 'treetop'
require 'skylab/face/path-tools'
require 'skylab/slake/muxer'
require File.expand_path('..', __FILE__)

module Skylab::CodeMolester
  class Config::File < Pathname
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all
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
    def initialize(*a, &b)
      @valid = @invalid_reason = nil
      b and b.call(self)
      super(*a)
    end
    attr_reader :invalid_reason
    def lines
      valid? or return false
      content_tree.lines
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
          @invalid_reason = self.class.render_failure_message(p)
        end
      end
      @valid
    end
  end
  class << Config::File
    def parser_class
      @parser_class ||= begin
        dir = File.expand_path('..', __FILE__)
        require "#{dir}/file-node-classes"
        pc = Treetop.load "#{dir}/file-node"
        pc
      end
    end
    def parser
      @parser ||= parser_class.new
    end
    def render_failure_message parser
      a = parser.terminal_failures
      "#{to_s} Parse Failure: Expecting #{a.map { |o| [o.index, o.expected_string].inspect }.join(', ')}"
    end
  end
end

