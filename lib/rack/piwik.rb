module Rack #:nodoc:
  class Piwik < Struct.new :app, :options
    def initialize(*args)
      super(*args)
      @custom_vars = setup_custom_vars
    end

    def call(env)
      status, headers, response = app.call(env)

      if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
        body = ""
        response.each { |part| body << part }
        index = body.rindex("</body>")
        if index
          body.insert(index, tracking_code(options[:piwik_url]))
          headers["Content-Length"] = body.length.to_s
          response = [body]
        end
      end

      [status, headers, response]
    end

    protected
      def setup_custom_vars
        git_dir = nil
        project_dir = nil
        dir = Dir.pwd
        last_dir = nil
        while dir != last_dir
          git_dir = ::File.join(dir, '.git')
          break if Dir.exists?(git_dir)

          last_dir = dir
          dir, project_dir = ::File.split(dir) # go up one level
          git_dir = nil
        end

        git_origin_url = nil
        if git_dir
          config = ::File.join(git_dir, 'config')
          found_origin = false
          ::File.open(config).each_line do |line|
            line.rstrip!
            if line == '[remote "origin"]'
              found_origin = true
              git_origin_url = "HERE"
            elsif found_origin && match = line.match(/^\s*url = (.*)$/)
              git_origin_url = match[1]
            end
          end
        end

        { git_origin_url: git_origin_url, project_dir: project_dir }
      end

      # Returns JS to be embeded. This takes one argument, a Web Property ID
      # (aka UA number).
      def tracking_code(piwik_url)
        set_custom_vars = ''
        @custom_vars.keys.each_with_index do |key, index|
          value = @custom_vars[key]
          if value
            set_custom_vars += "_paq.push(['setCustomVariable', #{index + 1}, '#{key}', '#{value}', 'page']);\n"
          end
        end
        returning_value = <<-EOF
<script type="text/javascript">
  var _paq = _paq || [];
  #{set_custom_vars}
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="#{piwik_url}";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', 1]);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0]; g.type='text/javascript';
    g.defer=true; g.async=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
<noscript><p><img src="#{piwik_url}piwik.php?idsite=1" style="border:0" alt="" /></p></noscript>
EOF
      returning_value
      end
  end
end
