require 'spec_helper_acceptance'

describe 'confluence' do
  specify 'should provision with no errors' do
    pp = <<-EOS
      $required_directories = [
        '/var/cache/puppet',
        '/var/cache/puppet/archives',
        '/opt',
      ]

      file { $required_directories:
        ensure => directory,
      }

      package { 'openjdk-6-jre':
        ensure => installed,
      }

      # test manifest
      class { 'confluence':
        java_package => 'openjdk-6-jre',
      }
    EOS

    # Run it twice and test for idempotency
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe file('/etc/init.d/confluence') do
    specify { should be_file }
    specify { should be_executable }
  end

  describe service('confluence') do
    specify { should be_running }
  end

  describe file('/opt/atlassian-confluence-current') do
    specify { should be_directory }
  end

  describe user('confluence') do
    specify { should exist }
    specify { should have_home_directory('/var/lib/confluence') }
    specify { should have_login_shell('/bin/false') }
  end

  describe file('/var/lib/confluence') do
    specify { should be_directory }
  end
end
