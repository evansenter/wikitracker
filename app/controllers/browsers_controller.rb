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
    
    @browser = Browser.new(browser_url( @fields ), NodeConnection.new_from_params( @fields ))
    puts "-- On creation -- "
    p @browser

    url_generator = method(:browser_url).to_proc

    @browser.handle_request(&url_generator)
    puts "-- After page load -- "
    p @browser
    
    Graph.record_node(
      @browser.origin_vertex, 
      @browser.request.link_name, 
      @browser.next_vertex)
  end

end
