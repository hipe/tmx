require File.expand_path('..', __FILE__)
require 'treetop'
require 'skylab/face/path-tools'
require 'skylab/slake/muxer'

module Skylab::CodeMolester
  module Config
    require DIR.join('../parse-failure-porcelain')
    require DIR.join('../sexp')
    require "#{DIR}/node"
  end

  class Config::File < Pathname
    extend ::Skylab::Slake::Muxer
    emits :all,
          :error     => :all,
          :info      => :all,
          :info_head => :all,
          :info_tail => :all

    alias_method :pathname_children, :children

    def content= str
      @valid = nil
      @content_tree = nil
      @content_string = str
    end
    def content_tree # @api private
      valid? ? @content_tree : false
    end
    %w([] content_items key? set_value value_items).each do |n| # @delegator
      define_method(n) do |*a|
        valid? or return false
        @content_tree.send(n, *a)
      end
    end
    alias_method :[]=, :set_value
    def error msg
      emit(:error, msg)
      false
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
    def unparse
      valid? ? @content_tree.unparse : @content_string
    end
    alias_method :content, :unparse

    # the below is wayy to porcelain-y to be here, but is just
    # a quick and dirty until we figure out a sane evented API for it
    # (because we certainly have the tools at this point)
    #
    def write
      if valid?
        content = self.content
        if content == ''
          emit(:info, "For now, won't write empty files.")
          return nil
        end
      else
        return error("Won't write #{pretty} - #{invalid_reason}")
      end
      if exist?
        if content == read
          emit(:info, "No change: #{pretty}")
          return nil
        else
          # backup - @todo FileServices
          emit(:info_head, "Rewriting #{pretty}")
          do_write = true
        end
      elsif dirname.exist?
        emit(:info_head, "Writing #{pretty}")
        do_write = true
      else
        return error("Won't write #{pretty}, parent directory not found.")
      end
      if do_write
        if exist? and (! writable?)
          emit(:info_tail, " .. not writable!")
          return error("Couldn't write #{to_s} - file was not writable")
        end
        bytes = nil
        File.open(to_s, 'w+') { |fh| bytes = fh.write(content) }
        emit(:info_tail, " .. done.")
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

