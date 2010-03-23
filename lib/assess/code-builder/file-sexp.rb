require 'assess/util/strict-attr-accessors'
module Hipe
  module Assess
    module CodeBuilder
      class FileSexp < Sexp
        include FileWriter
        undef_method :method_missing # too much pita
        include CommonSexpInstanceMethods
        BlockAutovivifyingSexp.has_block_at_index(self,:self)
        extend StrictAttrAccessors
        string_attr_accessor :path

        class << self
          def create_or_get_from_path path
            ruby = nil
            if (!File.exist?(path) || ""==(ruby=File.read(path)).strip)
              thing = self.new()
            else
              sexp = CodeBuilder.parser.process(ruby)
              thing = new(*sexp)
            end
            thing.path = path
            thing.enhance_sexp_node!
            thing
          end
          def get_from_path path
            ruby = File.read(path)
            sexp = CodeBuilder.parser.process(ruby)
            this = new(*sexp)
            this.path = path
            this.enhance_sexp_node!
            this
          end
        end

        #
        # for compatibility with folder
        #
        def branch?;  false end
        def is_stub?; false end
        def token; File.basename(@path) end
        def token_tree_flatten
          [[token]]
        end
        def get_source_file_contents
          to_ruby
        end
        #
        # end
        #

        def exists?
          File.exist? path
        end

        def add_require_at_top str
          assert_type :str, str, String
          thing = s(:call, nil, :require, s(:arglist, s(:str, str)))
          block!.insert(1, thing)
        end

        #
        # can be used to detect the requires of typical rubygems. hacky.
        #
        def simple_requires
          return [] unless any? # empty file
          founds = []
          unless :block == first
            fail("what's wrong with file? expecting block in #{path}, had"<<
            " #{first.inspect}")
          end
          find_nodes(:call).each do |node|
            # s(:call, nil, :include, s(:arglist, s(:str, "foo"))),
            next unless node[2] == :require
            next unless node[3].first == :arglist && node[3].length == 2
            next unless node[3][1].first == :str
            founds.push node[3][1][1]
          end
          founds
        end

        # assume user has called deep_enhance! already
        def module_tree
          if :module == first
            ModuleySexp.module_tree(self)
          elsif :block == first
            ModuleySexp.module_tree(self) # sure why not
          else
            fail("not want this #{first}")
          end
        end
      end
    end
  end
end
