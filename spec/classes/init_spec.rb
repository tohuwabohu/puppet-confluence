require 'spec_helper'

describe 'confluence' do
  let(:title) { 'confluence' }
  let(:archive_name) { 'atlassian-confluence-5.6.3' }
  let(:application_dir) { "/opt/#{archive_name}" }
  let(:cron_script) { '/etc/cron.daily/purge-old-confluence-backups' }
  let(:server_xml) { '/opt/atlassian-confluence-current/conf/server.xml' }
  let(:service_script) { '/etc/init.d/confluence' }
  let(:setenv_sh) { '/opt/atlassian-confluence-current/bin/setenv.sh' }
  let(:user_sh) { '/opt/atlassian-confluence-current/bin/user.sh' }

  describe 'by default' do
    let(:params) { {} }

    specify { should contain_archive(archive_name) }
    specify { should contain_user('confluence') }
    specify { should contain_group('confluence') }
    specify { should contain_service('confluence').with_ensure('running').with_enable(true) }
    specify { should contain_service('confluence').with_require('Package[sun-java6-jdk]') }
    specify { should contain_file(application_dir) }
    specify { should contain_file('/opt/atlassian-confluence-current').with_target(application_dir) }
    specify { should contain_file(cron_script).with_ensure('absent') }
    specify { should contain_file(server_xml).with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file(server_xml).with_content(/port="8009"/) }
    specify { should contain_file(setenv_sh).without_content(/-Datlassian.plugins.enable.wait=/) }
    specify { should contain_file(user_sh).with_content(/^CONF_USER="confluence"/) }
    specify { should contain_file(service_script).with_content(/^PIDFILE=\/var\/run\/confluence\/confluence.pid$/) }
    specify { should contain_file(service_script).with_content(/^START_SCRIPT=\/opt\/atlassian-confluence-current\/bin\/start-confluence.sh$/) }
    specify { should contain_file(service_script).with_content(/^STOP_SCRIPT=\/opt\/atlassian-confluence-current\/bin\/stop-confluence.sh$/) }
    specify { should contain_file(service_script).with_content(/^cd \/var\/lib\/confluence$/) }
  end

  describe 'should not accept empty hostname' do
    let(:params) { {:hostname => ''} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /hostname/)
    end
  end

  describe 'with version => 1.0.0' do
    let(:params) { {:version => '1.0.0'} }

    specify { should contain_archive('atlassian-confluence-1.0.0') }
  end

  describe 'should not accept empty version' do
    let(:params) { {:version => ''} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /version/)
    end
  end

  describe 'should accept empty md5sum' do
    let(:params) { {:md5sum => ''} }

    specify { should contain_archive(archive_name).with_digest_string('') }
  end

  describe 'with custom md5sum' do
    let(:params) { {:md5sum => 'beef'} }

    specify { should contain_archive(archive_name).with_digest_string('beef') }
  end

  describe 'should not accept empty service_disabled' do
    let(:params) { {:service_disabled => ''} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /service_disabled/)
    end
  end

  describe 'should not accept invalid service_disabled' do
    let(:params) { {:service_disabled => 'invalid'} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /service_disabled/)
    end
  end

  describe 'with service_disabled => true' do
    let(:params) { {:service_disabled => true} }

    specify { should contain_service('confluence').with_ensure('stopped').with_enable(false) }
  end

  describe 'with service_disabled => false' do
    let(:params) { {:service_disabled => false} }

    specify { should contain_service('confluence').with_ensure('running').with_enable(true) }
  end

  describe 'should not accept empty service_name' do
    let(:params) { {:service_name => ''} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /service_name/)
    end
  end

  describe 'with custom service_name' do
    let(:params) { {:service_name => 'jdoe'} }

    specify { should contain_user('jdoe') }
    specify { should contain_group('jdoe') }
    specify { should contain_service('jdoe') }
    specify { should contain_file(user_sh).with_content(/^CONF_USER="jdoe"/) }
  end

  describe 'should not accept invalid service_uid' do
    let(:params) { {:service_uid => 'invalid'} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /service_uid/)
    end
  end

  describe 'should accept valid service_uid' do
    let(:params) { {:service_uid => 500} }

    specify { should contain_user('confluence').with_uid(500) }
  end

  describe 'should accept empty service_uid' do
    let(:params) { {:service_gid => ''} }

    specify { should contain_user('confluence').with_uid('') }
  end

  describe 'should not accept invalid service_gid' do
    let(:params) { {:service_gid => 'invalid'} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /service_gid/)
    end
  end

  describe 'should accept valid service_gid' do
    let(:params) { {:service_gid => 500} }

    specify { should contain_user('confluence').with_gid('confluence') }
    specify { should contain_group('confluence').with_gid(500) }
  end

  describe 'should accept empty service_gid' do
    let(:params) { {:service_gid => ''} }

    specify { should contain_user('confluence').with_gid('confluence') }
    specify { should contain_group('confluence').with_gid('') }
  end

  describe 'with default HTTP address and port' do
    let(:params) { {:protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/address="127.0.0.1"/) }
    specify { should contain_file(server_xml).with_content(/port="8090"/) }
  end

  describe 'with empty HTTP address' do
    let(:params) { {:http_address => '', :protocols => ['http']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with wildcard HTTP address' do
    let(:params) { {:http_address => '*', :protocols => ['http']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with custom HTTP address' do
    let(:params) { {:http_address => '1.2.3.4', :protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom HTTP port' do
    let(:params) { {:http_port => '80', :protocols => ['http']} }

    specify { should contain_file(server_xml).with_content(/port="80"/) }
  end

  describe 'with custom AJP port' do
    let(:params) { {:ajp_port => 1234, :protocols => ['ajp']} }

    specify { should contain_file(server_xml).with_content(/port="1234"/) }
  end

  describe 'with empty AJP address' do
    let(:params) { {:ajp_address => '', :protocols => ['ajp']} }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with wildcard AJP address' do
    let(:params) { { :ajp_address => '*', :protocols => ['ajp'] } }

    specify { should contain_file(server_xml).without_content(/address=/) }
  end

  describe 'with custom AJP address' do
    let(:params) { {:ajp_address => '1.2.3.4', :protocols => ['ajp']} }

    specify { should contain_file(server_xml).with_content(/address="1.2.3.4"/) }
  end

  describe 'with custom java opts' do
    let(:params) { {:java_opts => '-Xms512m -Xmx1024m'} }

    specify { should contain_file(setenv_sh).with_content(/-Xms512m -Xmx1024m/) }
  end

  describe 'should not accept empty java opts' do
    let(:params) { {:java_opts => ''} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /java_opts/)
    end
  end

  describe 'depends on custom java package' do
    let(:params) { {:java_package => 'custom-java-jdk'} }

    specify { should contain_service('confluence').with_require('Package[custom-java-jdk]') }
  end

  describe 'should not accept invalid purge_backups_after' do
    let(:params) { {:purge_backups_after => 'invalid'} }

    specify do
      expect { should contain_class('confluence') }.to raise_error(Puppet::Error, /purge_backups_after/)
    end
  end

  describe 'should accept empty purge_backups_after' do
    let(:params) { {:purge_backups_after => ''} }

    specify { should contain_file(cron_script).with_ensure('absent') }
  end

  describe 'with purge_backups_after => 7 days' do
    let(:params) { {:purge_backups_after => 7} }

    specify { should contain_file(cron_script).with_ensure('file') }
    specify { should contain_file(cron_script).with_content(/\/var\/lib\/confluence\/backups\//) }
    specify { should contain_file(cron_script).with_content(/-mtime \+7/) }
  end
end
