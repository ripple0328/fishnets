# -*- coding: utf-8 -*-
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
end

# post '/access' do
#   content_type :xml, 'charset' => 'utf-8'

#   message = request.env[Weixin::Middleware::WEIXIN_MSG]
#   logger.info "message: #{request.env[Weixin::Middleware::WEIXIN_MSG_RAW]}"

#   from = message.FromUserName
#   if message.class == Weixin::TextMessage
#     content = message.Content
#     if content == 'Hello2BizUser'
#       reply_msg_content = "感谢关注！#{reply_msg_content}"
#     end
#   end

#   create_message(settings.wx_id, from, 'text', reply_msg_content)
# end

get '/access' do
  @pre_digest = [TOKEN, request[:timestamp],request[:nonce]].sort.join
  @digest = Digest::SHA1.hexdigest(@pre_digest)
  @echo = request[:echostr]
  if @digest == request[:signature]
    @echo
  else
    'Error ' + @echo

  end
end

get '/' do
  'H'+BODY
end

post '/access'  do
  @body = request.body
  @page = Nokogiri::XML(@body)
  @msg = @page.at_xpath('xml/Content').text
  @dev = @page.at_xpath('xml/ToUserName').text
  @user = @page.at_xpath('xml/FromUserName').text
  @msg_type = @page.at_xpath('xml/MsgType').text
  @create_time =@page.at_xpath('xml/CreateTime').text
  @url = DOIDO
  @post_param = {'say' => @msg}
  @return = Net::HTTP.post_form(URI.parse(@url),@post_param)
  @replay = Nokogiri::HTML(@return.body).text

  BODY = @page
  
  @to_user = "
   <xml>
  <ToUserName><![CDATA[#{@user}]]></ToUserName>
  <FromUserName><![CDATA[#{@dev}]]></FromUserName>
  <CreateTime>#{@create_time}</CreateTime>
  <MsgType><![CDATA[news]]></MsgType>
  <Content><![CDATA[#{@replay}]]></Content>
  <FuncFlag>0</FuncFlag>
  </xml> "

  return @to_user

end
