FROM endocode/phusion-image
MAINTAINER Naftuli Tzvi Kay <rfkrocktk@gmail.com>
MAINTAINER Khramov Anton <anton@endocode.com>

ENV HOME /root
ENV LANG en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Install init script to add SSH keys
ADD scripts/01_configure_authorized_keys.d.sh /etc/my_init.d/
ADD scripts/02_add_ssh_env_keys.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/*.sh

# Install SSH daemon configuration
ADD conf/sshd/sshd_config /etc/ssh/sshd_config

# Fixes Docker Automated Build problem
RUN ln -s -f /bin/true /usr/bin/chfn

COPY icinga.key /tmp/icinga.key
RUN echo "deb http://packages.icinga.org/ubuntu icinga-trusty main" > /etc/apt/sources.list.d/icinga.list
RUN apt-key add /tmp/icinga.key

# Install tools
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y ca-certificates icinga2 > /dev/null

# Install Puppet Labs Repository for Trusty
RUN curl -o puppet.deb -s https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i puppet.deb > /dev/null \
    && rm puppet.deb

# Install the latest stable Puppet client
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes -q 2 puppet >/dev/null

# Install startup script for adding the cron job
ADD scripts/50_add_puppet_cron.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/50_add_puppet_cron.sh

# Install startup script for puppet agent configuration
ADD scripts/60_configure_puppet_agent.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/60_configure_puppet_agent.sh

# Install actual Puppet agent run command
ADD scripts/run-puppet-agent.sh /sbin/run-puppet-agent
RUN chmod +x /sbin/run-puppet-agent

# Enable sshd
RUN rm -f /etc/service/sshd/down
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

EXPOSE 5665

# Use the runit init system.
CMD ["/sbin/my_init"]
