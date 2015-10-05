module Skylab::GitViz::Tasks

  class Build_RBX

    class Install__

      def initialize y, url, version
        @y = y ; @url = url ; @version = version
      end

      def execute
        @y << "try something like the following (after the dashes)"
        @y << "(we would have tried to script this, but brew exists already)"
        @y << "#{ '-' * 80 }"
        @y << "wget --directory-prefix wazoozle #{ @url }"
        @y << "cd wazoozle ; tar -xjvf #{ ::File.basename @url }"
        @y << "cd rubinius-#{ @version }"
        @y << "bundle install"
        @y << "this=$( brew --prefix openssl )"
        @y << "./configure --prefix=$HOME/.rbenv/versions/rbx-#{ @version } #{
          }--with-openssl-dir=$this"
        @y << "rake install"
        @y << "#{ '-' * 80 }"
        @y << "good luck!"
        ACHIEVED_
      end
    end
  end
end
# wget -v --tries 2 --timeout 5 --dns-timeout 10 --directory-prefix
