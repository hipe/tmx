module Skylab::Treemap
  class API::Render::CSV          # [#029] - #move render csv
                                  # [#030] - #doc-point there is randomness ..
    extend PubSub::Emitter

    emits payload: :all, error: :all, info: :all

    def self.[] tree              # render the tree as a string #exp
      io = Headless::Services::StringIO.new
      me = self.new tree  do |o|
        o.on_payload(& io.method(:puts))
      end
      me.send :execute # #special-privileges
      io.rewind
      io.read
    end

    def self.invoke *a, &b
      new( *a, &b ).send :execute # #special-privileges
    end

    # --*--

  protected

    row_struct = ::Class.new(
      ::Struct.new :id, :area, :group, :color ).class_eval do

      deny_rx = %r{[^-/a-z0-9 ]}i

      define_method :string do
        values.map do |v|
          case v
          when ::NilClass      ; ''
          when ::Float, ::Fixnum ; v.to_s
          else %("#{ v.to_s.gsub deny_rx, '' }")
          end
        end.join ','
      end

      self
    end

    define_method :initialize do |tree, &block|
      @row = row_struct.new
      block[ self ]
      @tree = tree
    end

    def clear!
      @current_line_number = 0
    end

    attr_reader :current_line_number

    path_deny_rx = %r{/}

    define_method :emit_line do |node, path_parts|
      @row.id = ( @current_line_number += 1 )
      path = path_parts + [ node.content ]
      path = path.map { |s| s.gsub path_deny_rx, '' }.join '/'
      @row.area = ( rand * 1000 ).to_i
      @row.group = path
      @row.color = ( rand * 1000 ).to_i
      emit :payload, @row.string
      nil
    end

    def emit_first_line
      emit :payload, 'id, area, group, color'
    end

    res_st = ::Struct.new :num_lines

    define_method :execute do
      clear!
      emit_first_line
      Models::Node::Visitor[ @tree, -> e do
        emit_line e.node, e.path
      end ]
      res_st.new current_line_number
    end
  end
end
