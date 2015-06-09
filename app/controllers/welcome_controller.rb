class WelcomeController < ApplicationController
  def index
    

    # @servers = []
    # @server_loads.each_with_index do |s,i|
    #     hour_group = ServerLoad.where("created_at > :day_ago",{day_ago: 1.day.ago}).where(id: s.id).group_by {|ticker| ticker.created_at.hour}

    #     group_average_array = [0]*24
    #     hour_group.each_pair do |idx, arr|
    #         group_average_array[idx] = (arr.map(&:ram_usage).sum)/arr.size
    #     end

    #     @servers[i] = {name: Server.find(s.server_id).name, data: group_average_array}
    #  end
    @series = []

    @servers = Server.all
    @servers.each do |s|
      hour_group = ServerLoad.where(server_id: s.id).where("created_at > :day_ago",{day_ago: 1.day.ago}).group_by {|ticker| ticker.created_at.hour}
      group_average_array = [0]*24
      hour_group.each_pair do |idx, arr|
        group_average_array[idx] = (arr.map(&:ram_usage).sum)/arr.size
      end
       @series.push({name: s.name, data: group_average_array})
    end
    puts @series
    @categories =["00:00","01:00", "02:00"]
    # @series = @series.map{|k| "{name: '#{k[:name]}', data: #{k[:data]} }" }
  end
end
