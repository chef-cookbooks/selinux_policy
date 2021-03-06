require 'spec_helper'

describe 'selinux_policy fcontext' do
  before do
    allow_any_instance_of(Chef::Resource).to receive(:use_selinux).and_return(true)
  end
  let :chef_run do
    ChefSpec::SoloRunner.new(platform: 'centos', version: '7', step_into: ['selinux_policy_fcontext']).converge_dsl('selinux_policy') do
      selinux_policy_fcontext '/tmp/test' do
        secontext 'http_dir_t'
      end
    end
  end

  describe 'AddOrModify' do
    it 'creates when none' do
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+'").and_return(false)
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+system_u:object_r:http_dir_t:s0\\s*$'").and_return(false)
      expect(chef_run).to run_execute('selinux-fcontext-http_dir_t-add')
      expect(chef_run).not_to run_execute('selinux-fcontext-http_dir_t-modify')
    end
    it 'modifies when exists and mismatch' do
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+'").and_return(true)
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+system_u:object_r:http_dir_t:s0\\s*$'").and_return(false)
      expect(chef_run).not_to run_execute('selinux-fcontext-http_dir_t-add')
      expect(chef_run).to run_execute('selinux-fcontext-http_dir_t-modify')
    end
    it 'does nothing when match' do
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+'").and_return(true)
      stub_command("semanage fcontext -l | grep -qP '^/tmp/test\\s+all\\ files\\s+system_u:object_r:http_dir_t:s0\\s*$'").and_return(true)
      expect(chef_run).not_to run_execute('selinux-fcontext-http_dir_t-add')
      expect(chef_run).not_to run_execute('selinux-fcontext-http_dir_t-modify')
    end
  end

  describe 'Add' do
    # it 'creates when none'
    # it 'does nothing when exists'
  end

  describe 'Modify' do
    # it 'does nothing when none'
    # it 'modifies when exists and mismatch'
    # it 'does nothing when match'
  end

  describe 'Delete' do
    # it 'does nothing when none'
    # it 'removes when match'
  end
end
