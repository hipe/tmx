module Skylab::Slicer

  class CLI::Client < Slicer_.lib_.CLI_client

    def initialize( * )
      super
      @param_h = { }
    end

    use :hi, :last_hot

    set :node, :ping, :invisible

    def ping
      @y << "hello from slicer."
      :hello_from_slicer
    end

    option_parser do |o|
      o.separator "#{ hi 'description:' } just raw-ass file copy to the slice!"
      o.separator "#{ hi 'options:' }"
      dry_run_option o

      o.banner = last_hot.usage_line
    end

    aliases :xfer

    def transfer
      api
    end

  dsl_off
  private

    def dry_run_option o
      @param_h[ :dry_run ] = false
      o.on '-n', '--dry-run', 'dry run.' do
        @param_h[ :dry_run ] = true
      end
    end

    def on_info_line e
      @y << e.payload_a.fetch( 0 )
      nil
    end

    def on_info_message e
      @y << "#{ @mechanics.last_hot_nis }: #{ e.payload_a.fetch 0 }"
      nil
    end
  end
end
