#!/bin/env ruby

require "yaml"

FILE = ARGV.first

loaded = YAML.load(File.read(FILE))
if loaded.nil? || loaded.empty?
  puts "YAML file seems corrupted"
else
  puts "YAML file can be parsed without issue"
end

syntax_problems = {
  "Missing @" =>              /(?<!@){\s/,
  "Missing space after {" =>  /@{\w/,
  "Missing space before }" => /@{[^}]+("|\w)}/
}

multi_genderification_pattern = /@(?:\((\w+)\))?\{\s*(.*?)\s*\}/
gender_patterns = /(?:([mfo]):(?:\s*?([^"\r\n\t\f\v ]+)|"(.*?)")\s*)/

line_num = 1
File.open(FILE).each_line do |line|
  pb = []
  pb += syntax_problems.map do |comment, regex|
    comment if line =~ regex
  end.compact

  line.gsub(multi_genderification_pattern) do |match|
    pattern = $2
    gender_matches = pattern.scan(gender_patterns).map { |p| p.compact.map(&:strip) }.to_h

    missing_keys = gender_matches.keys - ["m", "f", "o"]
    pb.push("Missing keys #{missing_keys} for #{pattern}") if !missing_keys.empty?

    ["m", "f", "o"].each do |gender_key|
      pb.push("Missing inflexion for gender key '#{gender_key}'") if !gender_matches[gender_key] || gender_matches[gender_key].empty?
    end
  end

  puts "#{line_num}:\t#{pb.join(", ")}" if !pb.empty?
  line_num += 1
end
