module Skylab::TMX::Modules::Bleed::API

  class Actions::Unbleed < Action

    listeners_digraph :bash, :error, :notice

    def invoke
      res = nil
      error = -> msg do
        call_digraph_listeners :bash, "echo #{ msg.inspect } ;"  # dodgy
        self.error msg
        false
      end
      begin
        p = ::ENV[ 'PATH' ] or break error[ "no PATH environment variable?" ]
        a = p.split ::File::PATH_SEPARATOR
        p = config_get_path or break error[ "can't unbleed because of above" ]
        p = ::Pathname.new( p ).expand_path.join( 'bin' ).to_s
        i = a.index( p ) or break error[ "PATH does not include path - #{ p }"]
        b = [ * a[ 0 ... i ], * a[ i + 1 .. -1 ] ]  # (paranoid compact)
        call_digraph_listeners :bash, "export PATH=\"#{ b * ':' }\" ;"
        call_digraph_listeners :bash, "echo \"removed from head of PATH - #{ p }\" ;"
        res = true
      end while nil
      res
    end
  end
end
