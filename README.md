# README

This app functions as an API backend for sending emails via Mailgun's API. 

It utilizes Rails as the API server, JSON Web Tokens via Devise for authentication, 
and SQLite to store user accounts and tokens.


Requirements:
    - Mailgun account, API key and Domain
    - Ruby @2.6.6+
    - Rails @6.1+


This excellent tutorial will help you: 
    - Setup MacOS's Developer Tools
    - Install Homebrew
    - Install Git
    - Install RVM (or another software version manager)
    - Install Ruby
    - Install Rails

https://learn-rails.com/install-rails-mac/index.html



Once everything is installed and configured:
    - Clone this repository
    - Navigate to the cloned directory and open it in terminal
    - Enter "bundle install"
    - Enter "rake db:create db:migrate" if database does not exist
    - Enter "rails server"



Rails should now be running with these API endpoints exposed:
    - http://localhost:3000/register
    - http://localhost:3000/sign_in
    - http://localhost:3000/mail


POST a JSON payload in this format to /register to create a user account:
    {
        "user": {
            "email": "youremail@yourdomain.com",
            "password": "yourPassword"
        }
    }


POST the same payload to /sign_in to get a bearer token for authentication:
    {
        "user": {
            "email": "youremail@yourdomain.com",
            "password": "yourPassword"
        }
    }
Make sure to copy the bearer token from the response header so you can include it 
in your requests that require authentication.


POST a JSON payload in this format to /mail to queue a message to be sent:
    {
        "api_key": "YourMailGunAPIKey",
        "domain": "YourMailgunDomain.mailgun.org",
        "from": "Sender Name <mailgun@YourMailgunDomain.mailgun.org>",
        "to": "YourRecipient@domain.com",
        "subject": "A Subject!",
        "body":  
        "<html><body>Email Text (HTML optional)</body></html>"
    }
Make sure to include your bearer token in the request's Authorization header.



Alternatively, you can include a 'template' key and a 'parameters' nested with 
'arg1', 'arg2', 'arg3' and 'arg4' keys. Any, or all of the arg keys can be empty, 
but must exist if 'template' is present. Anything within the 'body' key will be 
appended after the template contents:
    {
        "api_key": "YourMailGunAPIKey",
        "domain": "YourMailgunDomain.mailgun.org",
        "from": "Sender Name <mailgun@YourMailgunDomain.mailgun.org>",
        "to": "YourRecipient@domain.com",
        "subject": "A Subject!",
        "body": "<html><body>Email Text (HTML optional)</body></html>",
        "template": "welcome",
        "parameters": {
            "arg1": "WebsiteName",
            "arg2": "Item1",
            "arg3": "Item2",
            "arg4": "Item3"
        }
    }

Valid template names are: "welcome", "confirm_email", and "reset_password" with the arguments as follows:

welcome:
    arg1: Your website
    arg2: An item available on your website
    arg3: An item available on your website
    arg4: An item available on your website

confirm_email:
    arg1: Your website
    arg2: Confirmation link

reset_password:
    arg1: Recipient's name or username
    arg2: Reset link
    arg3: Number of hours before link expires




Once the payload is successfully delivered, your message will be sent shortly. 
If you're using a sandboxed domain, the email will likely land in your spam folder.
