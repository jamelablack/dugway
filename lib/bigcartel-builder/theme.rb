require 'sprockets'

module BigCartel
  module Builder
    class Theme      
      def initialize(source_dir, overridden_user_settings)
        @source_dir = source_dir
        @overridden_user_settings = overridden_user_settings
      end
      
      def find_template_by_path(path)
        name = path.split('/')[1] || 'home'
        name = name.include?('.') ? name : "#{ name }.html"
        
        if name =~ /\.html$/ && content = read_source_file(name)
          Template.new(self, name, content)
        elsif name == 'styles.css'
          Template.new(self, name, sprockets[name].to_s)
        elsif name == 'scripts.js'
          Template.new(self, name, sprockets[name].to_s, false)
        else
          nil
        end
      end
      
      def layout
        @layout ||= read_source_file('layout.html')
      end
      
      def settings
        @settings ||= JSON.parse(read_source_file('settings.json'))
      end
      
      def user_settings
        @user_settings ||= begin
          Hash.new.tap { |user_settings|
            %w( fonts colors options ).each { |type|
              if settings.has_key?(type)
                settings[type].each { |setting|
                  user_settings[setting['variable']] = setting['default']
                }
              end
            }
          
            user_settings.update(@overridden_user_settings)
          }
        end
      end
      
      private
      
      def sprockets
        @sprockets ||= begin
          sprockets = Sprockets::Environment.new
          sprockets.append_path @source_dir
          sprockets
        end
      end
      
      def read_source_file(file_name)
        file_path = File.join(@source_dir, file_name)
        
        if File.exist?(file_path)
          File.open(file_path, "rb").read
        else
          nil
        end
      end     
    end
  end
end
