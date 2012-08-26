module Skylab::TanMan
  class API::Actions::Use < API::Achtung::SubClient
    param :path, pathname: true, accessor: true
  protected
    EXTNAME = '.dot'
    def execute
      config.ready? or return
      tries = [path]
      if '' == path.extname
        tries.push path.class.new("#{path}#{EXTNAME}")
      end
      idx = tries.length.times.detect do |x|
        tries[x].exist? && ! tries[x].directory?
      end
      if idx
        @path = tries[idx]
        info "using #{path}"
      else
        @path = tries.last
        if 1 < tries.length
          info("(adding #{EXTNAME} extension because that's what god wants)")
        end
        create_path or return
      end
      config.set_value(:file, path.expand_path.to_s, :local) or return
    end
    # -- * --
    def create_path
      if path.exist?
        if path.directory?
          return error("cannot create, is directory: #{path}")
        else
          return error("cannot create, already exists: #{path}")
        end
      end
      bytes = nil
      path.open('w+') do |fh|
        bytes = fh.write('# created by herkemer on derkemer')
      end
      info("wrote #{path} (#{bytes} bytes).")
    end
  end
end
