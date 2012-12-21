module Skylab::TanMan

  class Services::Diff

  public

    def diff file_path_before, file_path_after, opts=nil, error=nil, info=nil
      changeset = nil
      begin
        cmd = Services::Diff::Command.new file_path_before, file_path_after
        info && info[ cmd.string ]
        popen3_ok = false
        Services::Open3.popen3( cmd.string ) do |sin, sout, serr|
          e = serr.read
          if '' != e
            break( error && error[ e ] )
          end
          changeset = Services::Diff::Changeset.new cmd
          while line = sout.gets
            changeset << line
          end
          popen3_ok =  true
        end
        popen3_ok or break
      end while nil
      changeset
    end

  protected

    def initialize
    end
  end
end
