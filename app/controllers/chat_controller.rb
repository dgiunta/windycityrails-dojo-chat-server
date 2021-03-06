class ChatController < ApplicationController
  before_filter :check_cookie, :only => [:index]
  skip_before_filter :verify_authenticity_token, :only => :push

  def index
    @recent_messages = (RedisClient.redis.zrevrange("room:default", 0, 30) || []).map { |message_json| ActiveSupport::JSON.decode(message_json) }
  end

  def sign_in
    cookies[:username] = params[:username]
    #TODO: need to store this in redis
    redirect_to :action => :index
  end

  def push
    user = cookies[:username] || params[:username] || "Anon"
    time_stamp = Time.now.to_f * 1000

    message = params[:message]
    message = %Q|<img src="#{params[:message]}" />| if message =~ /^http:\/\/.+\.(png|jpg|jpeg|gif)$/i

    message_json = {:username => user, :message => message, :time_stamp => time_stamp}.to_json

    RedisClient.redis.zadd("room:default", time_stamp, message_json)

    render :nothing => true
  end

  def pull
    messages = if params[:last_sync].to_i == 0
      []
    else
      delta = RedisClient.redis.zrangebyscore 'room:default', params[:last_sync].to_f + 0.01, '+inf' 
      delta.map { |message_json| ActiveSupport::JSON.decode(message_json) }
    end
    
    render :json => {:time => Time.now.to_f * 1000, :delta => messages}
  end

  protected

  def check_cookie
    redirect_to :action => :sign_in_form unless cookies[:username]
  end
end
