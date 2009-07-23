class Page
  
  def initialize(current_url, current_vertex, html, base_href, &url_generator)
    @document = Hpricot(html)

    change_links(current_url, current_vertex, base_href, &url_generator)
    change_forms(current_vertex, &url_generator)
    add_base_href(base_href)
  end
  
  def to_s
    @document.to_html
  end
  
  def title
    @document.search( '//title' ).text
  end

private

  def change_links(current_url, current_vertex, base_href, &url_generator)
    @document.search('//a[@href]') do |link|
      link_href = link.attributes['href']

      if anchor_match = link_href.match( /^(#.*)/ )
        # keep in page anchors on page
        link.set_attribute :href, "#{current_url}#{anchor_match[1]}"
      elsif ! link_to_file?( link_href )
        begin
          link_href = "#{base_href}#{link_href}" if URI.parse(link_href.to_s).relative?
      
          node_path = NodeConnection.new(current_vertex, link_href, link.inner_text.strip)
          link.set_attribute( :href, node_path.to_url(&url_generator) )
        rescue URI::InvalidURIError
        end
      end
    end
  end

  def change_forms(current_vertex, &url_generator)
    @document.search( '//form' ) do |form|
      form_action = form.attributes['action']
      inputs = form.search( '//input' )
      inputs.first.before( "<input type=hidden name='t' value='#{form_action}' />" )
      inputs.first.before( "<input type=hidden name='v' value='#{URI.escape(current_vertex.url)}' />" )
      inputs.first.before( "<input type=hidden name='n' value='<button>' />" )

      form.set_attribute( :action, url_generator.call )
    end
  end
  
  def add_base_href(base_href)
    @document.search( '//head' ) do |head|
      head_elements = head.search('/')
      head_elements.first.before( "<base href='#{base_href}' />" )
    end
  end
  
  def link_to_file?(link)
    extension_match = link.match( /\.(\w+)$/i )
    return false unless extension_match

    extension_match[1] !~ /s?html?|aspx?|php/i
  end
end
