# This is a comment
require 'sinatra'
require 'json'

post '/payload' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  body = payload_body.delete_prefix('payload=')
  decoded_uri = CGI.unescape(body)
  #printf("###%s###", decoded_uri)
  push = JSON.parse(decoded_uri)
  "I got some JSON: #{push.inspect}"
end

def verify_signature(payload_body)
  signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE_256'])
end
