# -*- coding: utf-8 -*-
$body = 'hello'
get '/' do
  $body
end

use Weixin::Middleware, TOKEN, '/access' 


helpers do

    def create_message(from, to, type, content, flag=0)
        msg = Weixin::TextReplyMessage.new
        msg.ToUserName = to
        msg.FromUserName = from
        msg.Content = content
        msg.to_xml
    end
    
    def talk_to_bot(msg)
      @url = DOIDO
      @post_param = {'say' => msg}
      @return = Net::HTTP.post_form(URI.parse(@url),@post_param)
      @replay = Nokogiri::HTML(@return.body).text
    end
end

get '/access' do
    params[:echostr]
end


post '/access' do
    content_type :xml, 'charset' => 'utf-8'
    message = request.env[Weixin::Middleware::WEIXIN_MSG]
    logger.info "message: #{request.env[Weixin::Middleware::WEIXIN_MSG_RAW]}"

    from = message.FromUserName
    to = message.ToUserName
    
    if message.class == Weixin::TextMessage
        content = message.Content
        if content == 'Hello2BizUser'
            reply_msg= "你好啊, #{from}"
        else
          reply_msg = talk_to_bot(content)
        end
      $body = content
    end
    
    create_message(to, from, 'text', reply_msg)
end

