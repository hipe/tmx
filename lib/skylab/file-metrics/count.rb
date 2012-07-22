module Skylab
  module Tmx
    module Modules
    end
  end
end

module Skylab::FileMetrics

  class Count
    def initialize name=nil, count=nil, fields=nil
      name and set_field(:name, name)
      count and set_field(:count, count)
      fields and fields.each { |k,v| set_field(k, v) }
    end
    attr_reader   :children # might be nil
    attr_writer   :total # only use this carefully!

    # children
    def children?
      (@children ||= nil) and @children.any?
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
      if (@total ||= nil)
        @total # this should only be used very carefully!
      elsif ! children?
        (@count ||= nil)
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
      if children?
        @children.each { |c| c.lines(lines) }
      else
        lines.push fields.map{ |f| "#{f}: #{send(f).inspect}" }.join(' ')
      end
      lines
    end
  end
end
