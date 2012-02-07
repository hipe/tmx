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



    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    def numbers
      api.invoke [:issue, :number, :list], {}
    end


  protected

    def api
      @api and return @api
      handlers = @handlers or fail("fixme for ui handling")
      [:all] == (keys = (handlers.keys - [:default])) or fail("algo has changed for compat!")
      @api = Api.new do
        on_payload do |e|
          e.handled!
          handlers[:all].call(e)
        end
        on_error do |e|
          e.handled!.message = "failed to #{e.verb} #{e.noun} - #{e.message}"
          handlers[:all].call(e)
        end
        on_all do |e|
          unless e.handled?
            md = %r{\A\((.+)\)\z}.match(e.message) and e.message = md[1]
            e.message = "while #{e.verb.progressive} #{e.noun}, #{e.message}"
            md and e.message = "(#{e.message})" # so ridiculous
            handlers[:all].call(e)
          end
        end
      end
    end
  end
end

