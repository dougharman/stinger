#!/usr/bin/env ruby

puts "Asset count is starting up in the ::#{ENV['APP_ENV']}:: environment"

require_relative '../lib/stinger'

counter = 1
Stinger::Asset.where(:client_id => 2).take(10).each do |a|
  puts counter
  sa = Stinger::Sharded::Asset.using(:client_2).new(a.attributes)
  sa.save!
  Stinger::Sharded::Vulnerability.using(:client_3).bulk_insert do |worker|
    a.vulnerabilities.each do |v|
      worker.add(
        :id => v.id,
        :client_id => v.client_id,
        :asset_id => v.asset_id,
        :cve_id => v.cve_id,
        :notes => v.notes,
        :created_at => v.created_at,
        :updated_at => v.updated_at
      )
    end
  end
  counter += 1
end

puts Stinger::Asset.count
puts Stinger::Sharded::Asset.using(:client_2).count
