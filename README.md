# Rubrik Chef Cookbook
## Overview
The Rubrik Chef cookbook is used to interact with a Rubrik cluster using Chef.
## Requirements
The following node attributes should be defined in order to use this cookbook:

Attribute Name | Example Value
--- | ---
rubrik_host | https://clustera.demo.com
rubrik_username | john.doe@demo.com'
rubrik_password | 'Rubrik123!'
## Detail
The resources and providers used are defined in `libraries/rubrik_api.rb`, this module is subject to on-going development.
