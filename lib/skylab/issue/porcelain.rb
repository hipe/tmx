require_relative 'api'

module Skylab::Issue

  class Porcelain
    extend ::Skylab::Porcelain
    extend ::Skylab::Autoloader

    desc "Add an \"issue\" line to #{ISSUES_FILE_NAME}."
    desc "Lines are added to the top and are sequentially numbered."

    desc ' arguments:' #                      DESC

    argument_syntax '<message>'
    desc '   <message>                        a one line description of the issue'

    option_syntax do |ctx|
      on('-n', '--dry-run', "don't actually do it") { ctx[:dry_run] = true }
    end

    def add message, ctx
      api.action(:issue, :add).wire!(&wire).invoke(ctx.merge( message: message ))
    end


    desc "show the details of issue(s)"

    action.alias 'list'

    option_syntax do |ctx|
      on('-l', '--last <num>', '--limit <num>',
         "shows the last N issues") { |n| ctx[:last] = n }
    end

    argument_syntax '[<identifier>]'

    def show identifier=nil, ctx
      ctx[:identifier] = identifier
      api.invoke(self, [:issue, :show], ctx) do |action|
        action.default_wiring!
        runtime = action.client.runtime
        action.on_error_with_manifest_line do |e|
          runtime.emit(:info, '---')
          runtime.emit(:error, "error on line #{e.line_number}-->#{e.line}<--")
           e.message = "failed to parse line #{e.line_number} because " <<
                "#{e.invalid_reason.to_s.gsub('_', ' ')} " <<
                "(in #{e.pathname.basename})" # this gets decorated haha
          # @todo: for:#102.901.3.2.2 : wiring should happen between
          # the events that an api-level action emits and the events
          # of the parent client of the action invocation, or something
          # all.rb does this confusing thing by having non-configurable core clients
         end
       end
    end


    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    def numbers
      api.invoke self, [:issue, :number, :list], {}
    end

  protected

    # this nonsense wires your evil foreign (frame) runtime to the big deal parent
    def wire! runtime, parent
      runtime.event_class = Api::MyEvent
      runtime.on_error { |e| parent.emit(:error, e.touch!) }
      runtime.on_info  { |e| parent.emit(:info, e.touch!) }
      runtime.on_all   { |e| parent.emit(e.type, e) unless e.touched? }
    end

    def api
      @api ||= Api.new
    end

    def wire action=nil
      action or return ->(a) { wire(a) }

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

