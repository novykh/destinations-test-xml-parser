class HomeController < ApplicationController
  def index
    @destinations = Crawler.new.get_nodes
    @destination = params[:destination_id] && !params[:destination_id].empty? ? @destinations.find{|x| x[:id] == params[:destination_id]} : @destinations.first
    @destination_desc = Crawler.new({id: @destination[:id]}).get_description
  end
end