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
