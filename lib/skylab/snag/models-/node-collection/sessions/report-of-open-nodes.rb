module Skylab::Snag

  # (will rewrite most of "report of open nodes")

    def bld_terse_node_yieldee
      m = @lines.method( :<< )
      ::Enumerator::Yielder.new do |n|
        @lines << n.first_line
        n.extra_line_a.each(& m ) if n.extra_lines_count.nonzero?
        nil
      end
    end

    def bld_yamlizing_node_yieldee

      downstream_yielder = Snag_.lib_.string_lib.yamlizer.curry_with(
        :output_line_yielder, @lines,
        :field_names, FIELD_NAMES__ )

      ::Enumerator::Yielder.new do | node |
        downstream_yielder << node.yaml_data_pairs
      end
    end
end
