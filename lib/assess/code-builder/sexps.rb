require 'assess/util/strict-attr-accessors'
module Hipe
  module Assess
    module CodeBuilder

      class FileSexp < Sexp
        undef_method :method_missing # too much pita
        include ModuleAutovivifyingSexp, BlockeySexp
        extend StrictAttrAccessors
        string_attr_accessor :path
        class << self

          def build path
            if File.exist? path
              ruby = File.read(path)
              if ruby.strip != ""
                sexp = CodeBuilder.parser.process(ruby)
                sexp = file_sexp_to_block_sexp sexp
                thing = new()
                thing.path = path
                thing.replace sexp
              else
                thing = new(:block)
                thing.path = path
              end
            else
              thing = new(:block)
              thing.path = path
            end
            fail("we always want our file nodes to be blocks(?)") unless
              thing.first == :block
            BlockeySexp[thing] unless thing.kind_of?(BlockeySexp)
            thing
          end

          def file_sexp_to_block_sexp sexp
            case sexp.first
            when :block
              return sexp
            when :call
              result = s(:block, sexp)
              BlockeySexp[result]
              return result
            else
              msg = ("this is probably ok but we should check it:"<<
                " #{sexp.first.inspect}. be sure you can still to_ruby"<<
                "on the result.")
              fail(msg)
            end
          end

        end

        def exists?
          File.exist? path
        end

        def add_require_at_top str
          assert_type :str, str, String
          thing = s(:call, nil, :require, s(:arglist, s(:str, str)))
          block.insert(1, thing)
        end

        #
        # can be used to detect the requires of typical rubygems
        #
        def simple_requires
          founds = []
          block.find_nodes(:call).each do |node|
            # s(:call, nil, :include, s(:arglist, s(:str, "foo"))),
            next unless node[2] == :require
            next unless node[3].first == :arglist && node[3].length == 2
            next unless node[3][1].first == :str
            founds.push node[3][1][1]
          end
          founds
        end

        # file must exist
        def backup ui, opts
          fail("no") unless exists?
          case opts.backup
          when :with_extension
            overwrite_prev = true
            dest = "#{path}#{opts.extension}"
          when :yes
            overwrite_prev = false
            dest = find_next_backup_name
          else
            fail("unhandled backup case: #{opts.backup.inspect}")
          end
          fail("no") if File.exist?(dest) && ! overwrite_prev
          opts = {:preserve=>true, :verbose=>true, :noop=>opts.dry_run?}
          FileUtils.cp path, dest, opts
        end

        def write ui, opts
          ruby = to_ruby
          len1 = ruby.length
          len2 = nil
          if File.exist?(path) && ruby == File.read(path)
            ui.puts "#{len1} bytes unchanged in #{path}"
          else
            backup(ui,opts) if File.exist?(path) && opts.backup?
            File.open(path,'w'){|fh| len2 = fh.write ruby} unless
              opts.dry_run?
            ui.puts "wrote #{len2.inspect} of #{len1} bytes to #{path}"
          end
          nil
        end

        def prune_backups ui, opts
          use_opts = {:verbose=>true, :noop=>opts.dry_run?}
          files, glob, _ = existing_backups_info
          if files.any?
            FileUtils.rm files, use_opts
          else
            ui.puts("Found no backup files to remove matching "<<
              " #{glob.inspect}")
          end
          nil
        end

      private

        def block
          fail("our file sexp got corrupted somehow?") unless first == :block
          self
        end

        #
        # with a file named "foo.rb", make names like foo.bak1.rb,
        # foo.bak2.rb ... etc.
        #
        # (preserves the final extension unless there is none.)
        #
        # This doesn't want to spin out of control if for some reason
        # it goes crazy trying to make new files; also this doesn't want
        # to inadvertently overwrite anything; so an error is thrown
        # if the number of existing backup files for a file has reached
        # a count of 9.
        #
        # split on any dot that has one or more not dots after it
        # "foo.tgz" => ['foo','tgz']  "foo.tar.gz"=>['foo.tar','gz']
        #    "foo"=>["foo"]
        #
        def find_next_backup_name
          files, glob, numbers, items = existing_backups_info
          available = (0..3).map - numbers
          unless available.any?
            flail("All backup slots are full. "<<
            "Please move or remove files matching the "<<
            "pattern: \"#{glob}\".")
          end
          available.sort!
          use_number = available.first
          items.insert(1, "bak#{use_number}")
          use_path = items.join('.')
          use_path
        end

        FinalExtensionRe = /\.(?=[^\.]+$)/
        #
        # @return [files, glob, numbers, items]
        #
        def existing_backups_info
          items = path.split(FinalExtensionRe)
          items2 = items.dup
          items2.insert(1,'bak[0-9]')
          glob = items2.join('.')
          existing_backups = Dir[glob]
          re = ['bak([0-9])']
          re.push(Regexp.escape(items[1])) if items[1]
          re = re.join('.')
          re.concat('\Z')
          re = Regexp.new(re)
          numbers = existing_backups.map{|x| x.match(re)[1].to_i }
          [existing_backups, glob, numbers, items]
        end
      end

      class ModuleSexp < Sexp
        include ModuleySexp
        undef_method :method_missing # too much pita
        def self.build name, &block
          name_sexp = CodeBuilder.module_name_sexp name
          thing = new(:module, name_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end
      end

      class ClassSexp < ModuleSexp
        include ClassySexp

        def self.build name_sym, extends_str, &block
          extends_str = extends_str.to_s
          if ""==extends_str
            extends_sexp = nil
          else
            extends_sexp = CodeBuilder.parser.process(extends_str)
          end
          name_sexp    = CodeBuilder.module_name_sexp name_sym
          thing = new(:class, name_sexp, extends_sexp, s(:scope, s(:block)))
          yield(thing) if block_given?
          thing
        end
      end
    end
  end
end
