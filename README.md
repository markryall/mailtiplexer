# heroku addons

For receiving mail:

    heroku addons:add cloudmailin:developer
    heroku addons:open cloudmailin
    heroku addons:docs cloudmailin

For sending mail:

    heroku addons:add sendgrid:starter
    heroku addons:docs sendgrid

# Local testing

Start the application:

    bundle
    ruby app.rb

In the cloudmail in configuration, edit the email target to post to the cloudmailin web hooks address using json post format.  Send an email and capture the json post content (ignore the curl command - this doesn't seem to work).

Save the content to a file (eg. mail.json) and run this test command:

    sh test < mail.json