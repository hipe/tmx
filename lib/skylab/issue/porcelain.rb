require File.expand_path('../api', __FILE__)

module Skylab::Issue

  class Porcelain
    extend ::Skylab::Porcelain

    desc "Add an \"issue\" line to #{ISSUES_FILE_NAME}."
    desc "Lines are added to the top and are sequentially numbered."

    desc ' arguments:' #                      DESC

    argument_syntax '<message>'
    desc '   <message>                        a one line description of the issue'

    option_syntax do |ctx|
      on('-n', '--dry-run', "don't actually do it")
    end

    def add message, ctx
      ctx[:message] = message
      api.invoke [:issue, :add], ctx
    end

  protected

    def api
      @api and return @api
      handlers = @handlers or fail("fixme for ui handling")
      [:all] == (keys = (handlers.keys - [:default])) or fail("algo has changed for compat!")
      @api = Api.new do
        on_error do |e|
          e.handled!
          e.message = "failed to #{e.verb} #{e.noun} - #{e.message}"
          handlers[:all].call(e)
        end
        on_all do |e|
          unless e.handled?
            e.message = "#{e.verb} #{e.noun} - #{e.message}"
            handlers[:all].call(e)
          end
        end
      end
    end
  end
end

