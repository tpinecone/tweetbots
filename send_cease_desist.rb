require 'logger'
require 'chatterbot'
require './cease_desist_generator.rb'
require './ceasedesistbot.rb'

bot = Ceasedesistbot.new
log = Logger.new("/tmp/#{bot.botname}.log")
log.level = Logger::DEBUG

log.debug "Starting bot"

log.debug "Syncing following"
bot.sync_following!
log.debug "Done syncing"

bot.home_timeline do |original_tweet|
  log.debug "Trying to generate based on tweet id #{original_tweet.id}"
  new_tweet_username = original_tweet.user.screen_name

  if original_tweet.retweet? || new_tweet_username == bot.botname
    log.debug "Tweet is retweet or from ceasedesistbot, skipping"
    next
  end

  new_tweet_text = CeaseDesistGenerator.new(original_tweet.text, new_tweet_username).generate_tweet

  bot.config[:since_id] = original_tweet.id
  unless new_tweet_text.nil?
    log.debug "Got a result: #{new_tweet_text}. Replying."
    bot.reply new_tweet_text, original_tweet
    break
  end
end
