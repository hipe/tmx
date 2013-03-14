module Skylab::Porcelain::Legacy

  module Adapter::For::Face
    module Of
      # ( see `ouroboros` ([#hl-069]) )
    end
  end

  Adapter::For::Face::Of::Hot = MetaHell::Proxy::Nice.new :slug, :summary,
    :respond_to?, :invokee, :help

  class Adapter::For::Face::Of::Hot

    respond_to_h = { invokee: true }

    define_singleton_method :[] do |my_mc_class|

      -> my_sheet, rc, rc_sheet, _ do

        real = -> do
          my_mc_class.new( rc.in, rc.out, rc.err ).instance_exec do
            self.program_name =
              "#{ rc.invocation_string } #{ my_sheet.name.as_slug }"
            real = -> { self }
            self
          end
        end
        new(
          slug: -> { my_sheet.slug },
          summary: -> do
            [ "usage: #{ real[].syntax_text }" ]
          end,
          respond_to?: -> x do
            respond_to_h.fetch x
          end,
          invokee: -> do
            real[]
          end,
          help: -> do
            real[].help
          end
        )
      end
    end
  end
end
