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
    def initialize name=nil, count=nil, fields=nil
      name and set_field(:name, name)
      count and set_field(:count, count)
      fields and fields.each { |k,v| set_field(k, v) }
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

    def display_summary_for(field_name, &block)
      @column_summary_cel ||= {}
      @column_summary_cel[field_name] = block
    end

    def display_total_for(field_name, &render_total)
      render_total ||= default_render_total
      @column_summary_cel ||= {}
      @column_summary_cel[field_name] = lambda do
        _total = children.map(&field_name).map{ |v| v.nil? ? 0 : v }.inject(&:+)
        render_total.call(_total)
      end
    end

    def default_render_total &block
      if block_given?
        @default_render_total = block
        return self
      end
      @defalt_render_total ||= lambda do |mixed|
        (mixed.kind_of(Float) ? "Total: %.2f" : "Total: %d") % mixed
      end
    end

    def summary_rows
      children.nil?            || children.empty?            and return []
      @column_summary_cel.nil? || @column_summary_cel.empty? and return []
      field_names = children.first.fields
      [
        field_names.map do |sym|
          @column_summary_cel[sym] ? @column_summary_cel[sym].call : ''
        end
      ]
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
  module CommonCommandMethods
    def count_lines files, label=nil
      (_filters =
      [ (%s{grep -v '^[ \t]*$'} unless @req[:count_blank_lines]),
        (%s{grep -v '^[ \t]*#'} unless @req[:count_comment_lines])
      ].compact).empty? and return linecount_using_wc(files)
      cmd_tail = "#{_filters.join(' | ')} | wc -l"
      count = Count.new(label || '.') # count.add_child(Count.new($2, $1.to_i))
      files.each do |file|
        cmd = "cat #{escape_path(file)} | #{cmd_tail}"
        @req[:show_commands] and @ui.err.puts(cmd)
        _ = %x{#{cmd}}
        if _ =~ /\A[[:space:]]*(\d+)[[:space:]]*\z/
          count.add_child(Count.new(file, $1.to_i))
        else
          count.add_child(Count.new(file, 0, :notice => "(parse failed: #{_})"))
        end
      end
      count
    end

    def linecount_using_wc files
      count = Count.new('.')
      files.empty? and return count
      _ = "wc -l #{files.map{ |x| escape_path(x) } * ' '} | sort -g"
      @req[:show_commands] and @ui.err.puts(_)
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
        end + count.summary_rows,
        out
      )
    end
  end
end
