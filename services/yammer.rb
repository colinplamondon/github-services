service :yammer do | data, payload|

  require 'oauth'
  require 'oauth/client'
   CONSUMER_KEY    = ''
   CONSUMER_SECRET = ''
   def index    
     if request.post?      
       consumer                     = get_consumer
       @request_token               = consumer.get_request_token
       session[:oauth_token]        = @request_token.token
       session[:oauth_token_secret] = @request_token.secret
       redirect_to @request_token.authorize_url # redirects user to https://www.yammer.com/authorize
     end        
   end      

   def callback
     consumer                     = get_consumer
     @request_token               = OAuth::RequestToken.new(consumer,session[:oauth_token],session[:oauth_token_secret])
     @access_token                = @request_token.get_access_token
     session[:oauth_token]        = @access_token.token
     session[:oauth_token_secret] = @access_token.secret        
   end                                                      

   def messages                     
     @access_token = OAuth::AccessToken.new(consumer,session[:oauth_token],session[:oauth_token_secret])
     @response     = @access_token.get '/api/v1/messages.json'
     if @response.is_a?(Net::HTTPSuccess)
       @api          = ActiveSupport::JSON::decode(@response.body)
     else
       flash[:error] = "Code: #{@response.code}, Error: #{ActiveSupport::JSON::decode(@response.body).pretty_print_inspect}"
       render :action => :error
     end
   end

   def post(message)
     response = @access_token.post('/api/v1/messages', {:body => message}, {'Accept' => 'application/xml'})
     if response.is_a?(Net::HTTPCreated)
       true
     else
       raise CouldNotPost, response.body
     end
   end
   def get_consumer
     @consumer||=OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,:site => "https://www.yammer.com")
   end

end
 
    def post(message)
      response = @access_token.post('/api/v1/messages', {:body => message}, {'Accept' => 'application/xml'})
      if response.is_a?(Net::HTTPCreated)
        true
      else
        raise CouldNotPost, response.body
      end
    end

end
