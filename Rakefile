LIB_NAME = 'Task'
LIB_VERSION_FILE = File.join('lib', 'src', 'pixeldroid', 'task', 'TaskVersion.ls')

begin
  load(File.join(ENV['HOME'], '.loom', 'tasks', 'loomlib.rake'))
rescue LoadError
  abort([
    'error: missing loomlib.rake',
    '  please install loomtasks before running this Rakefile:',
    '  https://github.com/pixeldroid/loomtasks/',
  ].join("\n"))
end
