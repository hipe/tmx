module Skylab::Treemap
  class API::Render::CSV
    extend Skylab::PubSub::Emitter
    emits payload: :all, error: :all, info: :all

    def self.invoke(*a, &b)
      new(*a, &b).invoke
    end

    def clear!
      @current_line_number = 0
    end

    DENY_RE = %r{[^-/a-z0-9 ]}i
    PATH_DENY_RE = %r{/}

    class Row < Struct.new(:id, :area, :group, :color)
      def string
        values.map do |v|
          case v
          when NilClass      ; ''
          when Float, Fixnum ; v.to_s
          else %("#{v.to_s.gsub(DENY_RE,'')}")
          end
        end.join ','
      end
    end

    def emit_line node, path_parts
      @row.id = (@current_line_number += 1)
      path = path_parts + [node.content]
      path = path.map { |s| s.gsub(PATH_DENY_RE, '') }.join('/')
      @row.area = (rand * 1000).to_i
      @row.group = path
      @row.color = (rand * 1000).to_i
      emit(:payload, @row.string)
    end

    def emit_first_line
      emit(:payload, 'id, area, group, color')
    end

    def initialize tree
      @row = Row.new
      yield self
      @tree = tree
    end

    def info msg
      emit(:info, msg)
    end

    def invoke
      clear!
      emit_first_line
      Models::Node::Visitor.new(@tree).invoke do |o|
        o.on_visit do |e|
          emit_line e.payload.node, e.payload.path
        end
      end
    end
  end
end

