require 'rubygems'
require 'rspec'
require 'tempfile'
require 'pp'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'git-media'

RSpec.configure do |config|
end

def in_temp_git
  tf = Tempfile.new('gitdir')
  temppath = tf.path
  tf.unlink
  FileUtils.mkdir(temppath)
  Dir.chdir(temppath) do
    `git init`
    yield
  end
end

def in_temp_git_w_media
  bin = File.expand_path(File.join(File.dirname(__FILE__), '..', 'bin', 'git-media'))
  in_temp_git do
    append_file('testing1.mov', '1234567')
    append_file('testing2.mov', '123456789')
    append_file('normal.txt', 'hello world')
    append_file('.gitattributes', '*.mov filter=media')
    `git config filter.media.clean "#{bin} filter-clean"`
    `git config filter.media.smudge "#{bin} filter-smudge"`
    yield
  end
end

def append_file(filename, content)
  File.open(filename, 'w+') do |f|
    f.print content
  end
end

def git(command)
  output = `git #{command} 2>/dev/null`.strip
end
