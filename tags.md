---
layout: page
title: Tags
permalink: /tags
---


# Projects

{% assign project_slugs = '' | split: '' %}
{% for page in site.pages %}
  {% if page.path contains "projects" %}
  {% assign project_title = page.title %}
  <a name="{{project_title | slugify}}"></a>
  <a class="smallcaps tag nav" href="{{ page.url }}">{{project_title}}</a> - {{ page.description }}
  {% assign project_slug = project_title | slugify %}
  {% assign project_slugs = project_slugs | append: project_title | slugify %}

  {%- for post in site.posts -%}
    {% assign post_proj_name = post.categories.last | slugify %}
    {%- if post_proj_name == project_slug -%}
[{{ post.title }}]({{ post.url }})
    {%- endif -%}
  {%- endfor -%}

  {% endif %}
{% endfor %}


# Other categories

{% for cat in site.categories %}
  {% assign cat_name = cat | first %}
  {% assign cat_slug = cat_name | slugify %}

  {%- if cat_slug contains "projects" -%}
  {%- elsif project_slugs contains cat_slug -%}
  {%- else -%}
  <a name="{{cat_slug}}"></a>
  <a class="smallcaps tag nav" href="{{site.baseurl}}/tags.html#{{ cat_slug }}">#{{cat_name}}:</a>
  {%- for post in site.posts -%}
    {%- if post.categories contains cat_name -%}
  [{{ post.title }}]({{post.url}})
    {%- endif -%}
  {%- endfor -%}
  {%- endif -%}
{% endfor %}


# Tags

{% for tag in site.tags %}
  {% assign tag_name = tag | first %}
  {% assign tag_slug = tag_name | slugify %}
  <a name="{{tag_slug}}"></a>
  <a class="smallcaps tag nav" href="{{site.baseurl}}/tags.html#{{tag_slug}}">#{{tag_name}}:</a>
  {%- for post in site.posts -%}
    {% if post.tags contains tag_name %}
  [{{ post.title }}]({{post.url}})
    {% endif %}
  {%- endfor -%}
{% endfor %}

