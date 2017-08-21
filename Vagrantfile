# -*- mode: ruby -*-
# vi: set ft=ruby :
Dir[File.expand_path("#{File.dirname(__FILE__)}/plugins/*.rb")].each {|file| require file }
env = UserEnv.load

servers = %w[manager worker-1 worker-2]

Vagrant.configure(2) do |config|
  servers.each do |server|
    config.vm.define server do |node|
      node.vm.box = "kmm/ubuntu-xenial64"
      node.vm.hostname = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-#{server}"
      node.vm.network :public_network, bridge: env['switch_name']
      node.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: env['smb_username'], smb_password: env['smb_password']

      node.vm.provider :hyperv do |hv, override|
        hv.vmname = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-#{server}"
        hv.memory = 1024
        hv.cpus = 2
      end

      node.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "ansible/vagrant_swarm.yml"
      end

    end
  end
end
