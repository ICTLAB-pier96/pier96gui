class ApplicationController < ActionController::Base

  protected
    def protect
      @ips = ['127.0.0.1', '62.195.198.94', '83.128.202.205']
      if not @ips.include? request.remote_ip
         if user = authenticate_with_http_basic { |u, p| u=='pier96' and p=='Pier96hro' }
              @current_user = user
         else
              request_http_basic_authentication
         end
      end
    end
end
