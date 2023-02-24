module ::DiscourseOpenAIBot
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseOpenAIBot
    config.autoload_paths << File.join(config.root, "lib")
  end
end
