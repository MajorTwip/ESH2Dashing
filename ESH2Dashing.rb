#!/usr/bin/ruby -w

# This is a quick and dirty solution to update Tiles in Dashing when a state in Openhab2 / ESH gets updated
# Attention, I use altered tiles
# Author: MajorTwip (majortwip(at)twipnet.ch)
require 'em-eventsource'
require 'json'

OpenhabURL = "http://localhost:8080"
Debuglevel = 0



def Openhabevent(item,state)
    puts "Function for Item #{item} started, value #{state}"
    # in this example, when the item "Test" receives an update, the data to send can be altered
    case item
    when "Test"
      send_event("welcome", "text", state)
    else
    # if nothing to do, then the Tile "itemname" will get un update for his data-state to "state"
      send_event(item, "state", state)
    end    #code
end

def send_event(widget,content,state)
    #to do: use YOUR_AUTH_TOKEN-variable to change on top of the script
    dashinghash = { auth_token: "YOUR_AUTH_TOKEN"}
    dashinghash[content] = state
    http = EventMachine::HttpRequest.new("http://localhost:3030/widgets/#{widget}").post :body => dashinghash.to_json
    http.errback { p 'error while sending to Dashing'}
    http.callback {
        if Debuglevel == 1
          p http.response_header.status
          p http.response_header
          p http.response
        end
    }
    puts "update sent!!"
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
    sleep(60)
    source.close
    source.start
  end
  source.open do
    puts "connection to OpenHAB opened"
  end
  source.start
end
