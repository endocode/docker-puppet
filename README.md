docker build -t endocode/phusion-image phusion-image/image
docker build -t endocode/puppet-master puppet-master
./run_puppet_master.sh
