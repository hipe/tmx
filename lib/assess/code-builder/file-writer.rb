module Hipe
  module Assess
    module CodeBuilder
      module FileWriter

        def write_ruby ui, opts
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

        def execute_write_request ui, opts
          contents = get_source_file_contents
          len1 = contents.length
          a, b, c = opts.values_at(:col1, :col2, :col3)
          path_str = "%-#{a}s" % path
          opts[:contents] = contents
          opts[:path_str] = path_str
          if opts.prune?
            prune_same ui, opts, path
          elsif File.exist?(path)
            if opts.code_merge?
              flail('Sorry, code_merge not yet implemented.')
            elsif(File.read(path) == contents)
              ui.puts("#{path_str} - no change" % [path])
            else
              ui.puts("#{path_str} - exists -- skipping")
            end
          else
            bytes = nil
            dir_path = File.dirname(path)
            if ! File.directory?(dir_path)
              opts2 = {:verbose=>1,:noop=>opts.dry_run?} # @todo modes
              ui.print("#{path_str} - ")
              FileUtils.mkdir_p(dir_path, opts2)
            end
            if ! opts.dry_run?
              File.open(path,'w+'){|fh| bytes = fh.write(contents)}
            end
            ui.puts("#{path_str} - wrote %#{b}s of %#{c}d bytes" %
              [bytes.inspect, len1]
            )
          end
        end

        def prune_same ui, opts, path
          if ! File.exist?(path)
            ui.puts("#{opts[:path_str]} - it's not exist, nothing to prune")
          elsif File.read(path) == opts[:contents]
            opts2 = {:verbose=>1, :noop=>opts.dry_run?}
            ui.print "#{opts[:path_str]} - "
            FileUtils.rm(path, opts2)
          else
            ui.puts "#{opts[:path_str]} - has changes. skipping."
          end
        end

        #
        # file must exist
        #
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


        # with a file named "foo.rb", make names like foo.bak1.rb,
        # foo.bak2.rb ... etc.
        #
        # (preserves the final extension unless there is none.)
        #
        # This doesn't want to spin out of control if for some reason
        # it goes crazy trying to make new files; also this doesn't want
        # to inadvertently overwrite anything; so an error is thrown
        # if the number of existing backup files for a file has reached
        # a count of some hard coded amount. (3? 9?).
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
      end
    end
  end
end

