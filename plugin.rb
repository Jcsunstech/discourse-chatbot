# name: discourse-openai-bot
# about: a plugin that allows you to have a conversation with a GPT OpenAI Bot in Topics and Private Messages
# version: 0.1
# authors: merefield

gem "httparty", '0.21.0' #, {require: false}
gem "ruby-openai", '3.3.0', {require: false} 

module ::DiscourseOpenAIBot
  PLUGIN_NAME = "discourse-openai-bot"
end

require_relative "lib/discourse_openai_bot/engine"

enabled_site_setting :openai_bot_enabled

after_initialize do
  %w(
    ../lib/discourse_openai_bot/bot.rb
    ../lib/discourse_openai_bot/openai_bot.rb
    ../lib/discourse_openai_bot/reply_creator.rb
    ../app/jobs/discourse_openai_bot/openai_bot_reply_job.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end

  #register_topic_custom_field_type("conversation_id", :string)

  # add_to_class(:topic, :conversation_id) do
  #   if !self.custom_fields["conversation_id"].nil?
  #     self.custom_fields["conversation_id"]
  #   else
  #     nil
  #   end
  # end

  # add_to_class(:topic, "conversation_id=") do |value|
  #   custom_fields["conversation_id"] = value
  # end
  
  # on(:topic_created) do |topic, opts, user|
  #   if opts[:conversation_id] != nil
  #     topic.custom_fields['conversation_id'] = opts[:conversation_id]
  #     topic.save_custom_fields(true)
  #   end
  # end
  
  ##
  # type:        step
  # number:      4.2
  # title:       Preload the field
  # description: Discourse preloads custom fields on listable models (i.e.
  #              categories or topics) before serializing them. This is to
  #              avoid running a potentially large number of SQL queries 
  #              ("N+1 Queries") at the point of serialization, which would
  #              cause performance to be affected.
  # references:  lib/plugins/instance.rb,
  #              app/models/topic_list.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
 # add_preloaded_topic_list_custom_field(FIELD_NAME)

  DiscourseEvent.on(:post_created) do |*params|
    post, opts, user = params

    if SiteSetting.openai_bot_enabled

      bot_username = SiteSetting.openai_bot_bot_user
      bot_user = User.find_by(username: bot_username)

      if (user.id != bot_user.id) && post.reply_count = 0
        bot = DiscourseOpenAIBot::Bot.new
        bot.on_post_created(post)
      end
    end
  end

end
