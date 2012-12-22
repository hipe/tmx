module Skylab::TanMan
  module API::Actions::Graph::Meaning
    # this will get sexed by the autoloader
  end



  class API::Actions::Graph::Meaning::Forget < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :force, :name, :verbose ]

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.selected or break
        write = nil
        res = cnt.unset_meaning name, true, dry_run, verbose,
          -> e do
            error e
            false
          end,
          -> success do
            info success
            write = true
            true
          end
        if write
          res = cnt.write dry_run, force, verbose
        end
      end while nil
      res
    end
  end



  class API::Actions::Graph::Meaning::Learn < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :create, :dry_run, :name, :value, :verbose ]

  protected

    def execute
      res = nil
      begin
        write = false
        cnt = collections.dot_file.selected or break
        res = cnt.set_meaning name, value, create, dry_run, verbose,
          -> e do
            error e
            false
          end,
          -> success do
            info success
            write = true
            true
          end,
          -> neutral do
            info neutral
            nil
          end
        if write
          res = cnt.write dry_run, false, verbose # never force for now
        end
      end while nil
      res
    end
  end



  class API::Actions::Graph::Meaning::List < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [:verbose]

    define_method :execute do
      res = nil
      begin
        cnt = collections.dot_file.selected or break
        count = 0
        cnt.meanings.each do |meaning|
          count += 1
                                  # b/c we have colors we can't use string
          ind = ' ' * [ (20 - meaning.name.length), 1 ].max # format codes
                                  # later we can stratify where this happens
          payload "#{ ind }#{ lbl meaning.name } : #{ val meaning.value }"

        end
        if 0 == count
          info "there is no meaning in #{ escape_path cnt.pathname }"
        else
          info "(found #{ count } total in #{ escape_path cnt.pathname })"
        end
        res = true
      end while nil
      res
    end
  end
end
