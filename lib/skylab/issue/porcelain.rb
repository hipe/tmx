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
      on('-n', '--dry-run', "don't actually do it") { ctx[:dry_run] = true }
    end

    def add message, ctx
      ctx[:message] = message
      api.invoke [:issue, :add], ctx
    end


    desc "show the details of issue(s)"

    option_syntax do |ctx|
      on('-l', '--last <num>', '--limit <num>',
         "shows the last N issues") { |n| ctx[:last] = n }
    end

    argument_syntax '[<identifier>]'

    def show identifier=nil, ctx
      ctx[:identifier] = identifier
      api.invoke [:issue, :show], ctx
    end




    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    def numbers
      api.invoke [:issue, :number, :list], {}
    end

  protected

    # this nonsense wires your custom root client to the big deal parent
    def wire! runtime, parent
      runtime.on_error { |e| parent.emit(:error, e.touch!) }
      runtime.on_info  { |e| parent.emit(:info, e.touch!) }
      runtime.on_all   { |e| parent.emit(e.type, e) unless e.touched? }
    end

    def api
      # this BS wires your action instances to your custom centralzied
      @api ||= Api.new do |action|
        action.on_payload { |e| runtime.emit(:payload, e) }
        action.on_error do |e|
          e.message = "failed to #{e.verb} #{e.noun} - #{e.message}"
          runtime.emit(:error, e)
        end
        action.on_info do |e|
          unless e.touched?
            md = %r{\A\((.+)\)\z}.match(e.message) and e.message = md[1]
            e.message = "while #{e.verb.progressive} #{e.noun}, #{e.message}"
            md and e.message = "(#{e.message})" # so ridiculous
            runtime.emit(:info, e)
          end
        end
      end
    end
  end
end

