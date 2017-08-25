# Rubrik Chef Cookbook
## Overview
The Rubrik Chef cookbook is used to interact with a Rubrik cluster using Chef.
## Requirements
The following node attributes should be defined in order to use this cookbook:

Attribute Name | Example Value
--- | ---
rubrik_host | https://clustera.demo.com
rubrik_username | john.doe@demo.com'
rubrik_password | Rubrik123!
rubrik_sla_domain | Gold
rubrik_win_sa_user | sa_rubrik@demo.com
rubrik_win_sa_pass | Rubrik123!

Note that 'rubrik_win_sa_user' and 'rubrik_win_sa_pass' are optional, and will only be required if installing the
connector on a Windows system.

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
```
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_cluster_info[get] action get (rubrik::default line 7)
[2017-08-25T02:38:22-07:00] INFO: Cluster ID: 4a5d5fc5-a764-4c9c-8908-9d56e4221fd6
[2017-08-25T02:38:22-07:00] INFO: Cluster Version: 4.0.2-374
[2017-08-25T02:38:22-07:00] INFO: Cluster API version: 1
```
#### set_sla
##### Action: get
Dumps the current SLA domain for the host to the Chef log.

Example usage:
```ruby
rubrik_set_sla 'get' do
  action :get
end
```
Example output:
```
[2017-08-25T02:38:22-07:00] INFO: Processing rubrik_set_sla[get] action get (rubrik::default line 11)
[2017-08-25T02:38:24-07:00] INFO: Current SLA domain is: Silver
```
##### Action: set
Sets the SLA domain for the host to the value set in `node.['rubrik_sla_domain']`.

Example usage:
```ruby
rubrik_set_sla 'set' do
  action :set
end
```
Example output:
```
[2017-08-25T02:38:24-07:00] INFO: Processing rubrik_set_sla[set] action set (rubrik::default line 15)
[2017-08-25T02:38:27-07:00] INFO: Updated SLA domain to: Silver
```
