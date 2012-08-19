module Skylab::TanMan
  class API::Actions::Use < API::Achtung
    param :path, pathname: true, accessor: true
  protected
    EXTNAME = '.dot'
    def execute
      config.ready? or return
      tries = [path]
      if '' == path.extname
        tries.push path.class.new("#{path}#{EXTNAME}")
      end
      if idx = tries.length.times.detect { |x| tries[x].exist? }
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
      if '' == path.extname
        @path = path.class.new("#{path}.dot")
      end
      bytes = nil
      path.open('w+') do |fh|
        bytes = fh.write('# created by herkemer on derkemer')
      end
      info("wrote #{path} (#{bytes} bytes).")
    end
  end
end
