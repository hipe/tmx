require 'assess/code-builder/file-backup'

module Hipe
  module Assess
    module CodeBuilder
      module FileWriter
        include FileBackup
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
          if opts.prune_generated?
            prune_same ui, opts, path, path_str, contents
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
      end
    end
  end
end

