require_relative 'api'

# @todo: add a feature that is a report of the todos

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
      # @todo we would love to have -1, -2 etc
      on('-l', '--last <num>', '--limit <num>',
         "shows the last N issues") { |n| ctx[:last] = n }
    end

    argument_syntax '[<identifier>]'

    def show identifier=nil, ctx
      action = api.action(:issue, :show).wire!(&wire)
      client = runtime # this is a part we don't like
      # @todo: for:#102.901.3.2.2 : wiring should happen between
      # the api action objects and the "client" (interface) instance that
      # invoked the api action.
      # all.rb does this confusing thing by having non-configurable core clients
      action.on_error_with_manifest_line do |e|
        client.emit(:info, '---')
        client.emit(:error, "error on line #{e.line_number}-->#{e.line}<--")
        e.message = "failed to parse line #{e.line_number} because " <<
            "#{e.invalid_reason.to_s.gsub('_', ' ')} " <<
            "(in #{e.pathname.basename})" # this gets decorated haha
      end
      action.invoke({ identifier: identifier }.merge!(ctx))
    end


    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    # @todo: bug with "tmx issue number -h"
    def numbers
      api.action(:issue, :number, :list).wire!(&wire).invoke
    end


    desc "a report of the @todo's in a codebase"

    option_syntax do |o|
      d = Api::Todo::Report.attributes.with(:default)

      on('--pattern <PATTERN>',
        "the todo pattern to use (default: '#{d[:pattern]}')"
        ) { |p| o[:pattern] = p }
      on('--name <NAME>',
        "the filename patterns to search, can be specified",
        "multiple times to broaden the search (default: '#{d[:names] * "', '"}')"
        ) { |n| (o[:names] ||= []).push n }
    end

    argument_syntax '<path> [<path> [..]]'

    # @todo we wanted to call this todo_report but there was that one bug
    def todo *paths, opts       # args interface will change
      api.action(:todo, :report).wire!(&wire).invoke(opts.merge(paths: paths))
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

    def wire
      @wire ||= ->(action) { wire_action(action) }
    end

    def wire_action action
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

