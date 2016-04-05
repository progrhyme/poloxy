MForwd       = Module.new
MForwd::Util = Module.new

require 'camel_snake'
require 'json'
require 'redis'
require 'redis-namespace'
require 'hiredis'
require 'stdlogger'
require 'toml'

require_relative 'mforwd/buffer'
require_relative 'mforwd/config'
require_relative 'mforwd/deliver'
require_relative 'mforwd/deliver/base'
require_relative 'mforwd/error'
require_relative 'mforwd/item'
require_relative 'mforwd/item/merge'
require_relative 'mforwd/item/merge/base'
require_relative 'mforwd/logging'
require_relative 'mforwd/message'
