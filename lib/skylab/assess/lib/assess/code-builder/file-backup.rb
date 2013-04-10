require 'pathname'
require 'shellwords'

module Hipe::Assess
  module FileBackup
    #
    # This was originally part of file subclasses and modules.
    # Extendees will somehow represent the file to be backed up
    # and must respond to:
    #  - exists?
    #  - path
    #
    # (all such calls to client methods should be prefixed with 'self' here)
    #
    # The opts being passed around here should probably parsed by
    # the FileBackupOptions common option set.
    #

    class << self
      def [](mixed)
        case mixed
        when String, Pathname
          res = mixed.kind_of?(String) ? Pathname.new(mixed) : mixed
          unless res.kind_of?(FileBackup)
            res.extend self
            res.extend PathnameAdapter
          end
          res
        else
          fail("haven't defined an initializer or adapter for #{mixed}")
        end
      end
    end

    module PathnameAdapter
      def exists?
        self.exist?
      end
      def path
        self.to_str
      end
    end

    def prune_same ui, opts, path, path_str, contents
      if ! File.exist?(path)
        ui.puts("#{path_str} - it's not exist, nothing to prune")
      elsif File.read(path) == contents
        opts2 = {:verbose=>1, :noop=>opts.dry_run?}
        ui.print "#{path_str} - "
        FileUtils.rm(path, opts2)
      else
        ui.puts "#{path_str} - has changes. skipping."
      end
    end

    # file must exist
    #
    def backup ui, opts
      fail("no") unless self.exists? and opts.backup?
      if opts.with_datestamp?
        ext = DateTime.now.strftime('%Y-%m-%d_%H-%M-%S')
        dest = "#{path}.#{ext}.bak"
        overwrite_prev = true
      elsif opts.with_custom?
        ext = opts.backup_ext
        dest = "#{path}#{opts.backup_ext}"
        overwrite_prev = true
      elsif opts.with_integers?
        overwrite_prev = false
        dest = find_next_backup_name
      else
        fail("huh?")
      end
      fail("no") if File.exist?(dest) && ! overwrite_prev
      opts2 = {:preserve=>true, :verbose=>true, :noop=>opts.dry_run?}
      FileUtils.cp path, dest, opts2
    end

    # @return [files, glob, numbers, items]
    #
    def existing_backups_info
      items = self.path.split(Const::ExtRe)
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
      opts2 = {:verbose=>true, :noop=>opts.dry_run?}
      files, glob, _ = existing_backups_info
      if files.any?
        FileUtils.rm files, opts2
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
    def find_next_backup_name
      files, glob, numbers, items = existing_backups_info
      available = (0..Config.max_backup_slots).map - numbers
      unless available.any?
        Common.flail(
        "#{Cmd.soft_name}: "<<
        "All #{Config.max_backup_slots} backup slots are full."<<
        " Please move or remove files matching the pattern: \"#{glob}\".\n"<<
        "e.g.: "<<Shellwords.shelljoin(['rm'] + files)<<"\n"){here!; no_help!}
      end
      available.sort!
      use_number = available.first
      items.insert(1, "bak#{use_number}")
      use_path = items.join('.')
      use_path
    end
  end
end
