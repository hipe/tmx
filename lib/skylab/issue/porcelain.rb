require File.expand_path('../api', __FILE__)

module Skylab::Issue

  class Porcelain
    extend ::Skylab::Porcelain

    desc "Add an \"issue\" line to #{ISSUES_FILE}."
    desc "Lines are added to the top and are sequentially numbered."

    desc ' arguments:' #                      DESC

    argument_syntax '<message>'
    desc '   <message>                        a one line description of the issue'

    option_syntax do |ctx|
      ctx[:issues_file] = ISSUES_FILE
      on('-n', '--dry-run', "don't actually do it")
    end

    def add message, ctx
      ctx[:message] = message
      api.invoke :add, ctx
    end

  private
    def api
      @api ||= begin
        _awful = @handlers or fail("fixme for ui handling")
        Api.new do
          (_awful.keys - [:default]).each do |event_type|
            send("on_#{event_type}", & _awful[event_type])
          end
        end
      end
    end
  end
end

