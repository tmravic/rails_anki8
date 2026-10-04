ActiveRecordProxyAdapters.configure do |config|
  # 0 means a SELECT goes to the replica immediately, including right after a write.
  config.proxy_delay = 0.seconds
end