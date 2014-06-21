require 'spec_helper'

describe 'confluence' do
  let(:title) { 'confluence' }
  let(:server_xml) { '/opt/atlassian-confluence-5.3.1/conf/server.xml' }
  let(:setenv_sh) { '/opt/atlassian-confluence-5.3.1/bin/setenv.sh' }

  describe 'by default' do
    let(:params) { {} }

    specify { should contain_archive('atlassian-confluence-5.3.1') }
    specify { should contain_service('confluence').with_ensure('running').with_enable(true) }
    specify { should contain_service('confluence').with_require('Package[sun-java6-jdk]') }
    specify { should contain_file(server_xml).with_content(/protocol="AJP\/1.3"/) }
    specify { should contain_file(server_xml).with_content(/port="8009"/) }
  end

  describe 'with custom version' do
    let(:params) { {:version => '1.0.0'} }

    specify { should contain_archive('atlassian-confluence-1.0.0') }
  end

  describe 'with disable => true' do
    let(:params) { {:disable => true} }

    specify { should contain_service('confluence').with_ensure('stopped').with_enable(false) }
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

  describe 'depends on custom java package' do
    let(:params) { {:java_package => 'custom-java-jdk'} }

    specify { should contain_service('confluence').with_require('Package[custom-java-jdk]') }
  end
end
