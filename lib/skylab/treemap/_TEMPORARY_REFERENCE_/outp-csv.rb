module Skylab::Treemap
  class Treemap::Services::File::CSV::Render < ::Enumerator
                                  # [#030] - #doc-point there is randomness ..

    # Despite our efforts at abstracting this out there is still a bit in
    # here that remains hard-coded..

    def self.[] tree              # render the tree as a string #exp
      self.new( tree ).string
    end

    attr_reader :current_line_number

    def string
      io = Headless::Services::StringIO.new
      _write io
      io.rewind
      io.read
    end

  private

    def initialize tree
      super(& method( :visit ) )
      @tree = tree
    end

    row_struct = ::Class.new( ::Struct.new :id, :area, :group, :color )
    row_struct.class_exec do

      deny_rx = %r{[^-/a-z0-9 ]}i

      define_method :string do
        values.reduce [] do |m, v|
          x = case v
          when ::NilClass        ; ''
          when ::Float, ::Fixnum ; v.to_s          # don't quote these
          else %("#{ v.to_s.gsub deny_rx, '' }")   # do quote these
          end
          m << x
        end.join ','
      end

      alias_method :to_s, :string
    end

    row = row_struct.new  # asking for it

    path_deny_rx = %r{/}

    define_method :_line do |o|  # `o` is a tree node flyweight
      @current_line_number += 1
      row.id = @current_line_number
      path = [ * o.path , o.node.content.strip ]
      path_s = path.map { |s| s.strip.gsub path_deny_rx, '' }.join '/'
      row.area = ( rand * 1000 ).to_i
      row.group = path_s
      row.color = ( rand * 1000 ).to_i
      @yield << row
      nil
    end

    num_lines = ::Struct.new :num_lines

    define_method :visit do |y|
      @yield = y
      @current_line_number = 0
      row.members.each_with_index { |k, i| row[i] = k.to_s } # hack the header
      @yield << row
      Models::Node::Visitor[ @tree, method(:_line) ]
      num_lines.new @current_line_number
    end

    def _write io
      reduce self do |m, row|
        io.puts row.string
      end
      nil
    end
  end
end
