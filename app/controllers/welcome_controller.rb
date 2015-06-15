class WelcomeController < ApplicationController
  def index
    @series = []

    @servers = Server.all

    load_hash = {}
    @servers.each do |s|
      hash = {}
      ServerLoad.where(server_id: s.id).where(updated_at: (Time.now - 24.hours)..Time.now).each do |s|
        if hash[s.created_at.hour+2].nil?
          hash[s.created_at.hour+2] = [s.ram_usage]
        else
          hash[s.created_at.hour+2] = hash[s.created_at.hour+2].push(s.ram_usage)
        end
      end
      load_hash[s.id] = hash
    end

    load_hash.each do |key, hash|
      hash.each do |hour, value|
        avg = (value.sum/value.size)
        load_hash[key][hour] = avg
      end
    end

    @categories = []
    @servers.each do |s|
      data = []
      time = Time.now.hour
      @categories.push("#{time}:00")
      data.push(load_hash[s.id][time])
      i = time -1 
      while i != time
        @categories.push("#{i}:00")
        data.push(load_hash[s.id][i])
        i = i - 1
        i = 23 if i == -1
        puts i
      end
      @series.push({name: s.name, data: data.reverse })
      @categories = @categories.reverse
    end
  end
end