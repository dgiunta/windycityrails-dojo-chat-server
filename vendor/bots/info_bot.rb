require File.expand_path("../bot_base", __FILE__)

class InfoBot < BotBase
  TALKS = {
    (Time.parse("2010-09-11 10:00:00AM")..Time.parse("2010-09-11 10:45:00AM")) => "Analyzing and Improving the Performance of your Rails Application with John McCaffrey",
    (Time.parse("2010-09-11 11:00:00AM")..Time.parse("2010-09-11 11:45:00AM")) => "It’s Time to Repay Your Debt with Kevin Gisi, Intridea",
    (Time.parse("2010-09-11 01:00:00PM")..Time.parse("2010-09-11 02:00:00PM")) => "Lightning Talks",
    (Time.parse("2010-09-11 02:15:00PM")..Time.parse("2010-09-11 03:00:00PM")) => "Weaving Design and Development with Ryan Singer, 37signals",
    (Time.parse("2010-09-11 03:15:00PM")..Time.parse("2010-09-11 04:00:00PM")) => "Grease your Suite: Tips and Tricks for Faster Testing with Nick Gauthier, SmartLogic Solutions",
    (Time.parse("2010-09-11 04:15:00PM")..Time.parse("2010-09-11 05:00:00PM")) => "Sustainably Awesome: How to Build a Team with Les Hill & Jim Remsik, Hashrocket",
    (Time.parse("2010-09-11 05:15:00PM")..Time.parse("2010-09-11 06:00:00PM")) => "What's New With Rails 3 with THE Yehuda Katz, Engine Yard"
  }
  
  def self.talks
    TALKS
  end
  
  def current_talk
    self.class.talks.each do |talk|
      return talk[1] if talk[0].include?(Time.now)
    end
    
    nil
  end
  
  def push_current_talk
    talk = current_talk
    
    if talk
      push(talk)
    else
      push("Looks like no talks are happening right now. Go talk to somebody!")
      push("Or better yet, come over to the Obtiva Coding Dojo!")
    end
  end
  
  def msg_for_infobot?(message)
    if message =~ /#{username}: current talk/
      puts "InfoBot triggered!"
      return true
    else
      puts "InfoBot dormant"
    end
  end
  
  def respond
    new_messages = pull
    new_messages.each do |message|
      message_user = message["username"]
      message_text = message["message"]
      
      puts "InfoBot got: #{message_text}"
      if msg_for_infobot?(message_text)
        push_current_talk
      end
      
    end
  end
  
end

if __FILE__ == $0
  InfoBot.run!("infobot")
end