module Skylab::Snag

  class CLI

    # notable things about it:
    #   + it itself is not a pub sub emitter - kiss
    #   + it's a franken-client of both legacy and headless,
    #       with latter trumping former. that it works is a testament to
    #       something, i'm not sure what
    #   + legacy DSL gets turned on below and that's when it hits the fan

    MetaHell::MAARS[ self ]
                                  # we autoload during load of this file

    include CLI::Action::InstanceMethods

    include Headless::CLI::Client::InstanceMethods

    def invoke argv               # modify at [#010]
      Headless::CLI::PathTools.clear # see
      res = super argv            # super handles argument errors etc.
      if false == res             # but if this, it is a petition for this:
        error "a low-ass-level error occured."
        res = nil
      end
      res
    end

  private                         # (DSL happens at bottom half)

    # `initialize` - we are straddling two f.w's: all we want is our (modality)
    # calls to to `emit` to "work". we follow the good standard of [#sl-114],
    # which among other things makes testing easier. Even though `legacy` gets
    # priority on the chain, it won't overwrite the (io adapter-based) `emit`
    # we get from h.l, which is good.

    def initialize up, pay, info  # (only strictifies the signature)
      super nil, nil, nil                      # lets legacy know we do it
      init_headless_cli_client up, pay, info   # i mean h.l does it
      nil
    end

    #         ~ event handling and emitting ~

    # emission of payload is straightforward. it is payload, we do not decorate
    # it. (#doc-point [#031] might have details on this)

    def handle_payload
      @handle_payload ||= -> txt do
        ::String === txt or fail "where? #{ txt.class }"  # #todo - remove
        payload txt
      end
    end

    def handle_raw_info
      @handle_raw_info ||= -> txt do
        ::String === txt or fail "wat #{ x.class }" # #todo -remove
        info txt
      end
    end

    render = -> me, e do
      if e.can_render_under
        e.render_under me
      else
        e.fetch_text
      end
    end

    split = -> do  # so ridiculous - "# (foo)" => [ "# (", "foo", ")" ]
      rx = /\A([( #]+)(.*[^)])(\))?\z/
      -> txt do
        if rx =~ txt
          $~.captures
        else
          [ nil, txt, nil ]
        end
      end
    end.call

    define_method :handle_info do
      @handle_info ||= -> e do  # assume API::Events::Lingual subproduct wide?
        txt = render[ self, e ]
        a, txt, z = split[ txt ]
        txt ="#{ a }while #{ e.verb_lexeme.progressive } #{ e.inflected_noun }#{
          }, #{ txt }#{ z }"
        info txt                               # (flatten the payload [#031])
      end
    end

    define_method :handle_error do
      @handle_error ||= -> e do
        txt = render[ self, e ]
        a, txt, z = split[ txt ]
        e.inflected_verb
        txt = "#{ a }failed to #{ e.inflected_verb } #{ e.inflected_noun } #{
          }- #{ txt }#{ z }"
        error txt                               # (it flattens it [#031])
      end
    end

    def issue_an_invitation_for norm_name_a
      as = CLI.fetch_action_sheetish norm_name_a
      issue_an_invitation_to_sheet as
      nil
    end

    def self.fetch_action_sheetish norm_name_a  #straddle
      # there is 1 level of legacy actions (which are now fine, it was cleaned)
      # but this nerk may be among the non-legacy too. hacklund
      if 1 == norm_name_a.length
        story.action_box[ norm_name_a[0] ]
      else
        a = norm_name_a.dup  # [ 'a', 'b' ] => [ 'a', :Actions, 'b'] ..
        full_a = a.reduce( [ a.shift ] ) { |m, x| m << :Actions ; m << x ; m }
        CLI::Actions.const_fetch full_a  # result in a class as a sheet!!
      end
    end

    def issue_an_invitation_to live_action  # assume everything
      issue_an_invitation_to_sheet live_action.class
    end

    def issue_an_invitation_to_sheet action_sheet
      parts = action_sheet.full_name_proc.map :as_slug
      parts.unshift program_name
      parts << '-h'
      emit :ui, "#{ kbd parts.join( ' ' ) } might have more information"
      nil  # SWALLOWED IT
    end

    #         ~ renderers not tied to any particular kind of event ~
    #         ~ (some for compat as a modality client for headless) ~
    #         ~ (alphabetical) ~

    define_method :escape_path, &Headless::CLI::PathTools::FUN.pretty_path

    def val x                     # how do you decorate a special value?
      em x
    end

    def render_param param        # `param` is a wrapper object
      if param.is_option
        param.as_parameter_signifier
      elsif param.is_argument
        "<#{ param.slug }>"
      end
    end

    #         ~ a fresh take on [#hl-036] `param` ~

    def param norm_name
      @legacy_last_hot.fetch_param norm_name
    end

    #         ~ api nerks ~

    def api
      @api ||= Snag::API::Client.new self
    end

    # --*--

    extend Porcelain::Legacy::DSL              # now entering DSL zone

    namespace :node, -> { CLI::Actions::Node }

    namespace :nodes, -> { CLI::Actions::Nodes }

    # --*--

    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    def numbers
      api_invoke [ :nodes, :numbers, :list ], nil, -> a do
        a.on_error handle_error
        a.on_info handle_info
        a.on_output_line handle_payload
      end
    end

    # --*--

    desc "when no arguments provided, list open issues"
    desc "when one argument provided, is used as first line of new issue"
    desc "that will be tagged #open"

    option_parser do |o|
      param_h = @param_h

      o.on '-n', '--max-count <num>',
        "limit output to N nodes (list only)" do |n|
        @param_h[:max_count] = n
      end

      o.regexp_replace_tokens %r{\A-(?<num>\d+)\z} do |md|  # [#030]
        [ '--max-count', md[:num] ]
      end

      o.on '--dry-run', "don't actually add the node (add only)" do
        param_h[:dry_run] = true
      end

      o.on '-v', '--verbose', 'verbose output' do
        param_h[:be_verbose] = true
      end
    end

    option_parser_class CLI::Option::Parser

    argument_syntax '[<message>]'

    def open message=nil, param_h
      # ( see description above - for fun we do a tricky dynamic syntax )
      pbox = MetaHell::Formal::Box::Open.from_hash param_h ; param_h = nil
      msg = -> is_opening do                   # i hope you enjoyed this
        a_b = [ 'opening issues', 'listing open issues' ]
        a_b.reverse! if is_opening
        a = pbox.names.map { |n| em render_param( param n ) }
        "sorry - #{ and_ a } #{ s :is } used for #{ a_b.first}, not #{a_b.last}"
      end
      if message
        p = pbox.partition_where_name_in! :dry_run, :be_verbose  # p has the <= 2 eles
        if pbox.length.nonzero? then res = error msg[ true ] else
          res = api_invoke [ :nodes, :add ],
            p.to_hash.merge!(
              do_prepend_open_tag: true,
                          message: message
            ), -> a do
              a.on_error handle_error
              a.on_info handle_info
              a.on_raw_info handle_raw_info
              a.on_new_node { |_| } # handled by manifest for now
            end
        end
      else
        p = pbox.partition_where_name_in! :max_count, :be_verbose
        if pbox.length.nonzero? then res = error msg[ false ] else
          p.add( :be_verbose, false ) if ! p.has? :be_verbose # decide dflt here
          p.add :query_sexp, [ :and, [ :has_tag, :open ] ]
          res = api_invoke [ :nodes, :reduce ], p.to_hash, -> a do
            a.on_output_line handle_payload
            a.on_info handle_info
            a.on_error handle_error
            a.on_invalid_node { |e| info invalid_node_message( e ) }
          end
        end
      end
      if false == res
        res = issue_an_invitation_for [ :open ]
      end
      res
    end

    # --*--

    namespace :todo, -> { CLI::Actions::Todo }

    # --*--

    desc "pings snag (lowlevel)."   # #todo you know you want to

    def ping
      @io_adapter.errstream.puts "hello from snag."
      :hello_from_snag
    end

    Client = self  # #tmx-compat
  end

  module CLI::Actions             # avoiding an #orphan sorry
    MetaHell::Boxxy[ self ]        # (it's as if we are wiring an autoloader)
  end                             # also BOXXY IS QUEEN
end
