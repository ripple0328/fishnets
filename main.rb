get '/' do
  'hello'
end

use Weixin::Middleware, 'fishnets', '/access' 

configure do
    set :wx_id, 'fishnets'
end

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
    if message.class == Weixin::TextMessage
        content = message.Content
        if content == 'Hello2BizUser'
            reply_msg_content = "Thx, #{reply_msg_content}"
        else
          reply_msg_content = talk_to_bot(content)
        end
    end

    create_message(settings.wx_id, from, 'text', reply_msg_content)
end

