module Skylab::CodeMolester

  class Config::Service

    # extend any class with services related to file-based config

    CM_.lib_.field_reflection self

    # ~ section 1 - the actual enhancing of your nerklette

    DSL = LIB_.constant_trouble.
      # we run this DSL thru the user and then we have the application's
      # field values stored in the below constants of its `Service` subclass
      # (called `Config_` and stored in the enhanced class itself.)
      new :Config_, self,
        [ :through_method,
          :in_ivar,
          :search_start_path,
          :default_init_directory,
          :search_num_dirs,
          :filename
        ]  # (what this does is amazing)


    THROUGH_METHOD_VALUE_ = 'config'

    IN_IVAR_VALUE_ = nil

    SEARCH_START_PATH_PROC_ = -> { ::Dir.pwd }

    DEFAULT_INIT_DIRECTORY_PROC_ = -> { ::Dir.pwd }

    SEARCH_NUM_DIRS_VALUE_ = 3

    FILENAME_VALUE_ = 'config'

    def self.enhance host, &blk
      _enhance host, true, blk
    end

    def self.imbue host, &blk
      _enhance host, false, blk
    end

    def self._enhance host, publc, blk
      DSL.enhance host, blk
      c = host::Config_
      m = c::THROUGH_METHOD_VALUE_
      ivar = c::IN_IVAR_VALUE_ || :"@#{ m }"
      host.method_defined?( m ) || host.private_method_defined?( m ) and
        raise "won't clobber existing method - #{ m } of #{ host } #{
          }(pick a different name with `through_method`?"
      host.send :define_method, m do
        instance_variable_defined?( ivar ) ?
          instance_variable_get( ivar ) :
          instance_variable_set( ivar, self.class::Config_.new )
      end
      publc or host.send :private, m
      nil
    end


    # ~ section 3 - public singleton methods ~

    # implement our meta-API compatible with [#ba-020]

    def self.dsl_fields
      self::DSL::FIELD_A_
    end

    # ~ section 4 - let it act like a mini `API services node` ~

    def [] i
      respond_to?( i ) or raise "`#{ i }` is not part of the public API#{
        }of #{ self.class }"
      send i
    end

    # ~ section 5 - some business additional to the DSL declaration above ~

    derived_fields do
      def get_search_start_pathname
        if (( p = search_start_path ))
          ::Pathname.new p
        end
      end
    end
  end
end
