{% from "git/map.jinja" import git_settings with context %}

include:
  - git

{% for username, user in git_settings.users %}

set git {{ username }} username:
  git.config_set:
    - name: user.name
    - user: {{ username }}
    - value: "{{ user.get('full_name', username) }}"
    - global: True

{% if user.email is defined %}
set git {{ username }} email:
  git.config_set:
    - name: user.email
    - user: {{ username }}
    - value: "{{ user.email }}"
    - global: True
{% endif %}

{% if git_settings.managed_userconfig %}
git_config_{{ username }}:
  file.managed:
    - name: {{ user.get('home', username) }}/.gitconfig
    - source: {{ user.get('config_source', git_settings.git_config_src) }}
    - template: jinja
    - user: {{ username }}
    - group: {{ user.get('group', username) }}
    - mode: {{ git_settings.git_config_mode }}
{% endif %}

{% endfor %}

{% if salt['pillar.get']('git_config', False) %}
git_config:
  file.managed:
    - name: {{ git_settings.git_config }}
    - source: {{ git_settings.git_config_src }}
    - template: jinja
    - user: {{ git_settings.git_config_user }}
    - group: {{ git_settings.git_config_group }}
    - mode: {{ git_settings.git_config_mode }}
{% endif %}
