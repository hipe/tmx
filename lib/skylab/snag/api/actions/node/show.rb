module Skylab::Snag
  class API::Actions::Node::Show < API::Action

    inflection.inflect.noun :plural

    attribute :identifier
    attribute :last

    emits :all,
      :error   => :all,
      :info    => :all,
      :payload => :all,
      :error_with_manifest_line => :error

  protected

    def execute
      res = nil
      begin
        break if ! nodes # we need them we want them, we want them now
        found = nodes.find identifier: identifier, last: last
        break( res = found ) if ! found
        yamlizer # kick
        res = paint found
      end while nil
      res
    end

    def paint items
      info "(looking at #{ escape_path manifest_pathname })"
      items.with_count!.each do |item|
        if item.valid?
          @yamlizer[ item ]
        else
          h = item.invalid_info
          emit :error_with_manifest_line, h
        end
      end
      ct = items.last_count
      case ct
      when 0
        emit :info, "found no nodes #{ items.search.adjp }"
      when 1
        # ok
      else
        emit :info, "found #{ ct } nodes #{ items.search.adjp }"
      end
      nil
    end

    fields = [ :identifier, :date, :message ]

    define_method :yamlizer do
      @yamlizer ||= begin
        ymlz = Snag::CLI::Yamlizer.new( fields ) do |o|
          o.on_line do |e|
            emit :payload, e
          end
        end
        ymlz
      end
    end
  end
end
