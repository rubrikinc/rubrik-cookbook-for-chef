# # encoding: utf-8

# Inspec test for recipe rubrik::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# Connector port 12800
describe port(12800), :skip do
  it { should be_listening }
end

# Connector port 12801
describe port(12801), :skip do
  it { should be_listening }
end
