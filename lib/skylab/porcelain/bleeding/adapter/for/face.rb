module Skylab::Porcelain::Bleeding

  module Adapter::For::Face
    module Of
      # you are now in "ouroboros" (see #doc-point [#hl-069])
    end
  end

  Adapter::For::Face::Of::Hot = MetaHell::Proxy::Nice.new :slug, :summary,
    :respond_to?, :invokee, :help

  class Adapter::For::Face::Of::Hot

    respond_to_h = { invokee: true }

    define_singleton_method :[] do |my_mc_class|  # my client class

      -> my_sheet, rc, rc_sheet, slug_fragment do

        real = -> do
          rl = my_mc_class.new rc.in, rc.out, rc.err
          rl.program_name =
            "#{ rc.invocation_string } #{ my_sheet.name.as_slug }"
          rl
        end

        new(
          slug: -> do
            my_sheet.name.as_slug
          end,
          summary: -> do
            real[].summary_lines
          end,
          respond_to?: -> x do
            respond_to_h.fetch x
          end,
          invokee: -> do
            real[]
          end,
          help: -> do
            real[].help full: true
          end
        )
      end
    end
  end
end
