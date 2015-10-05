module Skylab::GitViz::Tasks

  class Build_RBX

    class Resolve_action__

      def initialize y, installed, cloud
        @y = y
        @version_is_installed, @installed_ruby = installed.to_a
        @did_change = cloud.did_change
        if @did_change
          @cloud_version = cloud.version ; @url = cloud.url
        else
          @cloud_version = ::Gem::Version.new MOST_RECENT_KNOWN_RBX_VERSION_S_
          a, b = URL_HEAD_AND_TAIL_
          @url = "#{ a }#{ @cloud_version }#{ b }"
        end
      end

      def execute
        @did_change && hack_edit_file
        if @version_is_installed
          when_some_version_is_already_installed
        else
          when_no_version_is_installed_at_all
        end
      end

      def when_no_version_is_installed_at_all
        @y << say_no_version_is_installed
        procede
      end

      def say_no_version_is_installed
        "it appears that no version of rbx is currently installed"
      end

      def when_some_version_is_already_installed
        case @installed_ruby.version <=> @cloud_version
        when -1 ; when_upgrade
        when  0 ; when_same
        when  1 ; when_you_are_brian_shirai
        end
      end

      def when_you_are_brian_shirai
        @y << "ok bro, the highest version in your rbenv is #{
          }#{ @installed_ruby }, which is higher"
        @y << "than the highest known stable-esque version in The Cloud #{
          }(#{ @cloud_version }). neato, can i see!?"
        ACHIEVED_
      end

      def when_same
        @y << "#{ @installed_ruby.to_s } is in your rbenv and is #{
          }most recent according to The Cloud."
        ACHIEVED_
      end

      def when_upgrade
        @y << "YAY - you could upgrade from #{ @installed_ruby } #{
          }to #{ @cloud_version  }"
        Build_RBX::Install__.new( @y,  @url, @cloud_version ).execute
      end

      def hack_edit_file
        _file = Build_RBX.to_path
        _const = 'MOST_RECENT_KNOWN_RBX_VERSION_S_'
        @y << `#{ ::File.dirname __FILE__ }/persist-new-constant-value #{
          }#{ _file } #{ _const } #{ @cloud_version }` ; nil
      end
    end
  end
end
