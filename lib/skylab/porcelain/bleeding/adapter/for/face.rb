module Skylab::Porcelain::Bleeding

  module Adapter::For::Face
    module Of
      # you are now in "ouroboros" (see #doc-point [#hl-069])
    end
  end

  class Adapter::For::Face::Of::Hot < ::Skylab::Porcelain::Legacy::
        Adapter::For::Face::Of::Hot

    respond_to_h = { invokee: true }

    define_singleton_method :[] do |my_cli_class, hi_sheet|
      -> hi_svcs, _slug_used=nil do
        real = -> do
          a = hi_svcs.get_normal_invocation_string_parts
          a << hi_sheet.name.as_slug
          ioe = hi_svcs[ :istream, :ostream, :estream ]
          rl = my_cli_class.new( * ioe )
          rl.program_name = a * ' '
          real = -> { rl }
          rl
        end
        new(
          name: -> { hi_sheet.name },
          summary: -> *_ { real[].summary_lines },
          help: -> { real[].help full: true },
          respond_to?: -> i { respond_to_h.fetch i },
          invokee: -> { real[] },
          pre_execute: -> { } )
      end
    end
  end
end
