module Skylab::TMX

  class Magnetics_::ManifestStream_via_Installation  # 1x

    def self.[] o
      self._NOT_USED__open_015_on_stack__  # #open [#015] on stack
      new( o ).execute
    end

    # -

      def initialize inst

        @const_head_path = inst.participating_gem_const_head_path
        @exe_pfx = inst.participating_exe_prefix
        @gems_dir = inst.single_gems_dir
        @gem_pass_prefix = inst.participating_gem_prefix
      end

      def execute

        # first, find every known exe (~40) thru one filesystem glob call.

        exe_st = Stream_.call(
          ::Dir[ "#{ @gems_dir }/#{ @gem_pass_prefix }*/bin/#{ @exe_pfx }*" ] )

        sep = ::Regexp.escape ::File::SEPARATOR
        _rxs = Home_::Models_::GemNameElements::Tools[].
          regexp_source_for_installed_gem_filesystem_entry_extended

        rx = /\A
          (?<gem_path> .+ #{ sep } (?<entry> #{ _rxs } ) )
          #{ sep } bin #{ sep }
          (?<exe_entry>#{ @exe_pfx }.+)
        \z/x

        md = nil
        prev_md = nil

        match_3 = -> exe_path do

          prev_md = md
          md = rx.match exe_path
          [ md[ :gem_name ], md[ :version ], md[ :exe_entry ] ]
        end

        category_gemname = nil
        category_version = nil
        items = nil

        stem_via_range = @gem_pass_prefix.length .. -1

        proto = Models_::GemNameElements.define do |gne|
          gne.const_head_path = @const_head_path
          gne.exe_prefix = @exe_pfx
        end

        flush = -> do

          gem_name = prev_md[ :gem_name ]

          gne = proto.dup
          gne.entry_string = gem_name[ stem_via_range ]
          gne.gem_name = gem_name
          gne.gem_path = prev_md[ :gem_path ]

          Models_::Node::Manifest.new(
            items, Models_::LoadableReference.new( gne ) )
        end

        body_p = nil
        p = -> do

          # then, group the exe's by sidesystem. we need to chunk them in this
          # manner because we expose the sidesystem differently based on whether
          # or not it has an eponymous exe ("tmx-flex2treetop", for eg.), and
          # and we won't know whether it does or not unless we look at all of
          # them (per sidesystem).

          exe_path = exe_st.gets
          if exe_path

            category_gemname, category_version, item = match_3[ exe_path ]
            items = [ item ]
            p = body_p
            body_p[]
          else
            self._COVER_ME_just_nothing
          end
        end

        body_p = -> do

          # assume there is a category and one or more items

          begin
            exe_path = exe_st.gets
            if exe_path
              gemname, version, item = match_3[ exe_path ]
              if category_gemname == gemname
                # "normal"

                if category_version != version
                  self._IMPLEMENT_ME
                end

                items.push item
                redo
              end
              # flush point
              result = flush[]
              category_gemname = gemname
              category_version = version
              items = [ item ]
              break
            end
            # end of stream
            result = flush[]
            p = EMPTY_P_
          end while nil
          result
        end

        Common_.stream do
          p[]
        end
      end
    # -
  end
end
