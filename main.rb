# -*- coding: utf-8 -*-

# for debug
get '/' do
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

    def query_ur_secret(info)
      begin
        u = URI::encode(SECRET_API + info)
        reply = RestClient.post(u,{})
        page = Nokogiri::HTML(reply.body,nil, "GB18030")
        table = page.css("table tr")
        reply = ''
        table.each do |tr|
          ts = '|'
          tr.css('td').each do |td|
            ts << td.text + '|'
          end
          reply << ts + '\n'
        end
        return reply
      rescue Exception => e
        @reply = "查不到--#{e.to_s}"
      end
      
    end

    def talk_to_bot(msg)
      # for diodo robot api
      # @url = CHATBOT_API
      # @post_param = {'say' => msg}
      # @post_param = {'chat' >= msg}
      
      begin
        # for diodo robot api
        
        # @return = Net::HTTP.post_form(URI.parse(@url),@post_param)
        # @reply = Nokogiri::HTML(@return.body).text
        #for xiaodou api
        @u = URI::encode(CHAT_XIAODOU_API + msg)
        @reply = RestClient.post(@u,{})
      rescue Exception => e
        @reply = "机器人太忙，歇会--#{e.to_s}"
      end
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
    content = message.Content
    if message.class == Weixin::TextMessage

        if content == 'Hello2BizUser'
          reply_msg= WELCOME_BANNER
        elsif content.strip =~ /^[s]/
          reply_msg = query_ur_secret(content.split[1].strip)
        else
          reply_msg = talk_to_bot(content)
        end
    end
    
    create_message(to, from, 'text', reply_msg)
end

