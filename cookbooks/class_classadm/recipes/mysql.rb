include_recipe "class_classadm::default"

# allow classadms to manage mysql
classadm_commands "mysql" do
  commands [
    "/etc/init.d/mysqld *",
    "/sbin/chkconfig mysqld on",
    "/sbin/chkconfig mysqld off"
  ]
end