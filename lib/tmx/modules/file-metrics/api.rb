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

  class Api::LineCount
    include PathTools
    def self.run paths, opts, ui
      new(paths, opts, ui).run
    end
    def initialize paths, opts, ui
      @paths, @opts, @ui = [paths, opts, ui]
      # do defaults, normalization now, once in case we want to re-run for some awful reason
      @paths.empty? and @paths.push('.')
    end
    def run
      files = self.files
      @opts[:show_files_list] and @ui.err.puts(files)
      @opts[:show_report] or return true
      count =
      if @opts[:count_blank_lines] && @opts[:count_comment_lines]
        linecount_using_wc files
      else
        fail("pending implementation @todo")
      end
      if count.no_children?
        @ui.err.puts "no files found."
      else
        total = count.total.to_f
        count.sort_children_by! { |c| -1 * c.total }
        max = count.children.map(&:total).max.to_f
        count.children.each { |c| c.set_field(:total_share, c.total.to_f / total ) }
        count.children.each { |c| c.set_field(:max_share, c.total.to_f / max ) }
        tableize count, @ui.err
      end
    end
  protected
    def build_find_command
      FindCommand.build do |f|
        f.paths = @paths
        f.skip_dirs = @opts[:exclude_dirs]
        f.names = @opts[:include_names]
        f.extra = '-not -type d'
      end
    end

    def files
      tree = []
      @paths.each do |path|
        if File.directory? path
          tree.push [:directory, path, files_in_dir(path)]
        elsif File.file? path
          tree.push [:file, path]
        else
          @ui.err.puts "not a file or directory, skipping: #{path}"
        end
      end
      tree.map{ |n| n.first == :file ? n[1] : n[2] }.flatten
    end

    def files_in_dir path
      cmd = build_find_command
      @opts[:show_commands] and @ui.err.puts(cmd)
      `#{cmd}`.split("\n")
    end

    def linecount_using_wc files
      count = Count.new('.')
      files.empty? and return count
      _ = "wc -l #{files.map{ |x| escape_path(x) } * ' '} | sort -g"
      @opts[:show_commands] and @ui.err.puts(_)
      lines = `#{_}`.split("\n")
      case lines.size
      when 0
        raise SystemInterfaceError.new("never")
      when 1
        /\A *(\d+) (.+)\z/ =~ lines.first or
          raise SystemInterfaceError.new("regex failed to match: #{lines.first}")
        count.add_child(Count.new($2, $1.to_i))
        # truncated form looses information:
        # count.name = $2; count.count = $1.to_i
      else
        lines[0..-2].each do |line|
          /\A *(\d+) (.+)\z/ =~ line or
            raise SystemInterfaceError.new("regex failed to match: #{line}")
          count.add_child(Count.new($2, $1.to_i))
        end
        (/\A *(\d+) total\z/ =~ lines.last and $1.to_i) or
          raise SystemInterfaceError.new("regex failed to match: #{lines.last}")
        count.total = $1.to_i # might as well use this one and not calculate it ourselves
      end
      count
    end

    def tableize count, out
      return unless count.any_children?
      Table.render(
        [count.children.first.fields.map do |f|
          f = case f
          when :count ; 'Lines'
          else f
          end
          f.to_s.split('_').map(&:capitalize).join(' ')
        end] +
        count.children.map do |_count|
          _count.fields.map do |field|
            case field
            when :total_share, :max_share
              "%0.2f%%" % (_count.send(field) * 100)
            else
              _count.send(field).to_s
            end
          end
        end,
        out
      )
    end
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
