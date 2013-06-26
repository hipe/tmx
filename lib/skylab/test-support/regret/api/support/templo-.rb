module Skylab::TestSupport::Regret::API

  class Support::Templo_

    # it's a goofy name but i wanted it to be short, unique and semantic.
    # a "templo" holds all the ugly, hard-to read, and one-offy logic we
    # need to write partly because our templates are truly logic-less and
    # partly because what we're doing is so cool we need ad-hoc classes for
    # it. Sure call it a view controller but eew.

    EXT = '.tmpl'

    class << self
      alias_method :begin, :new
      # for now. `begin` means "set these (positional) parameters",
      # and "i might want to do more stuff - i.e hold on to the templo"
    end

    def render_to x ; @render_to[ x ] ; end

  private

    def get_template i
      Face::Services::Basic::String::Template.from_string(
        self.class.dir_pathname.join( "#{ i }#{ EXT }" ).read
      )
    end

    def get_templates *a
      a.map { |i| get_template i }
    end

    fun = { }

    fun[ :descify ] = -> do
      rx = /:\z/
      -> str do
        no_colon = str.gsub rx, ''
        no_colon.inspect
      end
    end.call

    FUN = ::Struct.new( * fun.keys ).new( * fun.values )
  end
end
