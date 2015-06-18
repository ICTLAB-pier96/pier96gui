class ServerLoad < ActiveRecord::Base
    
# The hour method returns an hour based on the created_at timestamp.
# If the localtime is 2015-06-16 11:37:47 +0200 it will return 11
#
# * *Returns*    :
#   - Integer -> the hour in which the model is created.
    def hour
      self.created_at.localtime.hour
    end
end
