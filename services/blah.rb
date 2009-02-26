require 'rubygems'
require 'oauth/consumer'
require 'yaml'
 
module Laika
  class Yammer
 
    class CouldNotLoadCredentials < Exception; end
    class CouldNotPost < Exception; end
    
    attr_reader :access_token
    
    def initialize(credential_file='laika.yml')
      begin
        @credentials = YAML.load_file(credential_file)
      rescue
        raise CouldNotLoadCredentials, "Couldn't load your Yammer credentials. You may need to run laika-auth."
      end
      @consumer = OAuth::Consumer.new(@credentials[:consumer_key], @credentials[:consumer_secret], {:site => "https://www.yammer.com"})
      @access_token = OAuth::AccessToken.new(@consumer, @credentials[:access_token], @credentials[:access_token_secret])
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
end
