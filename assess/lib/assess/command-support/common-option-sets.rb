module Hipe::Assess

  module OptionSet
    class << self
      def [](mixed)
        mixed.extend self
      end
    end
  end

  FileBackupOptions = OptionSet[lambda{|o|
    o.on '-d, --dry', :dry_run?,
           "dry run -- don't actually do anything, just show a preview."

    o.on '-p, --prune', :prune_backups?,
           "maybe remove backup files that you have generated."

    o.on( '-i=STR', :backup_ext,
           'files are altered in-place always. The default is to make a',
           'copy with incremental integers. If you pass the emtpy string',
           'as an argument, no backup will be made.  If you pass the string',
           '"<time>", a datetime will be used.',
           :default => '<int>'
    ){
      o.def!(:backup?, ''!=o.backup_ext)
      if o.backup?
        o.def!(:with_datestamp?, '<time>'==o.backup_ext)
        o.def!(:with_integers?, '<int>'==o.backup_ext)
        o.def!(:with_custom?, !(o.with_datestamp? || o.with_integers?))
      end
    }
  }]
end
