module Skylab::Porcelain::Legacy

  module Adapter::For::Face
    module Of
      # ( see `ouroboros` ([#hl-069]) )
    end
  end

  Adapter::For::Face::Of::Hot = MetaHell::Proxy::Nice.new(
    :name, :summary, :help, # for doc index
    :respond_to?, :invokee, :pre_execute  # for `get_executable` and `invoke`
  )

  class Adapter::For::Face::Of::Hot

    define_singleton_method :[] do |my_cli_class, hi_sheet|
      -> hi_svcs, _slug_used=nil do
        real = -> do
          ioe = hi_svcs[ :istream, :ostream, :estream ]
          a = hi_svcs.get_normal_invocation_string_parts
          a << hi_sheet.name.as_slug
          my_cli_class.new( * ioe ).instance_exec do
            self.program_name = a * ' '
            real = -> { self }
            self
          end
        end
        send_h = { invokee: true }
        _send_h = { invoke: true }
        new(
          name: -> { hi_sheet.name },
          summary: -> { [ "usage: #{ real[].syntax_text }" ] },
          help: -> { real[].help },
          respond_to?: -> i { send_h.fetch i },
          invokee: -> { real[] },
          pre_execute: -> { } )
      end
    end
  end
end
