require "json"
require "yaml"
require 'io/console'

class UserEnv
	def self.load
		instance = self.new
		instance.load_env
	end

	def up_command?
		ARGV[0].downcase.eql?('up')
	end

	def reload_command?
		ARGV[0].downcase.eql?('reload')
	end

	def env_file
		File.join(Dir.home, '.vagrant.d', 'vagrant.env')
	end

	def load_env
		return {} unless(Gem.win_platform? && (up_command? || reload_command?))

		#raise "No UserEnv file exists! Please run \"rake create:env\"" unless File.exists?(env_file)
    create_env_file unless File.exists?(env_file)
		get_switch_command = File.expand_path("#{File.dirname(__FILE__)}/setup_vmswitch.ps1")
		switch_name =  `powershell.exe -ExecutionPolicy RemoteSigned -Command \"#{get_switch_command}\"`

		puts "Setting up VM to use #{switch_name}"

		default_env_config = {
		  'smb_username' => ENV['USERNAME'],
		  'switch_name' => switch_name.strip
		}

		default_env_config.merge(YAML::load(File.read(env_file)))
	end

	def create_env_file
		return if File.exists?(env_file)

		settings = {}
		puts "Enter current password: "
		password = ::STDIN.noecho(&:gets)
		settings['smb_password'] = password.chomp

		File.open(env_file, "w") do |file|
		  file.write settings.to_yaml
		end
	end
end
