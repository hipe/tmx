module Skylab::TanMan
  class Models::DotFile::Collection < ::Struct.new :using_pathname
    include Core::SubClient::InstanceMethods

    CONFIG_PARAM = 'using_dotfile'

    def currently_using
      res = nil
      begin
        if @currently_using                    # there is danger here in ..
          break( res = @currently_using )      # the distant future
        end
        break if ! ready? # emits info
        if ! using_pathname
          info "no using_pathname!" # strange
          break
        end
        # (at the time of this writing the controllers.dot_file seems to
        # be a sort of singleton, which might be dodgy. we want a controller
        # object that exists sort of one-to-one with a pathname.)
        cnt = Models::DotFile::Controller.new request_client # (up not me)
        cnt.pathname = using_pathname
        cnt.verbose = verbose # inherit this puppy
        res = @currently_using = cnt
      end while nil
      res
    end

    config_param = CONFIG_PARAM

    define_method :ready? do |bad_conf=nil, no_param=nil, no_file=nil|
      res = false
      begin
        if ! using_pathname
          o = controllers.config
          if ! o.ready?( bad_conf )
            break
          end
          if ! o.known? config_param
            if no_param then no_param[ config_param ] else
              error "no '#{ config_param }' value is set in config(s)" # no inv.
            end
            break
          end
          relpath = o[ config_param ] or fail 'sanity'
          self.using_pathname = services.config.local.derelativize_path relpath
        end
        if using_pathname.exist?
          res = true
        else
          if no_file then no_file[ using_pathname ] else
            error "dotfile must exist: #{ escape_path using_pathname }"
          end
        end
      end while nil
      res
    end

    attr_accessor :verbose # compat

  protected

    def initialize request_client
      super
      @currently_using = nil
    end
  end
end
