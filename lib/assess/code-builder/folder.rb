require 'assess/util/token-tree'
module Hipe
  module Assess
    module CodeBuilder
      module FolderSupport
        module Pathy
          def path
            has_parent? ? File.join(parent.path, token) : @path
          end
          def set_path path, parent
            if parent
              # nothing for now!
            else
              @path = path
            end
          end
        end
        class UnparsedFile
          class << self
            def all; Folder.all end
            def get_from_path(path)
              new{|it| it.init_from_path(path)}
            end
          end
          attr_reader :path, :filesystem_node_id
          def initialize(&block)
            @filesystem_node_id = self.class.all.length
            self.class.all[filesystem_node_id] = self
            yield(self)
          end
          def init_from_path path
            @path = path
          end
          def get_file_contents
            if ! File.exist?(path)
              fail("can't get file contents for nonexistant file: #{path}")
            end
            File.read(path)
          end
        end
        class FileStub
          class << self
            def all; Folder.all end
            def convert_to_sexp_and_call obj, meth, args
              sexp = convert_filestub_to_sexp(obj)
              sexp.send(meth,*args)
            end
            def convert_filestub_to_sexp obj
              if obj.has_existing_sexp?
                sexp = obj.existing_sexp
              else
                source_path = obj.source_path
                sexp = CodeBuilder::FileSexp.get_from_path source_path
                sexp.path = obj.target_path
                if obj.has_parent?
                  obj.parent.replace_child(obj, sexp)
                end
                obj.destroy_self!
                obj.existing_sexp = sexp
              end
              sexp
            end
          end
          include TokenTree::LeafNode
          include Pathy
          def initialize token, parent
            token_tree_init token, parent
            set_path token, parent
          end
          def dir?; false; end
          def is_stub?; true end
          SexpTriggers = [:replace_node, :codepath, :codepath_all]
          SexpTriggers.each do |meth|
            define_method(meth) do |*a|
              self.class.convert_to_sexp_and_call(self,meth,a)
            end
          end
          def has_existing_sexp?
            !! @existing_sexp
          end
          def existing_sexp
            @existing_sexp
          end
          def existing_sexp= mixed
            fail("no") unless mixed
            @existing_sexp = mixed
          end
          def to_sexp
            has_existing_sexp? ? existing_sexp : CodeBuilder::file_sexp_from_path(path)
          end
          def get_file_contents
            if ! File.exist?(path)
              fail("can't get file contents for nonexistant file: #{path}")
            end
            File.read(path)
          end
          def destroy_self!
            self.class.all[token_tree_id] = :destroyed
          end
          def source_path
            path
          end
        end
        class IntermediateFileCopy < FileStub
          include FileWriter
          def initialize x, y, source
            super(x,y)
            @source_node_id = source.token_tree_id
          end
          def source
            Folder.all[@source_node_id]
          end
          def source_path
            source.path
          end
          alias_method :target_path, :path
          def to_sexp
            CodeBuilder.get_file_sexp source.path
          end
          def destroy_self!
            # no references to self to nullify
          end
          def get_source_file_contents
            source.get_file_contents
          end
          def replace_content_with_path path
            source = UnparsedFile.get_from_path path
            self.source.destroy!
            @source_node_id = source.filesystem_node_id
          end
        end
      end
      class Folder < TokenTree
        include FolderSupport
        include CommonInstanceMethods, Pathy, TokenTree::BranchNode
        extend CommonInstanceMethods
        @all = []
        class << self
          attr_reader :all
          def create_or_get path
            new(path){|f| f.create!}
          end
          def from_existing_folder path
            flail("folder doesn't exist or is not directory") unless
              File.directory?(path)
            new path
          end
          def intermediate_deep_copy path, other_dir
            f = new(path){|f| f.no_read! }
            f.init_intermediate_deep_copy other_dir
            f
          end
        end
        attr_reader :is_stub
        alias_method :is_stub?, :is_stub
        def initialize path, parent=nil, &block
          @is_stub = true
          @read = true
          use_path = parent ? File.join(parent.path,path) : path
          if File.exist?(use_path)
            if ! File.directory?(use_path)
              flail("no way #{use_path}")
            else
              set_path path, parent
            end
          else
            # FileUtils.mkdir(use_path)
            set_path path, parent
          end
          token_tree_init path, parent
          yield(self) if block_given?
          if no_read?
            @children = []
          end
        end
        def no_read!
          @read = false
          @is_stub = false
        end
        def create!
          if ! File.exist?(path)
            FileUtils.mkdir_p(path,{:verbose=>1})
          end
        end
        def destory_children!
          unless is_stub?
            super
          end
        end
        def replace_child old, nu
          idx = index_of_child_strict old
          @children[idx] = nu
          nil
        end
        def child_destroy_notify child
          idx = index_of_child_strict child
          @children.delete_at idx
          nil
        end
        def init_intermediate_deep_copy dir
          @children = Array.new(dir.children.length)
          dir.children.each_with_index do |node,idx|
            if node.dir?
              child = Folder.new(node.token, self){|f| f.no_read!}
              child.init_intermediate_deep_copy(node)
            else
              child = IntermediateFileCopy.new(node.token, self, node)
            end
            @children[idx] = child
          end
          @is_stub = false
          nil
        end
        def is_stub?; @is_stub end
        def has_child? str
          populate if is_stub?
          super str
        end
        def children
          populate if is_stub?
          super
        end
        def has_children?
          children.any?
        end
        def _set_children! chld
          @childre = child
        end
        def refresh!
          populate
        end
        def dir?; true end
        def paths
          token_tree_flatten.map do |arr|
            File.join(*arr)
          end
        end
        def special_prune_hack!
          unless children.size == 1
            fail("can't special prune unless only one child")
          end
          child = children[0]
          if child.has_parent?
            fail("no problem but needs logic")
            # child.def! :parent_id, false
          end
          child.instance_variable_set(
            '@parent_token_tree_id',
            parent.token_tree_id
          )
          child.meta.send(:define_method,:parent){
            Folder.all[@parent_token_tree_id]
          }
          ext = File.extname(child.token)
          me = token
          nu = "#{me}#{ext}"
          child.redefine! :token, nu
          child.extend Pathy # overwrites path() not @path
          parent.replace_child(self,child)
          nil
        end
        def execute_write_request ui, opts
          unless opts[:col1]
            longest = deep_leaf_children.map{|c|c.path.length}.
              inject { |m,len| m > len ? m : len }
            opts[:col1] = longest
            opts[:col2] ||= 6
            opts[:col3] ||= 6
          end
          deep_leaf_children.each do |child|
            child.execute_write_request ui, opts
          end
          prune_child_directories(ui, opts) if opts.prune?
          nil
        end
      private
        def prune_child_directories ui, opts
          opts2 = {:noop => opts.dry_run?, :verbose => true}
          deep_branch_children.each do |child|
            ch_path = child.path
            next if ch_path == './'
            name_str = ("%-#{opts[:col1]}s" % "#{ch_path}/")
            if ! File.exist?(ch_path)
              ui.puts "#{name_str} - it's not exist"
            elsif Dir[File.join(ch_path,'/*')].any?
              ui.puts "#{name_str} - not empty."
            else
              ui.print "#{name_str} - "
              FileUtils.rmdir(ch_path, opts2)
            end
          end
        end
        def no_read?
          ! @read
        end
        def index_of_child_strict child
          idx = children.index{|x| x.token == child.token }
          other = @children[idx]
          if other.object_id != child.object_id
            fail('uh oh')
          end
          idx
        end
        def populate
          @children = []
          dir = Dir.new(path)
          dir.reject{|x| ['.','..'].include?(x)}.each do |token|
            node = nil
            path2 = File.join(path, token)
            if File.directory? path2
              child = Folder.new(token, self)
              @children.push child
            elsif File.exist? path2
              child = FileStub.new(token, self)
              @children.push child
            else
              flail("huh? #{path}")
            end
          end
          @is_stub = false
        end
      end # class
    end
  end
end
# @todo everybody should get filesystem_node_id
#
