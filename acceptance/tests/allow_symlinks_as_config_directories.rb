test_name "Should allow symlinks to directories as configuration directories"

step "Create the test confdir with a link to it"
confdir = "/tmp/puppet_conf-directory-#{$$}"
conflink = "/tmp/puppet_conf-symlink-#{$$}"

on agents, "rm -rf #{conflink} #{confdir}"

on agents, "mkdir #{confdir}"
on agents, "ln -s #{confdir} #{conflink}"

create_remote_file agents, "#{confdir}/puppet.conf", <<CONFFILE
[main]
certname = "awesome_certname"
CONFFILE

manifest = 'notify{"My certname is $clientcert": }'

step "Run Puppet and ensure it used the conf file in the confdir"
on agents, puppet_apply("--confdir #{conflink}"), :stdin => manifest do
  assert_match("My certname is awesome_certname", stdout)
end

step "Check that the symlink and confdir are unchanged"
on agents, "[ -L #{conflink} ]"
on agents, "[ -d #{confdir} ]"
on agents, "[ $(readlink #{conflink}) = #{confdir} ]"