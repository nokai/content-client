require 'erb'

def CamelCase(s)
  s[0,1].downcase + s[1..-1]
end

BLOCKS_NAMES = ['SyncStarted',
                'SyncCompleted',
                'SyncFailed',
                'ContentItemDownloadStarted',
                'ContentItemDownloadProgressUpdate',
                'ContentItemDownloadCompleted',
                'ContentItemDownloadFailed']

instance_variables = <<-EOF

InfoBlock <%= CamelCase(block_name) %>Block;
EOF

interface = <<-EOF

- (void)set<%= block_name %>Block:(InfoBlock)a<%= block_name %>Block;
EOF

implementation = <<-EOF

- (void)set<%= block_name %>Block:(InfoBlock)a<%= block_name %>Block {
	[<%= CamelCase(block_name) %>Block release];
	<%= CamelCase(block_name) %>Block = [a<%= block_name %>Block copy];
}
EOF

print '// BEGIN CODEGEN - instance_variables'
BLOCKS_NAMES.each do |block_name|
  erb = ERB.new( instance_variables, nil, "-" )
  print erb.result( binding )
end
print "// END CODEGEN - instance_variables\n\n"

print '// BEGIN CODEGEN - interface'
BLOCKS_NAMES.each do |block_name|
  erb = ERB.new( interface, nil, "-" )
  print erb.result( binding )
end
print "// END CODEGEN - interface\n\n"

print "// BEGIN CODEGEN - implementation"
BLOCKS_NAMES.each do |block_name|
  erb = ERB.new( implementation, nil, "-" )
  print erb.result( binding )
end
print "// END CODEGEN - implementation\n\n"