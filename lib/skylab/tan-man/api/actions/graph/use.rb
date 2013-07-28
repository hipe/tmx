module Skylab::TanMan
  class API::Actions::Graph::Use < API::Action
    extend API::Action::Parameter_Adapter

    param :path, pathname: true, accessor: true, required: true

    attr_reader :verbose # compat

  private

    extname = '.dot'

    define_method :execute do
      result = nil
      begin
        controllers.config.ready? or break
        tries = [path]
        if '' == path.extname
          tries.push path.class.new( "#{ path }#{ extname }" )
        end
        idx = tries.length.times.detect do |x|
          tries[x].exist? && ! tries[x].directory?
        end
        if idx
          self[:path] = tries[idx]
          info "using #{ escape_path path }"
          result = true
        else
          self[:path] = tries.last
          if 1 < tries.length
            info "(adding #{ extname } extension because that's what god wants)"
          end
          result = create_path
          result or break
        end
        relpath = services.config.local.relativize_pathname path
        controllers.config.set_value Models::DotFile::Collection::CONFIG_PARAM,
                                       relpath.to_s, :local
        result = true
      end while nil
      result
    end

    # -- * --

    def create_path
      result = false
      begin
        if path.exist? # #pattern [#049]
          if path.directory?
            error "cannot create, is directory: #{ path }"
          else
            error "cannot create, already exists: #{ path }"
          end
          break
        elsif path.dirname.exist?
          if ! path.dirname.directory?
            error "cannot create, is not directory: #{ path.dirname }"
            break
          end
        else
          error "cannot create, directory does not exist: #{ path.dirname }"
          break
        end
        starter = collections.starter.using_starter or break # emits
        t = " using starter #{ starter.pathname.basename }"
        content = starter.call created_on: ::Time.now.utc.to_s
        bytes = nil
        path.open( WRITEMODE_ ) { |fh| bytes = fh.write content }
        info "wrote #{ path }#{ t } (#{ bytes } bytes)."
        result = bytes
      end while nil
      result
    end
  end
end
