RSpec.shared_context 'setup ldap mock' do |opts|
  let(:ldap_mock) { double(:ldap) }

  before do
    opts ||= {}
    expected_port = (opts[:for_ssl] ? 636 : 389)
    connection = (opts[:for_ssl] ? LDAP::SSLConn : LDAP::Conn)

    stub_const('CONFIG', CONFIG.merge({ 'ldap_servers' => 'my_ldap_server.com' }))

    allow(ldap_mock).to receive(:set_option).with(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_OFF)
    allow(ldap_mock).to receive(:set_option).with(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)

    if opts[:for_ssl]
      allow(connection).to receive(:new).with(
        'my_ldap_server.com', expected_port, opts[:start_tls] == true
      ).and_return(ldap_mock)
    else
      allow(connection).to receive(:new).with(
        'my_ldap_server.com', expected_port
      ).and_return(ldap_mock)
    end
  end
end

RSpec.shared_context 'an ldap connection' do
  before do
    allow(ldap_mock).to receive(:bind).with('tux', 'tux_password')
    allow(ldap_mock).to receive(:bound?).and_return(true)
  end
end

RSpec.shared_context 'an ldap connection that returns a user' do
  before do
    allow(ldap_mock).to receive(:search).and_yield(ldap_user)
    allow(ldap_mock).to receive(:unbind)
  end
end

RSpec.shared_context 'setup ldap mock with user mock' do |opts|
  let(:ldap_mock) { double(:ldap) }
  let(:ldap_user_mock) { double(:ldap_user) }

  before do
    opts ||= {}
    expected_port = (opts[:for_ssl] ? 636 : 389)
    connection = (opts[:for_ssl] ? LDAP::SSLConn : LDAP::Conn)

    stub_const('CONFIG', CONFIG.merge({ 'ldap_servers' => 'my_ldap_server.com' }))

    allow(ldap_mock).to receive(:set_option).with(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_OFF)
    allow(ldap_mock).to receive(:set_option).with(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
    allow(ldap_user_mock).to receive(:set_option).with(LDAP::LDAP_OPT_REFERRALS, LDAP::LDAP_OPT_OFF)
    allow(ldap_user_mock).to receive(:set_option).with(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)

    if opts[:for_ssl]
      allow(connection).to receive(:new).with(
        'my_ldap_server.com', expected_port, opts[:start_tls] == true
      ).and_return(ldap_mock, ldap_user_mock)
    else
      allow(connection).to receive(:new).with(
        'my_ldap_server.com', expected_port
      ).and_return(ldap_mock, ldap_user_mock)
    end
  end
end