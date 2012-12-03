module Skylab::TanMan

  class API::Actions::Use < API::Action
    extend API::Action::Parameter_Adapter

    param :path, pathname: true, accessor: true


  protected

    extname = '.dot'

    define_method :execute do
      result = nil
      begin
        config.ready? or break
        tries = [path]
        if '' == path.extname
          tries.push path.class.new( "#{path}#{extname}" )
        end
        idx = tries.length.times.detect do |x|
          tries[x].exist? && ! tries[x].directory?
        end
        if idx
          self[:path] = tries[idx]
          info "using #{ path }"
          result = true
        else
          self[:path] = tries.last
          if 1 < tries.length
            info "(adding #{extname} extension because that's what god wants)"
          end
          result = create_path
          result or break
        end
        config.set_value :file, path.expand_path.to_s, :local
        result = true
      end while nil
      result
    end

    # -- * --

    def create_path
      result = false
      begin
        if path.exist?
          if path.directory?
            error "cannot create, is directory: #{ path }"
          else
            error "cannot create, already exists: #{ path }"
          end
          break
        end
        template = service.examples.fetch 'digraph.dot'
        content = template.call created_on: ::Time.now.utc.to_s
        bytes = nil
        path.open('w+') { |fh| bytes = fh.write content }
        info "wrote #{ path } (#{ bytes } bytes)."
        result = bytes
      end while nil
      result
    end
  end
end
