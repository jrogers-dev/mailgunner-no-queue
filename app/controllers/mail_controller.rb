class MailController < ApplicationController
  before_action :authenticate_user!

  #Default response if you try and GET /mail
  def show
    render json: { message: "POST a JSON payload to this URL to send an email" }, status: 200
  end

  #Here is the main logic of the app.
  #Ideally the user is logged in and has their JWT token
  #They will submit, in JSON format, all the metadata necessary
  #to send an email through Mailgun
  def create
    @payload = mail_params()
    @error = false
    @response = {message: "", status: 200}
    
    if valid_payload?()
      if @payload["template"].present? && valid_template?()
        inject_template()
      end
    end

    if @error == false
      deliver_payload()
    end

    render json: {message: @response[:message]}, status: @response[:status]
  end

  private

  #This function allows us to filter out unwanted keys and values
  #by permitting only the ones we want. Since we must know the names
  #of the parameters, this limits us in how we use our templates
  def mail_params()
    params.permit(:api_key, :domain, :from, :to, :subject, :body, :template, :parameters => [:arg1, :arg2, :arg3, :arg4] )
  end

  #Here we determine if the metadata sent contains all the keys we're looking for
  def valid_payload?()
    if @payload.key?("api_key") && @payload.key?("domain") && @payload.key?("from")\
      && @payload.key?("to") && @payload.key?("subject") && @payload.key?("body")
      return true
    else
      @error = true
      @response = { message: "Invalid payload: JSON Payload must include key/value pairs for 'api_key'"\
      ", 'domain', 'from', 'to', 'subject', 'body', and  optionally 'template' and 'parameters'", status: 400}
      return false
    end
  end
  
  #Check that the template specified in the payload exists as a file in the templates folder
  def valid_template?()
    template_name = @payload["template"]
    if File.exists?("public/templates/#{template_name}.txt")
      return true
    else
      @error = true
      @response = {message: "Template name included in payload is invalid", status: 400}
      return false
    end
  end


  #Open specified template file, and if successful, interpolate parameters
  #from payload into the template text
  def inject_template()
    sym_payload = @payload.to_h.deep_symbolize_keys

    begin
      template_file = File.open("public/templates/#{sym_payload[:template]}.txt")
    rescue => e1
      @error = true
      @response = {message: "Unable to open file public/templates/#{sym_payload[:template]}.txt" + e1.message, status: 400}
    end

    begin
      @payload["body"] = template_file.read % sym_payload[:parameters] + sym_payload[:body]
    rescue => e2
      @error = true
      @response = {message: "Invalid template parameters: " + e2.message, status: 400}
    ensure
      template_file.close
    end
  end
  
  #Once we've established the metadata looks good, we can send it off to 
  #Mailgun by utilizing RestClient to post to Mailgun's API
  def deliver_payload()
    begin
      RestClient.post(
        "https://api:#{@payload["api_key"]}@api.mailgun.net/v3/#{@payload["domain"]}/messages",
        :from => @payload["from"],
        :to => @payload["to"],
        :subject => @payload["subject"],
        :html => @payload["body"]
      )
    rescue => e
      @response = { message: "Mailgun payload failed to post!", status: 400 }
    else
      @response = { message: "Successfully posted payload to Mailgun API!", status: 200 }
    end
  end
end