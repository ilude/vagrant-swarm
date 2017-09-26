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

node_count = 3

Vagrant.configure(2) do |config|
  config.vm.define :master, primary: true do |node|
    name = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-saltmaster"
    node.vm.box = "ilude/ubuntu-xenial-64"
    node.vm.hostname = name
    node.vm.network :public_network, bridge: env['switch_name']
    node.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: env['smb_username'], smb_password: env['smb_password']
    node.vm.provider :hyperv do |hv, override|
      hv.vmname = name
      hv.memory = 1024
      hv.cpus = 2
      hv.enable_virtualization_extensions = true
      hv.differencing_disk = true
    end

    #node.vm.synced_folder "saltstack/salt/", "/srv/salt"
    #node.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    node.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = false
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end

    node_count.times do |node_index|
      index = node_index + 1
      name = "swarm-#{index}"
      path = "/vagrant/tmp"
      node.vm.provision "shell", inline: "salt-key --gen-keys=#{name} --gen-keys-dir=#{path}; cp #{path}/#{name}.pub /etc/salt/pki/master/minions/#{name}"
    end
    #; salt-key -y -A
    node.vm.provision "shell", inline: "echo \"master: `hostname -I`\" > /vagrant/tmp/minion.config"
  end


  node_count.times do |server_index|
    index = server_index + 1
    server_name = "swarm-#{index}"
    config.vm.define server_name do |node|
      node.vm.box = "ilude/ubuntu-xenial-64"
      node.vm.hostname = server_name
      node.vm.network :public_network, bridge: env['switch_name']
      node.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: env['smb_username'], smb_password: env['smb_password']

      node.vm.provider :hyperv do |hv, override|
        hv.vmname = "#{File.basename(Dir.getwd)}-#{Socket.gethostname}-#{server_name}"
        hv.memory = 1024
        hv.cpus = 2
        hv.enable_virtualization_extensions = true
        hv.differencing_disk = true
      end

      node.vm.provision "shell", inline: "mkdir -p /etc/salt; cp /vagrant/tmp/minion.config /etc/salt/minion"

      node.vm.provision :salt do |salt|
        salt.minion_key = "tmp/#{server_name}.pem"
        salt.minion_pub = "tmp/#{server_name}.pub"
        salt.install_type = "stable"
        salt.verbose = true
        salt.colorize = true
        salt.bootstrap_options = "-P -c /tmp"
      end

    end
  end
end
