module Skylab::Snag
  module API::Actions::Nodes
    # gets sexed
  end

  class API::Actions::Nodes::Add < API::Action

    attribute :dry_run
    attribute :message,          :required => true
    attribute :verbose

    emits :all, :error => :all, :info => :all, :payload => :all

  protected

    def execute
      nodes.add message: message, dry_run: dry_run, verbose: verbose
    end
  end


  class API::Actions::Nodes::Reduce < API::Action

    inflection.inflect.noun :singular

    attribute :identifier
    attribute :last
    attribute :query_sexp

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
        sexp = query_sexp.dup if query_sexp
        (sexp ||= [:and]).push [:identifier, identifier] if identifier
        sexp ||= [:valid]
        found = nodes.find last, sexp
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
        emit :info, "found no nodes #{ items.search.phrasal_noun_modifier }"
      when 1
        # ok
      else
        emit :info, "found #{ ct } nodes #{ items.search.phrasal_noun_modifier}"
      end
      nil
    end

    field_names = Snag::Models::Node::Flyweight.field_names

    define_method :yamlizer do
      @yamlizer ||= begin
        ymlz = Snag::CLI::Yamlizer.new( field_names ) do |o|
          o.on_line do |e|
            emit :payload, e
          end
        end
        ymlz
      end
    end
  end
end
