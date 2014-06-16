require 'rubygems'
require 'json'

def whyrun_supported?
    true
end

action :set do
    if @current_resource.exists
        Chef::Log.info "#{@new_resource} already exists - nothing to do."
    else
        converge_by("Configure Phabricator: set #{@new_resource}") do
            set_config(@new_resource.name, @new_resource.value)
        end
    end
end

action :delete do
    if not @current_resource.exists
        Chef::Log.info "#{@new_resource} does not exist - nothing to do."
    else
        converge_by("Configure Phabricator: delete #{@new_resource}") do
            delete_config(@new_resource.name)
        end
    end
end

def load_current_resource
    @current_resource = Chef::Resource::PhabricatorConfig.new(@new_resource.name)
    @current_resource.name(@new_resource.name)
    @current_resource.value(@new_resource.value)

    value = get_config(@new_resource.name)
    if @new_resource.value == value
        @current_resource.exists = true
    end
end

def get_config(name)
    str = run_shell("#{config_tool_binary} get #{name}")
    hash = JSON.parse(str)
    if hash.length == 0 or hash['config'].length == 0
        return nil
    end
    hash['config'][0]['value']
end

def set_config(name, value)
    if value.class == TrueClass
        value = 'true'
    elsif value.class == FalseClass
        value = 'false'
    end
    run_shell "#{config_tool_binary} set #{name} #{value}"
end

def delete_config(name)
    run_shell "#{config_tool_binary} delete #{name}"
end

def run_shell(cmd)
    p = shell_out!(cmd)
    p.stdout
end

def config_tool_binary
    "#{@new_resource.path}/phabricator/bin/config"
end
