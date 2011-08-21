require 'shellwords'
require 'ruby-debug'
require "#{File.dirname(__FILE__)}/table"

module Skylab::Tmx::Modules::FileMetrics
  module PathTools
    def escape_path path
      (path =~ / |\$|'/) ? Shellwords.shellescape(path) : path
    end
  end
  class FindCommand
    include PathTools
    def initialize; end
    attr_accessor :paths, :skip_dirs, :names, :extra
    def self.build &block
      fc = new
      yield fc
      fc
    end
    def render
      parts = ["find"]
      parts.push @paths.map { |p| escape_path(p) }.join(' ')
      if @skip_dirs && @skip_dirs.any?
        paths = @skip_dirs.map{ |p| escape_path(p) }
        parts.push '-not \( -type d \( -mindepth 1 -a'
        parts.push paths.map{ |p| " -name '#{p}'" }.join(' -o')
        parts.push "\\) -prune \\)"
      end
      @extra and parts.push @extra
      if @names && @names.any?
        paths = @names.map{ |p| escape_path(p) }
        _ = @names.map{ |p| " -name '#{escape_path(p)}'"}.join(' -o')
        parts.push "\\(#{_} \\)"
      end
      parts.join(' ')
    end
    alias_method :to_s, :render
  end
end

module Skylab::Tmx::Modules::FileMetrics
  module Api
   class RuntimeError < ::RuntimeError; end
   class SystemInterfaceError < RuntimeError; end
  end
  class Count
    def initialize name=nil, count=nil
      name and set_field(:name, name)
      count and set_field(:count, count)
    end
    attr_reader   :children # might be nil
    attr_writer   :total # only use this carefully!

    # children
    def no_children?
      @children.nil? or ! @children.any?
    end
    def any_children?
      @children and @children.any?
    end
    def add_child child
      @children ||= []
      @children.push child
    end
    def sort_children_by! &b
      @children = @children.sort_by(&b)
    end

    # fields
    attr_reader :fields
    def set_field name, value
      @fields ||= []
      @fields.include?(name) or @fields.push(name)
      respond_to?(name) or class << self; self end.send(:attr_reader, name)
      respond_to?("#{name}=") or class << self; self end.send(:attr_writer, name)
      instance_variable_set("@#{name}", value)
    end

    # stats
    def total
      if @total
        @total # this should only be used very carefully!
      elsif no_children?
        @count
      else
        @children.map(&:total).inject(:+)
      end
    end

    # output and formatting
    def to_s
      lines.join("\n")
    end
    def lines lines=nil
      lines ||= []
      if any_children?
        @children.each { |c| c.lines(lines) }
      else
        lines.push fields.map{ |f| "#{f}: #{send(f).inspect}" }.join(' ')
      end
      lines
    end
  end
end
