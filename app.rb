require 'sinatra'
require 'pony'
require 'json'

RECIPIENTS = ENV['RECIPIENTS'].split ';'
EMAIL = ENV['CLOUDMAILIN_FORWARD_ADDRESS']
USER = EMAIL.split('@').first

Pony.options = {
  via: :smtp,
  via_options: {
    address: 'smtp.sendgrid.net',
    port: '587',
    domain: 'heroku.com',
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }
}

before do
  if request.request_method == "POST" and request.content_type=="application/json"
    body_parameters = request.body.read
    parsed = body_parameters && body_parameters.length >= 2 ? JSON.parse(body_parameters) : nil
    params.merge!(parsed)
  end
end

get '/' do
  "There are currently #{RECIPIENTS.count} recipients"
end

post "/cm#{USER}" do
  from = params['envelope']['from']
  return "Rejected email from non group member #{from}" unless RECIPIENTS.include? from
  RECIPIENTS.each do |recipient|
    Pony.mail to: recipient,
      from: params['envelope']['from'],
      reply_to: EMAIL,
      subject: params['headers']['Subject'],
      body: params['plain'],
      html_body: params['html']
  end
  "Sent #{RECIPIENTS.count} emails"
end