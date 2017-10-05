{% from "git/map.jinja" import git_settings with context %}
{% from "git/map.jinja" import git_config with context %}

include:
  - git

{% for username, user in git_settings.users.items() %}

set {{ username }}'s git username:
  git.config_set:
    - name: user.name
    - user: {{ username }}
    - value: "{{ user.get('fullname', username) }}"
    - global: True

{% if user.email is defined %}
set {{ username }}'s git email:
  git.config_set:
    - name: user.email
    - user: {{ username }}
    - value: "{{ user.email }}"
    - global: True
{% endif %}

{% if git_settings.managed_userconfig %}
git_config_{{ username }}:
  file.managed:
    - name: {{ user.get('config_file', "/home/" + username + "/.gitconfig") }}
    - source: {{ user.get('config_src', git_settings.config_src) }}
    - template: jinja
    - user: {{ user.get('config_user', username) }}
    - group: {{ user.get('config_group', username) }}
    - mode: {{ user.get('config_mode', git_settings.config_mode) }}
    - context:
        git_config: {{ user.get('git_config', git_config) }}
{% endif %}

{% endfor %}

{% if salt['pillar.get']('git_config', False) %}
git_config:
  file.managed:
    - name: {{ git_settings.config_file }}
    - source: {{ git_settings.config_src }}
    - template: jinja
    - user: {{ git_settings.config_user }}
    - group: {{ git_settings.config_group }}
    - mode: {{ git_settings.config_mode }}
    - context:
        git_config: {{ git_config }}
{% endif %}
