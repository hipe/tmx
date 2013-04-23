module Skylab::CodeMolester

  module Config::File::API_Client

    # extend an API client with services related to file-based config

    def self.enhance host, & def_blk

      host.class_exec do

        define_api_client do
          services %i|
            config_file_search_start_pathname
            config_file_search_num_dirs
            config_filename
            configs
            config
          |
        end

        # `configs` / `config` - readability enhancement

        def configs
          model :configs
        end

        def config
          model :config
        end
      end

      story = Story_.new host

      Conduit_.new(
        ->( *a, &b ) do
          story.set :config_file_search_start_pathname, a, b
        end,
        ->( *a, &b ) do
          story.set :config_file_search_num_dirs, a, b
        end,
        ->( *a, &b ) do
          story.set :config_filename, a, b
        end
      ).instance_exec( & def_blk )

      nil
    end

    Conduit_ = MetaHell::Enhance::Conduit.new %i|
      search_start_pathname
      search_num_dirs
      config_filename
    |

    class Story_

      def initialize host_mod
        set = nil
        x_h = { } ; f_h = { }
        host_mod.module_exec do
          set_with_arg = set_with_block = nil
          set = -> i, a, b do
            if a.length.zero?
              if b
                f_h[ i ] = b
                set_with_block[ i, b ]
              elsif x_h.key? i
                x_h.fetch i
              elsif f_h.key? i
                f_h.fetch( i ).call
              else
                raise ::ArgumentError, "expecting arg or block (and #{
                  }#{ i } was not yet defined)."
              end
            elsif b
              raise ::ArgumentError, "can't have args and block"
            elsif 1 == a.length
              set_with_arg[ i, a.fetch( 0 ) ]
            else  # this introduces the DSL problem (fixed elsewhere)
              set_with_arg[ i, a ]
            end
          end
          set_with_arg = -> i, x do
            set_with_block[ i, -> { x } ]
          end
          set_with_block = -> i, f do
            define_method i, &f
          end
        end
        @set = set
      end

      def set i, a, b
        @set.call i, a, b
      end
    end
  end
end
