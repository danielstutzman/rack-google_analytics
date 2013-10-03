module Rack #:nodoc:
  class Piwik < Struct.new :app, :options

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

      # Returns JS to be embeded. This takes one argument, a Web Property ID
      # (aka UA number).
      def tracking_code(piwik_url)
        returning_value = <<-EOF
<script type="text/javascript">
  var _paq = _paq || [];
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
