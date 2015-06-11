class ServerLoad < ActiveRecord::Base
    def hour
      self.created_at.to_date.strftime('%H')
    end
end
