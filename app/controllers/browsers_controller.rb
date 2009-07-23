require 'net/http'
require 'hpricot'

class BrowsersController < ApplicationController
    
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
    # tbd - switch on content
    
    p 'show called'
    p params
    
    @fields = params.dup
    @fields.delete "controller"
    @fields.delete "action"
    puts "@fields=#{@fields.inspect}"
    
    @browser = Browser.new(browser_url( @fields ), @fields)
    p @browser

    @browser.load_page
    
    url_generator = method(:browser_url).to_proc
    @page = @browser.get_page(&url_generator)
    
    Graph.record_node(
      @browser.next_page.origin_vertex, 
      @browser.next_page.link_name, 
      @page.title, 
      @browser.next_page.destination_vertex_url)
  end

end
