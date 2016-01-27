module Ore
  module Template
    module Helpers
      #
      # @api semipublic
      #
      # @since 0.10.0
      #
      module Textile
        #
        # Emits a Textile link.
        #
        # @param [String, nil] text
        #
        # @param [String] url
        #
        # @return [String]
        #
        def link_to(text,url)
          if text
            "#{text.dump}:#{url}"
          else
            url
          end
        end

        #
        # Emits a Textile image tag.
        #
        # @param [String] url
        #
        # @param [String, nil] alt
        #
        # @return [String]
        #
        def image(url,alt=nil)
          if alt then "!#{url}(#{alt})!"
          else        "!#{url}!"
          end
        end

        #
        # Emits a Textile h1 heading.
        #
        # @param [String] title
        #
        # @return [String]
        #
        def h1(title)
          "h1. #{title}"
        end

        #
        # Emits a Textile h2 heading.
        #
        # @param [String] title
        #
        # @return [String]
        #
        def h2(title)
          "h2. #{title}"
        end

        #
        # Emits a Textile h3 heading.
        #
        # @param [String] title
        #
        # @return [String]
        #
        def h3(title)
          "h3. #{title}"
        end

        #
        # Emits a Textile h4 heading.
        #
        # @param [String] title
        #
        # @return [String]
        #
        def h4(title)
          "h4. #{title}"
        end

        #
        # Emits a Textile code block.
        #
        # @param [String] code
        #
        # @yield []
        #   The return value of the given block will be used as the code.
        #
        # @return [String]
        #
        def pre(code)
          if code =~ /#{$/}\s*#{$/}/
            "bc.. #{code}"
          else
            "bc. #{code}"
          end
        end
      end
    end
  end
end
