require 'sinatra'
require 'mail'
require 'json'

RECIPIENTS = ENV['RECIPIENTS'].split ';'
EMAIL = ENV['CLOUDMAILIN_FORWARD_ADDRESS']

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.sendgrid.net',
    port: '587',
    domain: 'heroku.com',
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    authentication: :plain,
    enable_starttls_auto: true
  }
end

before do
  if request.request_method == 'POST' and request.content_type == 'application/json'
    body_parameters = request.body.read
    parsed = body_parameters && body_parameters.length >= 2 ? JSON.parse(body_parameters) : nil
    params.merge!(parsed)
  end
end

get '/' do
  "There are currently #{RECIPIENTS.count} recipients"
end

post '/mailin' do
  from, subject = params['envelope']['from'], params['headers']['Subject']
  body, html_body = params['plain'], params['html']
  in_reply_to, references = params['headers']['In-Reply-To'], params['headers']['References']
  return "Rejected email from non group member #{from}" unless RECIPIENTS.include? from
  sent = 0
  RECIPIENTS.each do |recipient|
    unless recipient == from
      mail = Mail.new do
        to recipient
        reply_to EMAIL
        from from
        subject subject
        body body
        html_part do
          content_type 'text/html; charset=UTF-8'
          body html_body
        end
      end
      mail.in_reply_to = in_reply_to if in_reply_to
      mail.references = references if references
      mail.deliver!
      sent =+ 1
    end
  end
  "Sent #{sent} emails"
end