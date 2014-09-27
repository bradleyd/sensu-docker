require 'docker'
require 'erb'

# read file in
docker_config = File.read("/opt/pair/docker-sensu-server/Dockerfile")
image = Docker::Image.build(docker_config)
p img: image.json

p dbg: image.tag('repo' => 'sensu', 'force' => true)


# EXPOSE 22 3000 4567 5671 15672
a= {"PortBindings" =>  { "22/tcp" => [ { "HostPort" => "10022", "HostIp" => "0.0.0.0" } ], "4567/tcp" => [ { "HostPort" => "4568", "HostIp" => "0.0.0.0" } ], "5671/tcp" => [ { "HostPort" => "5671", "HostIp" => "0.0.0.0" } ] }}
container = Docker::Container.create('Image' => image.id)
p cont: container.json
p container.start(a)


puts "*****************************"
p dbg: container.commit
p dbg: container.json
