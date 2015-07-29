require 'em-eventsource'
require 'json'

OpenhabURL = "http://localhost:8080"
Debuglevel = 0



def Openhabevent(item,state)
    puts "Function for Item #{item} started, value #{state}"
    case item
    when "Test"
      send_event("welcome", "text", state)
    else
      send_event(item, "state", state)
    end    #code
end

def send_event(widget,content,state)
    dashinghash = { auth_token: "YOUR_AUTH_TOKEN"}
    dashinghash[content] = state
    http = EventMachine::HttpRequest.new("http://localhost:3030/widgets/#{widget}").post :body => dashinghash.to_json
    http.errback { p 'Uh oh'}
    http.callback {
        if Debuglevel == 1
          p http.response_header.status
          p http.response_header
          p http.response
        end
    }
    puts "sent!!"
end

EM.run do
  source = EM::EventSource.new("#{OpenhabURL}/rest/events")
  source.inactivity_timeout = 0
  
  source.on "message" do |message|
    response = JSON.parse(message)
    item = response["topic"][/([^\/]*)\Z/]
    if Debuglevel == 1
      puts "Got State #{response["object"]} for Item #{item}"
    end
    Openhabevent(item,response["object"])
  end
  source.error do |error|
    puts "error #{error}"
    sleep(30)
    source.close
    source.start
  end
  source.open do
    puts "connection to OpenHAB opened"
  end
  source.start
end