# Rubrik Chef Cookbook

## Overview

The Rubrik Chef cookbook is used to configure hosts on the Rubrik system, and install the Rubrik connector.

## Requirements

The following node attributes should be defined in order to use this cookbook:

Attribute Name | Description | Example Value
--- | --- | ---
rubrik_host | Defines the IP/hostname of the Rubrik cluster to interact with | clustera.demo.com
rubrik_username | Defines the username for the Rubrik cluster | john.doe@demo.com
rubrik_password | Defines the password for the user defined above | Rubrik123!
rubrik_sla_domain | Defines the Rubrik SLA Domain to protect objects with | Gold
rubrik_win_sa_user | Windows systems - defines the login user for the Rubrik Backup Service | sa_rubrik@demo.com
rubrik_win_sa_pass | Windows systems - defines the password for above RBS user | Rubrik123!
rubrik_fileset | Defines a list of fileset templates used to create filesets on this host | ['fileset_1', 'fileset_2']
rubrik_org_name | Defines the Organization to add the host to | 'ITOps'
rubrik_http_timeout | Defines the HTTP timeout in seconds (default: 60) | 100

Note that `rubrik_win_sa_user` and `rubrik_win_sa_pass` are optional, and will only be required if installing the
connector on a Windows system. If these are omitted then the service will run as LocalSystem.

Note that the `rubrik_fileset` attribute can take a single string, or an array of strings.

## Running recipes individually

The sample recipes included with the cookbook can be run individually through the following commands:

### Cluster Info

`sudo chef-client -z -r 'recipe[rubrik::cluster_info]' -l info`

### Get VMware VM SLA

`sudo chef-client -z -r 'recipe[rubrik::get_vmware_vm_sla]' -l info`

### Set VMware VM SLA

`sudo chef-client -z -r 'recipe[rubrik::set_vmware_vm_sla]' -l info`

### On-Demand VMware Snapshot

`sudo chef-client -z -r 'recipe[rubrik::snapshot_vmware_vm]' -l info`

### Register Host

`sudo chef-client -z -r 'recipe[rubrik::set_host_registration]' -l info`

### Get Host Registration Status

`sudo chef-client -z -r 'recipe[rubrik::get_host_registration]' -l info`

### Get SQL Server Host SLA

`sudo chef-client -z -r 'recipe[rubrik::get_sql_host_sla]' -l info`

### Set SQL Server Host SLA

`sudo chef-client -z -r 'recipe[rubrik::set_sql_host_sla]' -l info`

### Create Filesets

`sudo chef-client -z -r 'recipe[rubrik::create_fileset]' -l info`

### Get Fileset Details

`sudo chef-client -z -r 'recipe[rubrik::get_filesets]' -l info`

### Install Rubrik Connector

`sudo chef-client -z -r 'recipe[rubrik::connector]' -l info`

### Refresh Host

`sudo chef-client -z -r 'recipe[rubrik::refresh_host]' -l info`

### Refresh All vCenter Servers

`sudo chef-client -z -r 'recipe[rubrik::refresh_all_vcenters]' -l info`

### Check Organization membership

`sudo chef-client -z -r 'recipe[rubrik::get_object_organization]' -l info`

### Set Organization membership

`sudo chef-client -z -r 'recipe[rubrik::set_object_organization]' -l info`

## Detail

The resources and providers used are defined in `libraries/rubrik_api.rb`, this module is subject to on-going development.
Currently available resources are detailed below:

### Resources

#### get_cluster_info

##### Action: get

Dumps the cluster ID, version, and API version to the Chef log.

Example usage:

```ruby
rubrik_cluster_info 'get' do
  action :get
end
```

Example output:

```none
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_cluster_info[get] action get (rubrik::default line 7)
[2017-08-25T02:38:22-07:00] INFO: Cluster ID: 4a5d5fc5-a764-4c9c-8908-9d56e4221fd6
[2017-08-25T02:38:22-07:00] INFO: Cluster Version: 4.0.2-374
[2017-08-25T02:38:22-07:00] INFO: Cluster API version: 1
```

#### set_vmware_vm_sla

##### Action: get

Dumps the current SLA domain for the host to the Chef log.

Example usage:

```ruby
rubrik_set_vmware_vm_sla 'get' do
  action :get
end
```

Example output:

```none
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_set_sla[get] action get (rubrik::default line 11)
[2017-08-25T02:38:24-07:00] INFO: Current SLA domain is: Silver
```

##### Action: set

Sets the SLA domain for the host to the value set in `node['rubrik_sla_domain']`.

Example usage:

```ruby
rubrik_set_vmware_vm_sla 'set' do
  action :set
end
```

Example output:

```none
[2017-08-25T02:38:24-07:00] INFO: Processing rubrik_set_sla[set] action set (rubrik::default line 15)
[2017-08-25T02:38:27-07:00] INFO: Updated SLA domain to: Silver
```

Optional Properties:

The following optional parameters can be used when defining this resource:

Property name | Description | Default Value
--- | --- | ---
`crash_consistent` | Specifies whether to force crash consistent snapshots, can be `true` or `false` | `false`

#### snapshot_vmware_vm

##### Action: set

Takes an on-demand backup of the local machine.

Example usage:

```ruby
rubrik_snapshot_vmware_vm 'set' do
    action :set
    sla_domain 'Gold'
end
```

**NOTE: If sla_domain is set to 'Unprotected', snapshot will be taken with no SLA domain attached. If it is omitted, then snapshot will be taken with the SLA policy attached to the host. Otherwise, SLA Domain can be specified by name using the `sla_domain` attribute**

Example output:

```none
[2017-09-26T02:21:05-07:00] INFO: Processing rubrik_od_backup[set] action set (rubrik::od_backup line 10)
[2017-09-26T02:21:06-07:00] INFO: Getting ID for SLA domain: Gold
[2017-09-26T02:21:07-07:00] INFO: Triggering snapshot...
[2017-09-26T02:21:07-07:00] INFO: Snapshot initialisation complete
```

#### register_host

##### Action: get

Checks if the current host is registered to the Rubrik cluster. This first checks using the hostname gathered by Ohai, and if this returns a 404, will try via IP address.

Example usage:

```ruby
rubrik_register_host 'get' do
  action :get
end
```

Example output:

```none
[2017-10-09T01:35:38-07:00] INFO: Processing rubrik_register_host[get] action get (rubrik::register_host line 1)
[2017-10-09T01:35:38-07:00] INFO: Host is not registered against the Rubrik cluster
```

##### Action: set

Registers the host to the Rubrik cluster. This uses first the hostname gathered by Ohai, and if this returns a 404, will try via IP address.

Example usage:

```ruby
rubrik_register_host 'set' do
  action :set
end
```

Example output:

```none
[2017-10-09T01:36:00-07:00] INFO: Processing rubrik_register_host[set] action set (rubrik::register_host line 1)
[2017-10-09T01:36:01-07:00] INFO: Host is not registered against the Rubrik cluster, registering now
[2017-10-09T01:36:01-07:00] INFO: Host registered successfully against the Rubrik cluster
```

#### fileset

##### Action: get

Reports on filesets configured for the current host.

Example usage:

```ruby
rubrik_fileset 'get' do
  action :get
end
```

Example output:

```none
[2017-10-09T03:16:10-07:00] INFO: Processing rubrik_fileset[get] action get (rubrik::fileset line 9)
[2017-10-09T03:16:11-07:00] INFO: Host Current host ID is: Host:::a7654d58-dd3e-4918-a635-66b888400820
[2017-10-09T03:16:11-07:00] INFO: This host has 2 filesets currently assigned
[2017-10-09T03:16:11-07:00] INFO: Fileset 'Winner Chicken Dinner' found, with ID: Fileset:::ce5dcde7-937b-43cd-9efd-0ab9de56e363, and SLA domain: Silver
[2017-10-09T03:16:11-07:00] INFO: Fileset 'Home dirs' found, with ID: Fileset:::cb0b04a7-b210-43e3-98a7-2250800138f9, and SLA domain: Silver
```

##### Action: set

Reports on filesets configured for the current host.

Example usage:

```ruby
rubrik_fileset 'set' do
  action :set
end
```

Example output:

```none
[2017-10-09T08:21:14-07:00] INFO: Processing rubrik_fileset[set] action set (rubrik::fileset line 9)
[2017-10-09T08:21:15-07:00] INFO: Host Current host ID is: Host:::a7654d58-dd3e-4918-a635-66b888400820
[2017-10-09T08:21:17-07:00] INFO: Fileset Home dirs found, but SLA domain is not correct, correcting...
[2017-10-09T08:21:20-07:00] INFO: Fileset updated succesfully
[2017-10-09T08:21:20-07:00] INFO: Fileset Winner Chicken Dinner found, but SLA domain is not correct, correcting...
[2017-10-09T08:21:22-07:00] INFO: Fileset updated succesfully
```

#### set_sql_host_sla

##### Action: get

Gets the SLA domain associated with all instances on the host

```ruby
rubrik_set_sql_host_sla 'get' do
  action :get
end
```

##### Action: set

Sets the SLA domain protection for all instances on the host

Example usage:

```ruby
rubrik_set_sql_host_sla 'set' do
  action :set
end
```

Optional Properties:

The following optional parameters can be used when defining this resource:

Property name | Description | Default Value
--- | --- | ---
`log_backup_freq_minutes` | The number of minutes between transaction log backups | `30`
`log_retention_days` | The number of days to keep transaction logs | `7`

#### refresh_all_vcenters

##### Action: set

Refreshes the inventory for all vCenter servers on the Rubrik cluster

Example usage:

```ruby
rubrik_refresh_all_vcenters 'set' do
  action :set
end
```

#### refresh_host

##### Action: set

Refreshes the inventory for the current host

Example usage:

```ruby
rubrik_refresh_host 'set' do
  action :set
end
```

### Recipes

#### connector.rb

This recipe will install the connector on a RedHat, Debian, or Windows based system, pulling the connector install package from the cluster, and installing it.

##### Action: default

Installs the Rubrik connector on the target system, and configures it with the service account (Windows only) defined in the `rubrik_win_sa_user` and `rubrik_win_sa_pass` node variables.

Example usage:

```ruby
include_recipe 'rubrik::connector'
```

### object_organization

#### Action: get

Checks if the current object is added to the Organization name set in  `node['rubrik_org_name']`. Can specify object_type as `vmwarevm` (default), or `host` to add a physical host.

```ruby
rubrik_object_organization 'get' do
  action :get
  object_type 'host'
end
```

Example output:

```none
[2019-05-31T09:12:35+01:00] INFO: Processing rubrik_object_organization[get] action get (rubrik::get_object_organization line 9)
[2019-05-31T09:12:37+01:00] INFO: This object is currently assigned to Organization with name: DEVOPS
```

#### Action: set

Updates the Organization for the current object, to that set in `node['rubrik_org_name']`. Can specify object_type as `vmwarevm` (default), or `host` to add a physical host.

Example usage:

```ruby
rubrik_object_organization 'set' do
  action :set
  object_type 'host'
end
```

```none
[2019-05-31T09:12:23+01:00] INFO: Processing rubrik_object_organization[set] action set (rubrik::set_object_organization line 9)
[2019-05-31T09:12:26+01:00] INFO: Assigned object to Organization with name: DEVOPS
```
