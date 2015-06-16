class DashboardController < ApplicationController
  def index
    time = Time.now.hour
    @series = get_series(time)
    @categories = get_categories(time)
  end


  private
# This method uses ServerLoad logs to calculate the average ram_usage per server per hour.
# It formats the output as expected by highcharts.
#
# * *Args*    :
#   - current_hour -> the current hour is needed to collect the logs of the previous 24 hours
# * *Returns* :
#   - @series -> hashmap inside an array, highcharts expects the keys :name->(STRING) and :data->(ARRAY)
# * *Raises* :
#   - Nothing
    def get_series(current_hour)
      @series = []
      empty_hash =  {}
      Array (00..23).each{|i| empty_hash[i] = [ServerLoad.new({:ram_usage => 0})]}
      Server.all.each do |s|
        logs_per_hour = empty_hash.merge!(ServerLoad.where(server_id: s.id, updated_at: (Time.now - 24.hours)..Time.now).group_by(&:hour))
        data = logs_per_hour.map{|k,array| (array.map{|l| l.ram_usage}.reduce(:+).to_f/ array.size).round(2)}
        data = data[current_hour+1..data.size]+ data[0..current_hour]
        puts data.inspect
        @series.push({name: s.name, data: data})
      end
      return @series
    end

# This method created an array 0..23 and reorder this based on the current_hour,
# if the current time is 12:01 the output will look like this:
# ["13:00","14:00","15:00","16:00","17:00","18:00","19:00","20:00","21:00","22:00","23:00","0:00",1:00","2:00","3:00","4:00","5:00","6:00","7:00","8:00","9:00","10:00","11:00","12:00"]
#
# * *Args*    :
#   - current_hour -> the current hour is needed to match the order of the list with the previous 24 hours
# * *Returns* :
#   - @categories -> an array with axis labels, it contains the previous hours 
# * *Raises* :
#   - Nothing
    def get_categories(current_hour)
      @categories = []
      Array (00..23).each{|i| @categories.push("#{i}:00")}
      @categories = @categories.split("#{current_hour}:00").insert(0, "#{current_hour}:00").reverse.flatten
      return @categories
    end
end