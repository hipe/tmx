module Skylab::Slicer

  class CLI::Client < Face::CLI

    option_parser do |o|
      o.separator "#{ hi 'description:' } just raw-ass file copy to the slice!"
      o.separator "#{ hi 'options:' }"
      dry_run_option o

      o.banner = @command.usage_line
    end

    aliases :xfer

    def transfer
      api
    end

  private

    def initialize( * )
      super
      @param_h = { }
    end

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
