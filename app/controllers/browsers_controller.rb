require 'net/http'
require 'hpricot'

class BrowsersController < ApplicationController
  
  before_filter :prepare_browser, :only => [ :show ]
  
  # Broken:
  #   Need to handle AJAX requests - fuck! :)
  #   Need to handle links to images..
  # => Handled by not tracking anything with specific file extensions..
  # => Should track links to these and return the appropriate content.. we can do this by switching off of the HTTP response headers. 
  #
  # Grace:
  #   Need to handle/guard-against logging in through forms   
  #   Need to handle various HTTP responses
  
  def show
    resp = resolve_request
    content = resp.body
    
    p "got content:"
    p content

    # tbd - switch on content
    
    handle_html_file(content)
  end
  
private

  def prepare_browser
    p 'show called'
    p params
    
    @fields = params.dup
    @fields.delete "controller"
    @fields.delete "action"
    puts "@fields=#{@fields.inspect}"
    
    @current_url = browser_url( @fields )
    p "@current_url=#{@current_url}"
    
    @target_url = @fields.delete("t") || 'http://www.wikipedia.org'
    @target_url += '?' + @fields.map { |k,v| "#{k}=#{v}" }.join( '&' ) unless @fields.empty?
    puts "@target_url=#{@target_url.inspect}"
  end
  
  def resolve_request
    target_url_path = URI.escape(@target_url)
    target_uri = URI.parse( target_url_path )
    resp = Net::HTTP.start(target_uri.host, target_uri.port) do |http|
      p "looking up #{target_url_path}"
      http.get(target_url_path)
    end
    
    # follow redirects
    while resp.is_a?( Net::HTTPFound ) || resp.is_a?( Net::HTTPMovedPermanently ) do
      target_url_path = resp.instance_variable_get( :@header )['location'].to_s
      p "redirecting to '#{target_url_path}'"
      target_uri = URI.parse( target_url_path )
      
      resp = Net::HTTP.start(target_uri.host, target_uri.port) do |http|
        http.get(target_url_path)
      end
    end
    
    @base_href = target_uri.select( :scheme, :host ).join( '://' )
    
    resp
  end
  
  def handle_html_file(content)
    @document = Hpricot(content)
    
    # intercept links
    @document.search('//a[@href]') do |link|
      link_href = link.attributes['href']

      if anchor_match = link_href.match( /^(#.*)/ )
        # keep in page anchors on page
        link.set_attribute :href, "#{@current_url}#{anchor_match[1]}"
      elsif ! link_to_file?( link_href )
        begin
          link_href = "#{@base_href}#{link_href}" if URI.parse(link_href.to_s).relative?
          link.set_attribute :href, browser_url( :t => URI.escape(link_href) )
        rescue URI::InvalidURIError
        end
      end
    end

    # intercept forms    
    @document.search( '//form' ) do |form|
      form_action = form.attributes['action']
      inputs = form.search( '//input' )
      inputs.first.before( "<input type=hidden name='t' value='#{form_action}' />" )
      
      form.set_attribute( :action, browser_url )
    end

    # add base href
    @document.search( '//head' ) do |head|
      head_elements = head.search('/')
      head_elements.first.before( "<base href='#{@base_href}' />" )
    end    
  end
  
  def link_to_file?(link)
    extension_match = link.match( /\.(\w+)$/i )
    return false unless extension_match

    extension_match[1] !~ /s?html?|aspx?|php/i
  end
end
