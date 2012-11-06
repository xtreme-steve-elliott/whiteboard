module WithAuthorizedIps
  def with_authorized_ips(ips=nil)
    old_value = AuthorizedIps::AUTHORIZED_IP_ADDRESSES

    ips ||= {sf: [IPAddr.new("127.0.0.1/27")]}
    Kernel::silence_warnings { AuthorizedIps.const_set('AUTHORIZED_IP_ADDRESSES', ips) }

    yield

    Kernel::silence_warnings { AuthorizedIps.const_set('AUTHORIZED_IP_ADDRESSES', old_value) }
  end
end
