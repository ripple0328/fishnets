get '/'  do
  "hello world"  
end

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

  @to_user = "
   <xml>
  <ToUserName><![CDATA[#{@user}]]></ToUserName>
  <FromUserName><![CDATA[#{@dev}]]></FromUserName>
  <CreateTime>#{Time.now}</CreateTime>
  <MsgType><![CDATA[#{@msg_type}]]></MsgType>
  <Content><![CDATA[#{@replay}]]></Content>
  <FuncFlag>0</FuncFlag>
  </xml> "

  return @to_user

end
