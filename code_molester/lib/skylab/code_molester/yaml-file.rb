module Skylab::CodeMolester
  module Yaml
    class Node
      def initialize
      end
      # because of some facepalming decisions of how yaml trees are represented in psych, this.
      # this has some facepalming vulnerabilities of its own
      def init_from_psych_tree psych
        if ! psych.kind_of? Home_::Library_::Psych::Nodes::Mapping
          fail "needed Psych::Nodes::Mapping, had: #{ psych.class }"
        end
        tree? or _change_to_tree!
        key = nil
        i = -1 ; length = psych.children.length ; while (i+=1) < length
          child = psych.children[i]
          if child.children
            node = Node.new
            node.init_from_psych_tree child
            _set_child key, node
            key = nil
          elsif key
            node = Node.new
            node.value = child.value
            _set_child key, node
            key = nil
          else
            key = child.value
          end
        end
        nil
      end
      def leaf?
        @children_hash.nil?
      end
      def tree?
        ! @children_hash.nil?
      end
      def change_to_tree!
        @value.nil? or @value = nil # don't create attribute if not set
        @ordered_keys = []
        @children_hash = {}
      end
      def key? key
        tree? or return false
        @children_hash.key? key.intern
      end
      def []= k, v
        node!(k).value = v
      end
      def [] k
        tree? or return nil
        @children_hash[k]
      end
      def value= val
        leaf? or fail("won't demote tree to leaf (for now)")
        @value = val
      end
      attr_reader :value
      def node! key
        tree? or _change_to_tree!
        if @children_hash.key?(key = key.intern)
          @children_hash[key]
        else
          @ordered_keys.push key
          @children_hash[key] = Node.new
        end
      end
      def _set_child key, val
        unless @ordered_keys.include?(key = key.intern)
          @ordered_keys.push key
        end
        @children_hash[key] = val
      end
      private :_set_child
      def to_string margin=nil, opts=nil
        if opts.nil? && margin.kind_of?(Hash)
          opts = margin
          margin = nil
        end
        opts ||= {}
        opts[:buffer] ||= ''.extend(BufferAdapter)
        if leaf?
          opts[:buffer].write(@value.to_s)
        else
          opts[:indent_with] ||= '  '
          margin ||= EMPTY_S_
          child_margin = "#{margin}#{opts[:indent_with]}"
          newline = nil
          @ordered_keys.each do |key|
            child = @children_hash[key]
            sep = child.leaf? ? SPACE_ : NEWLINE_
            opts[:buffer].write "#{newline}#{margin}#{key}:#{sep}"
            newline ||= NEWLINE_
            child.to_string(child_margin, opts)
          end
        end
        opts[:buffer]
      end
      def to_primitive
        leaf? and return @value
        hash = {}
        @ordered_keys.each do |key|
          hash[key] = @children_hash[key].to_primitive
        end
        hash
      end
      alias_method :data, :to_primitive # experimental
    private
      def _change_to_tree!
        @value.nil? or fail("won't change node to tree when a value is present!")
        change_to_tree!
      end
    end
  end
  module BufferAdapter
    def puts str
      str ||= EMPTY_S_
      str =~ /\n\Z/ or str = "#{str}\n"
      concat str
    end
    def write str
      concat str
    end
  end

  class YamlFile < Yaml::Node
    def initialize path
      @pathname = ::Pathname.new path.to_s
      if pathname.exist?
        parsed = Home_::Library_::YAML.parse pathname.read
        if false == parsed # empty file, special case
          # nothing for now
        else
          init_from_psych_tree parsed
        end
      end
    end
    attr_reader :pathname
    def exists?
      pathname.exist?
    end
    def write
      bytes = nil
      str = to_string(:indent_with => '  ')
      len = str.length
      len == 0 and return 0 # don't create empty files (for now)
      str =~ /\n\Z/ or str = "#{str}\n" # add newline to end of file if necessary
      pathname.open WRITE_MODE_ do |fh|
        fh.write str
        bytes = len
      end
      bytes
    end
  end
end