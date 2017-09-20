# -*- mode: ruby -*-
# vi: set ft=ruby :
Dir[File.expand_path("#{File.dirname(__FILE__)}/plugins/*.rb")].each {|file| require file }
env = UserEnv.load

if ARGV.include?('up')
  # clean up temp files
  dir_path = "./tmp"

  puts "Cleaning up #{dir_path} files..."

  Dir.foreach(dir_path) {|f| fn = File.join(dir_path, f); File.delete(fn) if f != '.' && f != '..'&& f != '.keep' }
end

server_count = 3

Vagrant.configure(2) do |config|
  server_count.times do |server_index|
    index = server_index + 1
    server_name = "swarm-#{index}"
    config.vm.define server_name do |node|
      node.vm.box = "ilude/ubuntu-xenial-64"
      node.vm.hostname = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-#{server_name}"
      node.vm.network :public_network, bridge: env['switch_name']
      node.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: env['smb_username'], smb_password: env['smb_password']

      node.vm.provider :hyperv do |hv, override|
        hv.vmname = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-#{server_name}"
        hv.memory = 1024
        hv.cpus = 2
        hv.enable_virtualization_extensions = true
        hv.differencing_disk = true
      end

      node.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "ansible/swarm.yml"
      end

    end
  end
end
